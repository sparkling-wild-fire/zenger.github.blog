## Reactor����

����epoll�ײ����ķ�װ�����߳�����һ���¼�ѭ��mainLoop,�����ͻ��˷������ӵ�socketfd�������е�socketfd�ɹ��������Ӻ�
���װ��һ��connectionfd��connectionfd�д洢��һ��channel����ôͨ�����channel�������connectionfd�ģ�������connectionfd����epoll_ctl����

mainLoop��ÿ����һ��fd������ѭ������һ��subLoop��������

### Channel

��Ҫ���ã����û�̬��socketfd��eventfd�ķ�װ����Ҫ������Ϊfd�������¼����ص�����

һ��channel������˶���¼�����ɶ���д�ȣ������װ��epoll_event�ṹ�岢�洢���ں˵��¼����У�events��Ա��һ��λ���룬���ڱ�ʶ��fd�Ϸ������¼�����

#### ��Ҫ����

1. fd�Լ�Ŀǰ���¼�״̬
```C++
const int fd_;    // fd, Poller�����Ķ���
int events_; // ע��fd����Ȥ���¼�
int revents_; // poller���صľ��巢�����¼�

const int Channel::kNoneEvent = 0;                     // ��ɶ��������Ȥ����ʱ��Ҫ�����poll��ɾ��
const int Channel::kReadEvent = EPOLLIN | EPOLLPRI;    // �Զ��¼�����Ȥ
const int Channel::kWriteEvent = EPOLLOUT;             // ��д�¼�����Ȥ
```

2. �󶨵Ļص�: 

- ֻ���¼��ص������ó�ʱʱ�䣬��ֹ�����ж�fd�Ķ��˹رգ�����subLoop�߳�һֱ���������ݶ�һֱ�����ڻص������� 
- �����ƶ������channel�Ļص��������и�ֵ������ص�����������ģ������ģ�����ڴ治��Ҫ��ʹ���ˣ����ֱ�ӽ�b��ռ�õ���Դ�ƽ���a
   - ע�⣬a��b���������õĶ��󣬲���ֱ�ӽ�aָ��b�ĵ�ַ��b�����ǻᱻ�ͷŵģ�ֻ��b��ռ�õ���Դ��Ϊ��aռ���˲����ͷš�
   - b�ƽ�����Դ�������ڴ���Դ���ļ������������Դ�ȡ�
- �¼��ص���ʼ��ʱ�����Կɶ��¼�Ϊ����
   - mainLoop��acceptor��ʼ������Ҫ���ÿɶ��ص��������������ӳɹ��󣬽������ӽ��зַ�
   - subLoop��wakeup��ʼ������һ�������ӷַ���subLoop�����̻߳����subLoop��wakeupдһ�ֽ����ݣ�����subLoop
   - subLoop��connection��ʼ����������������������

```C++
using EventCallback = std::function<void()>;   // �¼��ص�
using ReadEventCallback = std::function<void(Timestamp)>;  // ֻ���¼��ص�

ReadEventCallback readCallback_;
EventCallback writeCallback_;
EventCallback closeCallback_;
EventCallback errorCallback_; 

// �������ƶ��������ûص���������
// eventLoop���캯����Ϊwakeupfd���ã���mainLoop��subLoopдsocketfdʱ�������ûص�
// ���ûص���EventLoop��handlRead(),ȥ�ں˶������ӵ�socketfd������EventLoop�������¼���epoll_wait���أ������߳�
void setReadCallback(ReadEventCallback cb) { readCallback_ = std::move(cb); }   // ����acceptor�Ĺ��캯����  Acceptor�Ĺ��캯��ʲôʱ�򱻵��ã�
void setWriteCallback(EventCallback cb) { writeCallback_ = std::move(cb); }       
void setCloseCallback(EventCallback cb) { closeCallback_ = std::move(cb); }
void setErrorCallback(EventCallback cb) { errorCallback_ = std::move(cb); }
```

#### ��ʼ��

