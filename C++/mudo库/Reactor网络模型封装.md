## Reactor部分

基于epoll底层代码的封装，主线程中有一个事件循环mainLoop,监听客户端发起连接的socketfd，当其中的socketfd成功建立连接后，
则封装成一个connectionfd，connectionfd中存储了一个channel（怎么通过这个channel操作这个connectionfd的？），对connectionfd进行epoll_ctl操作

mainLoop中每生产一个fd，都会循环唤醒一个subLoop进行消费

### Channel

主要作用，在用户态对socketfd、eventfd的封装，主要表现在为fd设置了事件、回调函数

一个channel如果绑定了多个事件（如可读可写等），会封装成epoll_event结构体并存储在内核的事件表中，events成员是一个位掩码，用于标识该fd上发生的事件类型

#### 主要变量

1. fd以及目前的事件状态
```C++
const int fd_;    // fd, Poller监听的对象
int events_; // 注册fd感兴趣的事件
int revents_; // poller返回的具体发生的事件

const int Channel::kNoneEvent = 0;                     // 对啥都不感兴趣，此时需要将其从poll中删除
const int Channel::kReadEvent = EPOLLIN | EPOLLPRI;    // 对读事件感兴趣
const int Channel::kWriteEvent = EPOLLOUT;             // 对写事件感兴趣
```

2. 绑定的回调: 

- 只读事件回调需设置超时时间，防止网络中断fd的读端关闭，导致subLoop线程一直读不到数据而一直阻塞在回调函数。 
- 利用移动语义对channel的回调函数进行赋值。这个回调函数是其他模块过来的，这块内存不需要再使用了，因此直接将b所占用的资源移交给a
   - 注意，a和b是两个不用的对象，不是直接将a指向b的地址，b后续是会被释放的，只是b所占用的资源因为被a占有了不会释放。
   - b移交的资源包括：内存资源、文件句柄，网络资源等。
- 事件回调初始化时机，以可读事件为例：
   - mainLoop的acceptor初始化，需要设置可读回调，当有连接连接成功后，将该连接进行分发
   - subLoop的wakeup初始化：当一个新连接分发给subLoop后，主线程会向该subLoop的wakeup写一字节数据，唤醒subLoop
   - subLoop的connection初始化：读缓存区的网络数据

```C++
using EventCallback = std::function<void()>;   // 事件回调
using ReadEventCallback = std::function<void(Timestamp)>;  // 只读事件回调

ReadEventCallback readCallback_;
EventCallback writeCallback_;
EventCallback closeCallback_;
EventCallback errorCallback_; 

// 这里用移动语义设置回调函数对象，
// eventLoop构造函数中为wakeupfd设置，当mainLoop往subLoop写socketfd时，触发该回调
// （该回调绑定EventLoop的handlRead(),去内核读已连接的socketfd），该EventLoop发生读事件，epoll_wait返回，唤醒线程
void setReadCallback(ReadEventCallback cb) { readCallback_ = std::move(cb); }   // 会在acceptor的构造函数和  Acceptor的构造函数什么时候被调用？
void setWriteCallback(EventCallback cb) { writeCallback_ = std::move(cb); }       
void setCloseCallback(EventCallback cb) { closeCallback_ = std::move(cb); }
void setErrorCallback(EventCallback cb) { errorCallback_ = std::move(cb); }
```

#### 初始化

主要注意以下三个值的变化：
1. loop_: channl会被注册到某个poll上，也就是某个loop中，因为一个线程一个loop，一个loop一个poller（loop可视为对epoll的封装）
2. index_=-1: 表示该channel未注册到poller中
3. tied_=false: 当新连接建立时，绑定tcpconnection和channel，当connection断开，channel感知执行回调，调用tcpconnection绑定的方法 
   - 防止channel被手动释放，我们还在用的这样一种跨线程的操作？

```C++
Channel::Channel(EventLoop *loop, int fd)
: loop_(loop), fd_(fd), events_(0), revents_(0), index_(-1), tied_(false)
{
}
```

#### Loop操作

更新、注册、删除loop中的channel

```C++
void Channel::update()
{
    // 通过channel所属的EventLoop，调用poller的相应方法，注册、更新、删除
    loop_->updateChannel(this);
}

// 在channel所属的EventLoop中， 把当前的channel删除掉
void Channel::remove()
{
    loop_->removeChannel(this);
}
```

#### 事件处理

EventLoop中，epoll_wait事件返回后，调用handleEvent，执行channel的回调

```C++
// fd得到poller通知以后，处理事件的
void Channel::handleEvent(Timestamp receiveTime)
{
    if (tied_)   // 绑定过，监听我当前的这个channel
    {
        std::shared_ptr<void> guard = tie_.lock();   // 提升成强智能指针
        if (guard)
        {
            handleEventWithGuard(receiveTime);
        }
    }
    else
    {
        handleEventWithGuard(receiveTime);
    }
}

// 根据poller通知的channel发生的具体事件， 由channel处理实际发生的事件
void Channel::handleEventWithGuard(Timestamp receiveTime)
{
    LOG_INFO("channel handleEvent revents:%d\n", revents_);

    if ((revents_ & EPOLLHUP) && !(revents_ & EPOLLIN))
    {
        if (closeCallback_)
        {
            closeCallback_();
        }
    }

    if (revents_ & EPOLLERR)
    {
        if (errorCallback_)
        {
            errorCallback_();
        }
    }

    if (revents_ & (EPOLLIN | EPOLLPRI))
    {
        if (readCallback_)
        {
            readCallback_(receiveTime);    // 超时时间
        }
    }

    if (revents_ & EPOLLOUT)
    {
        if (writeCallback_)
        {
            writeCallback_();
        }
    }
}
```

### poller

windwos下用selector实现，linux下用epoller实现

#### 主要变量

1. ChannelMap: 用户态存储poller中的channel，wakeupChannel不需要存储在这里
```C++
using ChannelMap = std::unordered_map<int, Channel*>;
ChannelMap channels_ 
```

2. EventLoop *ownerLoop_: 定义Poller所属的事件循环EventLoop


#### 主要接口

都申明为虚函数，用于selector，epoll实现

1. Timestamp poll(int timeoutMs, ChannelList *activeChannels)：循环调用epoll_wait(),处理发生的事件

2. void updateChannel(Channel *channel): 调用epoll_ctl(),更新poll中的channel

3. static Poller* newDefaultPoller(EventLoop *loop): 根据环境变量，生成selector或epoll的实例

4. bool hasChannel(Channel *channel)： 判断channel是否在当前poller当中

### epoll

对poller的继承

#### 主要变量

1. channel是否在epoll中
```C++
// channel未添加到poller中
const int kNew = -1;  // channel的成员index_ = -1
// channel已添加到poller中
const int kAdded = 1;
// channel从poller中删除
const int kDeleted = 2; 
```

2. 事件接收向量：
```C++
using EventList = std::vector<epoll_event>;
EventList events_;
static const int kInitEventListSize = 16;    // 向量大小，也就是用户态一次处理的事件数量
```

3. int epollfd_: epoll进行wait、ctl操作的句柄

#### 初始化

```C++
EPollPoller::EPollPoller(EventLoop *loop)
    : Poller(loop)             // 初始化自己所属的loop，这个loop是主线程创建传给subLoop的
    , epollfd_(::epoll_create1(EPOLL_CLOEXEC))        // 创建一个epollfd，作为epoll_wait、epoll_ctl的句柄
    , events_(kInitEventListSize)  // 接收等待队列事件的向量大小
{
    if (epollfd_ < 0)
    {
        LOG_FATAL("epoll_create error:%d \n", errno);
    }
}
```

#### poll()

在epoll中poll()封装的是`epoll_wait()`

注意：当epoll_wait()返回的事件数量等于事件向量的容量时，事件向量需进行扩容，减少陷入内核的次数

```C++
Timestamp EPollPoller::poll(int timeoutMs, ChannelList *activeChannels)
{
    // LT模式，这次取不完的下次继续取
    LOG_INFO("func=%s => fd total count:%lu \n", __FUNCTION__, channels_.size());

    int numEvents = ::epoll_wait(epollfd_, &*events_.begin(), static_cast<int>(events_.size()), timeoutMs);
    int saveErrno = errno;
    Timestamp now(Timestamp::now());

    if (numEvents > 0)
    {
        LOG_INFO("%d events happened \n", numEvents);
        fillActiveChannels(numEvents, activeChannels);
        if (numEvents == events_.size())
        {
            events_.resize(events_.size() * 2);
        }
    }
    else if (numEvents == 0)
    {
        LOG_DEBUG("%s timeout! \n", __FUNCTION__);
    }
    else
    {
        if (saveErrno != EINTR)
        {
            errno = saveErrno;
            LOG_ERROR("EPollPoller::poll() err!");
        }
    }
    return now;
}
```