��Ҫע����������ֵ�ı仯��
1. loop_: channl�ᱻע�ᵽĳ��poll�ϣ�Ҳ����ĳ��loop�У���Ϊһ���߳�һ��loop��һ��loopһ��poller��loop����Ϊ��epoll�ķ�װ��
2. index_=-1: ��ʾ��channelδע�ᵽpoller��
3. tied_=false: �������ӽ���ʱ����tcpconnection��channel����connection�Ͽ���channel��ִ֪�лص�������tcpconnection�󶨵ķ��� 
   - ��ֹchannel���ֶ��ͷţ����ǻ����õ�����һ�ֿ��̵߳Ĳ�����

```C++
Channel::Channel(EventLoop *loop, int fd)
: loop_(loop), fd_(fd), events_(0), revents_(0), index_(-1), tied_(false)
{
}
```

#### Loop����

���¡�ע�ᡢɾ��loop�е�channel

```C++
void Channel::update()
{
    // ͨ��channel������EventLoop������poller����Ӧ������ע�ᡢ���¡�ɾ��
    loop_->updateChannel(this);
}

// ��channel������EventLoop�У� �ѵ�ǰ��channelɾ����
void Channel::remove()
{
    loop_->removeChannel(this);
}
```

#### �¼�����

EventLoop�У�epoll_wait�¼����غ󣬵���handleEvent��ִ��channel�Ļص�

```C++
// fd�õ�poller֪ͨ�Ժ󣬴����¼���
void Channel::handleEvent(Timestamp receiveTime)
{
    if (tied_)   // �󶨹��������ҵ�ǰ�����channel
    {
        std::shared_ptr<void> guard = tie_.lock();   // ������ǿ����ָ��
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

// ����poller֪ͨ��channel�����ľ����¼��� ��channel����ʵ�ʷ������¼�
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
            readCallback_(receiveTime);    // ��ʱʱ��
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

windwos����selectorʵ�֣�linux����epollerʵ��

#### ��Ҫ����

1. ChannelMap: �û�̬�洢poller�е�channel��wakeupChannel����Ҫ�洢������
```C++
using ChannelMap = std::unordered_map<int, Channel*>;
ChannelMap channels_ 
```

2. EventLoop *ownerLoop_: ����Poller�������¼�ѭ��EventLoop


#### ��Ҫ�ӿ�

������Ϊ�麯��������selector��epollʵ��

1. Timestamp poll(int timeoutMs, ChannelList *activeChannels)��ѭ������epoll_wait(),���������¼�

2. void updateChannel(Channel *channel): ����epoll_ctl(),����poll�е�channel

3. static Poller* newDefaultPoller(EventLoop *loop): ���ݻ�������������selector��epoll��ʵ��

4. bool hasChannel(Channel *channel)�� �ж�channel�Ƿ��ڵ�ǰpoller����

### epoll

��poller�ļ̳�

#### ��Ҫ����

1. channel�Ƿ���epoll��
```C++
// channelδ��ӵ�poller��
const int kNew = -1;  // channel�ĳ�Աindex_ = -1
// channel����ӵ�poller��
const int kAdded = 1;
// channel��poller��ɾ��
const int kDeleted = 2; 
```

2. �¼�����������
```C++
using EventList = std::vector<epoll_event>;
EventList events_;
static const int kInitEventListSize = 16;    // ������С��Ҳ�����û�̬һ�δ�����¼�����
```

3. int epollfd_: epoll����wait��ctl�����ľ��

#### ��ʼ��

```C++
EPollPoller::EPollPoller(EventLoop *loop)
    : Poller(loop)             // ��ʼ���Լ�������loop�����loop�����̴߳�������subLoop��
    , epollfd_(::epoll_create1(EPOLL_CLOEXEC))        // ����һ��epollfd����Ϊepoll_wait��epoll_ctl�ľ��
    , events_(kInitEventListSize)  // ���յȴ������¼���������С
{
    if (epollfd_ < 0)
    {
        LOG_FATAL("epoll_create error:%d \n", errno);
    }
}
```

#### poll()

��epoll��poll()��װ����`epoll_wait()`

ע�⣺��epoll_wait()���ص��¼����������¼�����������ʱ���¼�������������ݣ����������ں˵Ĵ���

```C++
Timestamp EPollPoller::poll(int timeoutMs, ChannelList *activeChannels)
{
    // LTģʽ�����ȡ������´μ���ȡ
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

#### channel����

��Ҫ�漰`epoll_ctl()`����

1. ����channelͨ�� epoll_ctl add/mod/del

```C++
void EPollPoller::update(int operation, Channel *channel)
{
    epoll_event event;
    bzero(&event, sizeof event);
    
    int fd = channel->fd();

    event.events = channel->events();  // epoll���¼��ṹ�壬data����fd���û�ָ��
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

2. ����channel��add/mod/del����

```C++
void EPollPoller::updateChannel(Channel *channel)      // ��Ϊ�����������poller��ע�������ûע���
{
    const int index = channel->index();
    LOG_INFO("func=%s => fd=%d events=%d index=%d \n", __FUNCTION__, channel->fd(), channel->events(), index);

    if (index == kNew || index == kDeleted)
    {
        if (index == kNew)   // ��wakeupchannel��ʼ��ʱ,ִ������,��channel����epoll��channelMap
        {
            int fd = channel->fd();
            channels_[fd] = channel;
        }
        // ���channelֻ�Ǵ�epoll��ɾ����ֻ��Ҫ��channel��ӵ�epoll 
        // ��һ��fd��ʱ�������¼���������Ȥʱ��ֻ��Ҫ��epoll���Ƴ�
        channel->set_index(kAdded);         
        update(EPOLL_CTL_ADD, channel);
    }
    else  // channel�Ѿ���poller��ע�����
    {
        int fd = channel->fd();
        if (channel->isNoneEvent())      // channel���¼�������Ȥ�����epoll���Ƴ�
        {
            update(EPOLL_CTL_DEL, channel);
            channel->set_index(kDeleted);
        }
        else
        {
            update(EPOLL_CTL_MOD, channel);   // ���涼�Ƕ�channel��Ӧ�Ľڵ������ɾ�������Ǹ���channel���¼�
        }
    }
}

// ��poller��ɾ��channel
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

3. ����Ծ����

��epoll�����¼���channel�б��ص�loop. ��eventList�е��¼��ȸ��Ƶ�channelList����ֹҵ�����������һֱ�޷�epoll_wait()

```C++
// ��д��Ծ������
void EPollPoller::fillActiveChannels(int numEvents, ChannelList *activeChannels) const
{
    for (int i=0; i < numEvents; ++i)
    {
        Channel *channel = static_cast<Channel*>(events_[i].data.ptr);    // ptr = channel
        channel->set_revents(events_[i].events);
        activeChannels->push_back(channel); // EventLoop���õ�������poller�������ص����з����¼���channel�б���
    }
}
```

### EventLoop

EventLoop����ΪReactor�еĵ��¼��ַ���������ͬ��channel�ַ�����ͬ��poller������Ŀ���õ���ѯ�ַ�

#### ��Ҫ����

1. loopѭ����ʶ

```C++
std::atomic_bool looping_;  // ԭ�Ӳ�����ͨ��CASʵ�ֵ�
std::atomic_bool quit_; // ��ʶ�˳�loopѭ��
```

2. �����߳�

```C++
pid_t threadId_;
__thread EventLoop *t_loopInThisThread = nullptr;   // �ֲ߳̾��洢EventLoopָ�룬�̴߳���epollʱ���ڱ��̵߳ľֲ��洢���洢��epoll��ָ��
```

3. poller������

```C++
Timestamp pollReturnTime_; // poller���ط����¼���channels��ʱ���
std::unique_ptr<Poller> poller_;    // loop�е�poller

ChannelList activeChannels_;  // ��Ծ�б������¼���channel
```

4. wakeup���ѻ���

```C++
int wakeupFd_; // ��Ҫ���ã���mainLoop��ȡһ�����û���channel��ͨ����ѯ�㷨ѡ��һ��subloop��ͨ���ó�Ա����subloop����channel
std::unique_ptr<Channel> wakeupChannel_;
```

5. �ص������������и�����ǲ��ü���ص�������ֱ��ִ�еģ�
```C++
std::atomic_bool callingPendingFunctors_; // ��ʶ��ǰloop�Ƿ�����Ҫִ�еĻص�����
std::vector<Functor> pendingFunctors_; // �洢loop��Ҫִ�е����еĻص�����
// ��������������������vector�������̰߳�ȫ����,��һ�����ӽ����ɹ�ʱ��
// ���̻߳������̵߳Ļص�����д�����ӽ����ص���������wakeupfdд���ݻ������̣߳�������̣����̻߳ص����������ڴ治�ܱ������߳�д�룬���ײ���Ī�����������
std::mutex mutex_; 
```


#### ��ʼ��

1. ����ʶ�ֶζ���ΪĬ��ֵ
2. ���������߳�id�������epoll������ɺ󣬽�t_loopInThisThreadָ���epoll��������һ���߳�ֻ��ָ��һ��poller��
3. ��ʼ��poller�������Linux���򴴽�epoll
4. ����wakeupfd��eventfd��,����װ��wakeupChannel��Ȼ��ΪwakeupChannel�󶨿ɶ��ص��¼�������mainLoop��subLoop��wakeupfdдsocketʱ�������������ص������̣߳�

```C++
// ����wakeupfd������notify����subReactor����������channel
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

    // ����wakeupfd���¼������Լ������¼���Ļص�����,Ҳ����ȥ��һ���ֽڣ���ʵhandleRead�ص�������ɶ������Ҫ����Ϊ��Ҫ���õ������߳����õĻص���
    wakeupChannel_->setReadCallback(std::bind(&EventLoop::handleRead, this));     // ��eventloop����
    // ÿһ��eventloop��������wakeupchannel��EPOLLIN�� �¼���
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

### �¼�ѭ��

ѭ������������poll(),�����صĻ�Ծchannel��������ִ����󶨵Ļص�������

pendingFunctors_�������������洢�����߳���Ҫ��epollִ�еĻص���

```C++
// �����¼�ѭ��
void EventLoop::loop()
{
    looping_ = true;
    quit_ = false;

    LOG_INFO("EventLoop %p start looping \n", this);

    while(!quit_)
    {
        activeChannels_.clear();
        // ��������fd   һ����client��fd��һ��wakeupfd
        pollReturnTime_ = poller_->poll(kPollTimeMs, &activeChannels_);
        for (Channel *channel : activeChannels_)
        {
            // Poller������Щchannel�����¼��ˣ�Ȼ���ϱ���EventLoop��֪ͨchannel������Ӧ���¼�
            channel->handleEvent(pollReturnTime_);
        }
        // ִ�е�ǰEventLoop�¼�ѭ����Ҫ����Ļص�����
        /**
         * IO�߳� mainLoop accept fd��=channel subloop
         * mainLoop ����ע��һ���ص�cb����Ҫsubloop��ִ�У�    wakeup subloop��ִ������ķ�����ִ��֮ǰmainloopע���cb��������Դ��TCPServerģ�飩
         */

        // ����ִ����һ�ֻص�����������poll�ˣ���Ϊ�˽�Լʱ�䣩, mainloop��loopע��ص�ʱ(ע��ص���һ��ִ�лص�)
        // ���Ѹ�loop����Ծ����һ���ǿյģ���Ϊ����ҵ�����̫���ӣ���ûִ����
        doPendingFunctors();
    }

    LOG_INFO("EventLoop %p stop looping. \n", this);
    looping_ = false;
}

// �˳��¼�ѭ��  1.loop���Լ����߳��е���quit  2.�ڷ�loop���߳��У�����loop��quit����Ҫ�����������߳����ߣ�
void EventLoop::quit()
{
    quit_ = true;

    // ������������߳��У����õ�quit   ��һ��subloop(woker)�У�������mainLoop(IO)��quit
    if (!isInLoopThread())  
    {
        wakeup();   // �Ȼ��ѣ�Ȼ��quit�������������˳� 
    }
}
```

### �̻߳��ѻ���

ǰ��˵��EventLoop��ʼ�����wakeupchannel�󶨿ɶ��ص��¼�

```C++
void EventLoop::handleRead()
{
  // ��8�ֽڣ�fdΪint
  uint64_t one = 1;
  ssize_t n = read(wakeupFd_, &one, sizeof one);   // ��һ��socket��epoll�͸�֪���ˣ�
  if (n != sizeof one)
  {
    LOG_ERROR("EventLoop::handleRead() reads %lu bytes instead of 8", n);
  }
}
```

�������̵߳��ñ�EventLooopʵ����wakeup����ʱ������wakeupfdдһ��socket��������ɶ��¼���epoll_wait()���������ػ����߳�

```C++
void EventLoop::handleRead()
{
  // ��8�ֽڣ�fdΪint
  uint64_t one = 1;
  ssize_t n = read(wakeupFd_, &one, sizeof one);   // ��һ��socket��epoll�͸�֪���ˣ�
  if (n != sizeof one)
  {
    LOG_ERROR("EventLoop::handleRead() reads %lu bytes instead of 8", n);
  }
}
```

### ִ�лص�

������ڱ��̣߳���ֱ��ִ�лص����ɣ��������Ҫ�����߳�ִ�лص�������Ҫ���ص����뵽�ص������������Ѷ�Ӧ���̣߳�

```C++
// �ڵ�ǰloop��ִ��cb
void EventLoop::runInLoop(Functor cb)     // ���ĵ���
{
    if (isInLoopThread()) // �ڵ�ǰ��loop�߳��У�ִ��cb
    {
        cb();
    }
    else // �ڷǵ�ǰloop�߳���ִ��cb��Ϊʲô��ģ��� , ����Ҫ����loop�����̣߳�ִ��cb   Ϊʲô����loop����ҵĻص�����  ����ָ��mainloop��loop��ӻص��ɣ�
    {
        queueInLoop(cb);
    }
}
// ��cb��������У�����loop���ڵ��̣߳�ִ��cb
void EventLoop::queueInLoop(Functor cb)
{
    {
        std::unique_lock<std::mutex> lock(mutex_);    // ���߳�Ҳ���subLoop�ӻص�
        pendingFunctors_.emplace_back(cb);
    }

    // ������Ӧ��subloop����Ҫִ������ص�������loop���߳���
    // || callingPendingFunctors_����˼�ǣ���ǰloop����ִ�лص�������loop�������µĻص�
    if (!isInLoopThread() || callingPendingFunctors_)    //  !isInLoopThread()��Ҫ�������mainLoop��subLoop��wakeupfd�ַ������
    {
        wakeup(); // ����loop�����߳�
    }
}
```

runInLoop�ںܶ�ط����ã�
- tcpserver: �������ӣ���channel��poller��ɾ������ע�������е��¼�
- tcpserver: �ر����ӣ����ݷ�����ɺ󣬹ر�channel��д��
- ����������acceptorChannelע����¼�
    - ����subLoop������acceptor����mainLoop�����ӡ�
    - �����µ������٣�������ܶ࣬����mainLoop���Բ���epoll,�����epoll��epoll�е�fd���԰���ͬ�Ķ˿ڣ�Ҳ���԰󶨲�ͬ�Ķ˿�
        - ʹ��epoll��ȱ�����fd��Ҫռ���ڴ棬��Ҫ��Ƶ�����������л������ͷ���������  => ����Ŀ����mianLoopʹ��epoll��Ҳ����һ��mainLoop�����������󣨵��߳�ģʽ����
- �����ӣ�ע��ɶ��¼�
- send()�������ݣ�chanel���ڵ�poller���ܲ��ڱ��߳�
    - testserver�ڳ�ʼ��ʱ��onMessage��������tcpconnection��send()����,��onMessage����connectionfd�յ�����ʱ����
    - ���еĳ������Ὣ����channel�Ĳ����ռ�������һ��send()

ִ�лص�����,ע���Ƚ��ص�������ȡ��������������

```C++
void EventLoop::doPendingFunctors() // ִ�лص�
{
    std::vector<Functor> functors;
    callingPendingFunctors_ = true;
    
    // �Ȱѻص�������ȡ��������ֹ����������loop��main loop�����ܻ��������loopע��ص����������������ס�ˣ�ע���ȡ����Ҫ��������
    // �㲻ִ���꣬mainloop��û�������loop��ע��ص�  =�� ʱ�Ӵ�  
    // ����������Ļ�Ծ�����ص�������ִ���꣬û����ȥ�ں����¼���
    {
        std::unique_lock<std::mutex> lock(mutex_);
        functors.swap(pendingFunctors_);
    }

    for (const Functor &functor : functors)
    {
        functor(); // ִ�е�ǰloop��Ҫִ�еĻص�����
    }

    callingPendingFunctors_ = false;
}
```