#### channel操作

主要涉及`epoll_ctl()`操作

1. 更新channel通道 epoll_ctl add/mod/del

```C++
void EPollPoller::update(int operation, Channel *channel)
{
    epoll_event event;
    bzero(&event, sizeof event);
    
    int fd = channel->fd();

    event.events = channel->events();  // epoll的事件结构体，data包括fd和用户指针
    event.data.fd = fd; 
    event.data.ptr = channel;
    
    if (::epoll_ctl(epollfd_, operation, fd, &event) < 0)
    {
        if (operation == EPOLL_CTL_DEL)
        {
            LOG_ERROR("epoll_ctl del error:%d\n", errno);
        }
        else
        {
            LOG_FATAL("epoll_ctl add/mod error:%d\n", errno);
        }
    }
}
```

2. 设置channel的add/mod/del操作

```C++
void EPollPoller::updateChannel(Channel *channel)      // 分为两种情况，在poller中注册过，和没注册过
{
    const int index = channel->index();
    LOG_INFO("func=%s => fd=%d events=%d index=%d \n", __FUNCTION__, channel->fd(), channel->events(), index);

    if (index == kNew || index == kDeleted)
    {
        if (index == kNew)   // 如wakeupchannel初始化时,执行这里,将channel加入epoll和channelMap
        {
            int fd = channel->fd();
            channels_[fd] = channel;
        }
        // 如果channel只是从epoll中删除，只需要将channel添加到epoll 
        // 当一个fd暂时对任务事件都不感兴趣时，只需要从epoll中移除
        channel->set_index(kAdded);         
        update(EPOLL_CTL_ADD, channel);
    }
    else  // channel已经在poller上注册过了
    {
        int fd = channel->fd();
        if (channel->isNoneEvent())      // channel对事件不感兴趣，则从epoll中移除
        {
            update(EPOLL_CTL_DEL, channel);
            channel->set_index(kDeleted);
        }
        else
        {
            update(EPOLL_CTL_MOD, channel);   // 上面都是对channel对应的节点进行增删，这里是更新channel的事件
        }
    }
}

// 从poller中删除channel
void EPollPoller::removeChannel(Channel *channel) 
{
    int fd = channel->fd();
    channels_.erase(fd);

    LOG_INFO("func=%s => fd=%d\n", __FUNCTION__, fd);
    
    int index = channel->index();
    if (index == kAdded)
    {
        update(EPOLL_CTL_DEL, channel);
    }
    channel->set_index(kNew);
}
```

3. 填充活跃连接

将epoll发生事件的channel列表返回到loop. 将eventList中的事件先复制到channelList，防止业务代码阻塞，一直无法epoll_wait()

```C++
// 填写活跃的连接
void EPollPoller::fillActiveChannels(int numEvents, ChannelList *activeChannels) const
{
    for (int i=0; i < numEvents; ++i)
    {
        Channel *channel = static_cast<Channel*>(events_[i].data.ptr);    // ptr = channel
        channel->set_revents(events_[i].events);
        activeChannels->push_back(channel); // EventLoop就拿到了它的poller给它返回的所有发生事件的channel列表了
    }
}
```

### EventLoop

EventLoop可视为Reactor中的的事件分发器，将不同的channel分发给不同的poller，本项目采用的轮询分发

#### 主要变量

1. loop循环标识

```C++
std::atomic_bool looping_;  // 原子操作，通过CAS实现的
std::atomic_bool quit_; // 标识退出loop循环
```

2. 所属线程

```C++
pid_t threadId_;
__thread EventLoop *t_loopInThisThread = nullptr;   // 线程局部存储EventLoop指针，线程创建epoll时会在本线程的局部存储区存储此epoll的指针
```

3. poller参数：

```C++
Timestamp pollReturnTime_; // poller返回发生事件的channels的时间点
std::unique_ptr<Poller> poller_;    // loop中的poller

ChannelList activeChannels_;  // 活跃列表，发生事件的channel
```

4. wakeup唤醒机制

```C++
int wakeupFd_; // 主要作用，当mainLoop获取一个新用户的channel，通过轮询算法选择一个subloop，通过该成员唤醒subloop处理channel
std::unique_ptr<Channel> wakeupChannel_;
```

5. 回调操作：好像有个情况是不用加入回调向量就直接执行的？
```C++
std::atomic_bool callingPendingFunctors_; // 标识当前loop是否有需要执行的回调操作
std::vector<Functor> pendingFunctors_; // 存储loop需要执行的所有的回调操作
// 互斥锁，用来保护上面vector容器的线程安全操作,如一个连接建立成功时，
// 主线程会往子线程的回调数组写入连接建立回调，并会向wakeupfd写数据唤醒子线程，这个过程，子线程回调数组的这块内存不能被其他线程写入，容易产生莫名奇妙的问题
std::mutex mutex_; 
```


#### 初始化

1. 将标识字段都置为默认值
2. 设置所属线程id，等最后epoll创建完成后，将t_loopInThisThread指向该epoll（并控制一个线程只能指向一个poller）
3. 初始化poller，如果是Linux，则创建epoll
4. 创建wakeupfd（eventfd）,并封装成wakeupChannel，然后为wakeupChannel绑定可读回调事件（这样mainLoop向subLoop的wakeupfd写socket时，会立即触发回调唤醒线程）

```C++
// 创建wakeupfd，用来notify唤醒subReactor处理新来的channel
int createEventfd()
{
    int evtfd = ::eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
    if (evtfd < 0)
    {
        LOG_FATAL("eventfd error:%d \n", errno);
    }
    return evtfd;
}

EventLoop::EventLoop()
    : looping_(false)
    , quit_(false)
    , callingPendingFunctors_(false)
    , threadId_(CurrentThread::tid())
    , poller_(Poller::newDefaultPoller(this))
    , wakeupFd_(createEventfd())
    , wakeupChannel_(new Channel(this, wakeupFd_))
{
    LOG_DEBUG("EventLoop created %p in thread %d \n", this, threadId_);
    if (t_loopInThisThread)
    {
        LOG_FATAL("Another EventLoop %p exists in this thread %d \n", t_loopInThisThread, threadId_);
    }
    else
    {
        t_loopInThisThread = this;
    }

    // 设置wakeupfd的事件类型以及发生事件后的回调操作,也就是去读一个字节（其实handleRead回调函数是啥并不重要，因为主要调用的是主线程设置的回调）
    wakeupChannel_->setReadCallback(std::bind(&EventLoop::handleRead, this));     // 本eventloop对象
    // 每一个eventloop都将监听wakeupchannel的EPOLLIN读 事件了
    wakeupChannel_->enableReading();
}

EventLoop::~EventLoop()
{
    wakeupChannel_->disableAll();
    wakeupChannel_->remove();
    ::close(wakeupFd_);
    t_loopInThisThread = nullptr;
}
```

### 事件循环

循环开启：调用poll(),将返回的活跃channel挨个处理，执行其绑定的回调操作。

pendingFunctors_的作用是用来存储其他线程需要该epoll执行的回调。

```C++
// 开启事件循环
void EventLoop::loop()
{
    looping_ = true;
    quit_ = false;

    LOG_INFO("EventLoop %p start looping \n", this);

    while(!quit_)
    {
        activeChannels_.clear();
        // 监听两类fd   一种是client的fd，一种wakeupfd
        pollReturnTime_ = poller_->poll(kPollTimeMs, &activeChannels_);
        for (Channel *channel : activeChannels_)
        {
            // Poller监听哪些channel发生事件了，然后上报给EventLoop，通知channel处理相应的事件
            channel->handleEvent(pollReturnTime_);
        }
        // 执行当前EventLoop事件循环需要处理的回调操作
        /**
         * IO线程 mainLoop accept fd《=channel subloop
         * mainLoop 事先注册一个回调cb（需要subloop来执行）    wakeup subloop后，执行下面的方法，执行之前mainloop注册的cb操作（来源于TCPServer模块）
         */

        // 这里执行完一轮回调后，又阻塞在poll了，（为了节约时间）, mainloop向loop注册回调时(注册回调不一定执行回调)
        // 唤醒该loop，活跃链表不一定是空的，因为可能业务代码太冗杂，还没执行完
        doPendingFunctors();
    }

    LOG_INFO("EventLoop %p stop looping. \n", this);
    looping_ = false;
}

// 退出事件循环  1.loop在自己的线程中调用quit  2.在非loop的线程中，调用loop的quit（主要是主线让子线程休眠）
void EventLoop::quit()
{
    quit_ = true;

    // 如果是在其它线程中，调用的quit   在一个subloop(woker)中，调用了mainLoop(IO)的quit
    if (!isInLoopThread())  
    {
        wakeup();   // 先唤醒，然后！quit不满足条件，退出 
    }
}
```

### 线程唤醒机制

前面说了EventLoop初始化会给wakeupchannel绑定可读回调事件

```C++
void EventLoop::handleRead()
{
  // 读8字节，fd为int
  uint64_t one = 1;
  ssize_t n = read(wakeupFd_, &one, sizeof one);   // 读一个socket，epoll就感知到了，
  if (n != sizeof one)
  {
    LOG_ERROR("EventLoop::handleRead() reads %lu bytes instead of 8", n);
  }
}
```

当其他线程调用本EventLooop实例的wakeup方法时，会向wakeupfd写一个socket，触发其可读事件，epoll_wait()将立即返回唤醒线程

```C++
void EventLoop::handleRead()
{
  // 读8字节，fd为int
  uint64_t one = 1;
  ssize_t n = read(wakeupFd_, &one, sizeof one);   // 读一个socket，epoll就感知到了，
  if (n != sizeof one)
  {
    LOG_ERROR("EventLoop::handleRead() reads %lu bytes instead of 8", n);
  }
}
```

### 执行回调

如果是在本线程，则直接执行回调即可，如果是需要其他线程执行回调，则需要将回调加入到回调向量，并唤醒对应的线程：

```C++
// 在当前loop中执行cb
void EventLoop::runInLoop(Functor cb)     // 在哪调用
{
    if (isInLoopThread()) // 在当前的loop线程中，执行cb
    {
        cb();
    }
    else // 在非当前loop线程中执行cb（为什么会的？） , 就需要唤醒loop所在线程，执行cb   为什么其他loop会调我的回调啊？  就是指的mainloop向loop添加回调吧？
    {
        queueInLoop(cb);
    }
}
// 把cb放入队列中，唤醒loop所在的线程，执行cb
void EventLoop::queueInLoop(Functor cb)
{
    {
        std::unique_lock<std::mutex> lock(mutex_);    // 主线程也会给subLoop加回调
        pendingFunctors_.emplace_back(cb);
    }

    // 唤醒相应的subloop，需要执行上面回调操作的loop的线程了
    // || callingPendingFunctors_的意思是：当前loop正在执行回调，但是loop又有了新的回调
    if (!isInLoopThread() || callingPendingFunctors_)    //  !isInLoopThread()主要就是针对mainLoop向subLoop的wakeupfd分发的情况
    {
        wakeup(); // 唤醒loop所在线程
    }
}
```

runInLoop在很多地方调用：
- tcpserver: 销毁连接，将channel从poller中删除，并注销其所有的事件
- tcpserver: 关闭连接，数据发送完成后，关闭channel的写段
- 开启监听：acceptorChannel注册读事件
    - 所有subLoop启动后，acceptor监听mainLoop的连接。
    - 由于新的连接少，但请求很多，所以mainLoop可以不用epoll,如果用epoll，epoll中的fd可以绑定相同的端口，也可以绑定不同的端口
        - 使用epoll的缺点就是fd需要占用内存，主要是频繁地上下文切换，降低服务器性能  => 本项目采用mianLoop使用epoll，也兼容一个mainLoop处理所有请求（单线程模式）。
- 新连接：注册可读事件
- send()发送数据：chanel所在的poller可能不在本线程
    - testserver在初始化时，onMessage函数调用tcpconnection的send()函数,而onMessage会在connectionfd收到数据时调用
    - 但有的场景，会将所有channel的操作收集起来，一起send()

执行回调操作,注意先将回调函数都取出来，防阻塞：

```C++
void EventLoop::doPendingFunctors() // 执行回调
{
    std::vector<Functor> functors;
    callingPendingFunctors_ = true;
    
    // 先把回调向量都取出来，防止阻塞，其他loop（main loop）可能会向你这个loop注册回调，而这个向量被锁住了（注册和取出都要加锁），
    // 你不执行完，mainloop就没法向你的loop里注册回调  =》 时延大  
    // 类似于上面的活跃链表，回调函数不执行完，没法再去内核拿事件了
    {
        std::unique_lock<std::mutex> lock(mutex_);
        functors.swap(pendingFunctors_);
    }

    for (const Functor &functor : functors)
    {
        functor(); // 执行当前loop需要执行的回调操作
    }

    callingPendingFunctors_ = false;
}
```