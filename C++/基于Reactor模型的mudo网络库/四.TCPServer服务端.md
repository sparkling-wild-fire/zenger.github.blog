### TCP封装

1. Acceptor类：当有新用户连接，通过accept获取connfd
2. TcpConnection: 设置回调，将建立的连接轮询分发给subLoop  
   - 分发给subLoop后，将绑定的channel设置为待插入，通过线程对象的eventLoop对象进行插入

#### Acceptor

Acceptor是对listenfd的封装，而listenfd是一个Socket封装后的对象（此处省略）

##### 主要成员变量

1. loop指针：绑定mainLoop
2. acceptSocket_: 一个绑定了ip和端口的fd。如果要监听多个端口，可以设置多个acceptSocket
3. acceptChannel_：主要用来给listenfd设置可读事件
4. newConnectionCallback_: 连接成功的回调函数
5. listenning_：是否开启监听

##### 初始化

listenfd要设置为非阻塞的，不然没有客户端连接请求时，fd会一直等待，把主线程阻塞，无法处理其他事件

```c++
static int createNonblocking()
{
    // SOCK_NONBLOCK非阻塞
    int sockfd = ::socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK | SOCK_CLOEXEC, 0);
    if (sockfd < 0) 
    {
        LOG_FATAL("%s:%s:%d listen socket create err:%d \n", __FILE__, __FUNCTION__, __LINE__, errno);  // 公司的日志都是打印了宏的
    }
}

Acceptor::Acceptor(EventLoop *loop, const InetAddress &listenAddr, bool reuseport)
    : loop_(loop)
    , acceptSocket_(createNonblocking()) // sockfd要设置成非阻塞的
    , acceptChannel_(loop, acceptSocket_.fd())  // Channel初始化
    , listenning_(false)
{
    acceptSocket_.setReuseAddr(true);
    acceptSocket_.setReusePort(true);
    acceptSocket_.bindAddress(listenAddr); // bind
    // TcpServer::start() Acceptor.listen  有新用户的连接，要执行一个回调（connfd=》channel=》subloop）  =》 channel是accept仍过来
    // baseLoop => acceptChannel_(listenfd) => 
    acceptChannel_.setReadCallback(std::bind(&Acceptor::handleRead, this));    // 给Channel设置可读事件回调
}

Acceptor::~Acceptor()
{
    acceptChannel_.disableAll();
    acceptChannel_.remove();
}
```

##### 开启监听

```C++
void Acceptor::listen()
{
    listenning_ = true;
    // 第二个参数是在连接队列中等待的连接数量的最大值（通常被称为backlog）。
    // 在调用listen()函数之后，套接字将变为被动模式，等待客户端连接。
    // 一旦有客户端连接请求到达，服务器将接受该连接并返回一个新的套接字描述符，可以使用该描述符与客户端通信
    acceptSocket_.listen(); 
    acceptChannel_.enableReading(); // 注册读事件，放到mainLoop中，如果要监听多个端口，可以创建多个acceptChannel注册到mainLoop
}

// listenfd有事件发生了，就是有新用户连接了
void Acceptor::handleRead()
{
    InetAddress peerAddr;
    int connfd = acceptSocket_.accept(&peerAddr);   // fd可能被用完  =》 集群 、 提高fd数量
    if (connfd >= 0)
    {
        if (newConnectionCallback_)    // 在tcpServer定义
        {
            // 轮询找到subLoop，唤醒，分发当前的新客户端的Channel(新连接回调在tcpserver中设置)
            newConnectionCallback_(connfd, peerAddr); 
        }
        else
        {
            ::close(connfd);
        }
    }
    else
    {
        LOG_ERROR("%s:%s:%d accept err:%d \n", __FILE__, __FUNCTION__, __LINE__, errno);
        if (errno == EMFILE)
        {
            LOG_ERROR("%s:%s:%d sockfd reached limit! \n", __FILE__, __FUNCTION__, __LINE__);
        }
    }
}
```

#### TcpConnection

1. 连接状态：enum StateE {kDisconnected(不能进行数据的收发了), kConnecting, kConnected, kDisconnecting}
2. subLoop指针
3. 一个socketfd指针，一个channel指针
4. ip和端口信息
5. 回调：
    - connectionCallback_：新连接回调  （为什么你会有新连接回调的，这不是acceptfd的事情吗）
    - messageCallback_：读写消息回调
    - highWaterMarkCallback_： 发送和接收速率控制（配合highWaterMark_成员）
    - - writeCompleteCallback_： 消息发送完成后的回调
    - closeCallback_：连接关闭回调
6. 接收缓存区、发送缓存区


#### 初始化

因为TCPConnection对象都是已连接的对象，因此需先检测它指向的loop是否已经启动`CheckLoopNotNull`

```C++
static EventLoop* CheckLoopNotNull(EventLoop *loop)
{
    if (loop == nullptr)
    {
        LOG_FATAL("%s:%s:%d TcpConnection Loop is null! \n", __FILE__, __FUNCTION__, __LINE__);
    }
    return loop;
}

TcpConnection::TcpConnection(EventLoop *loop, 
                const std::string &nameArg, 
                int sockfd,
                const InetAddress& localAddr,
                const InetAddress& peerAddr)
    : loop_(CheckLoopNotNull(loop))              // 检查loop是否已经启动
    , name_(nameArg)                            
    , state_(kConnecting)                   // 状态设置为连接中
    , reading_(true)                        
    , socket_(new Socket(sockfd))               
    , channel_(new Channel(loop, sockfd))       // connectChannel
    , localAddr_(localAddr)
    , peerAddr_(peerAddr)
    , highWaterMark_(64*1024*1024) // 64M 高水位设置
{
    // 下面给channel设置相应的回调函数，poller给channel通知感兴趣的事件发生了，channel会回调相应的操作函数
    channel_->setReadCallback(
        std::bind(&TcpConnection::handleRead, this, std::placeholders::_1)
    );
    channel_->setWriteCallback(
        std::bind(&TcpConnection::handleWrite, this)
    );
    channel_->setCloseCallback(
        std::bind(&TcpConnection::handleClose, this)
    );
    channel_->setErrorCallback(
        std::bind(&TcpConnection::handleError, this)
    );

    LOG_INFO("TcpConnection::ctor[%s] at fd=%d\n", name_.c_str(), sockfd);
    socket_->setKeepAlive(true);   // Socket类中的setsockopt系统调用
}


TcpConnection::~TcpConnection()
{
    LOG_INFO("TcpConnection::dtor[%s] at fd=%d state=%d \n", 
        name_.c_str(), channel_->fd(), (int)state_);
}
```

##### 连接建立与销毁

```C++
// 连接建立
void TcpConnection::connectEstablished()
{
    setState(kConnected);
    // 遇到的问题：tcpconnection 下面管理这一个channel，而channel的回调都是tcpconnection绑定传给他的，
    // 因此如果tcpconnection被remove调了的话，channel再去调用对应的回调函数，结果就是未知的了,如去读缓冲区，此时客户端心跳超时，发送者一直收到不到消息
    // 这里将channel的tied_变量指向当前的TCPConnnection对象，如果这个对象被remove了，这个对象就是NULL了，channel在执行回调时，如果判断tied_为NULL,就不执行回调，或者报错处理
    channel_->tie(shared_from_this());
    channel_->enableReading(); // 向poller注册channel的epollin事件
    // 新连接建立，执行回调
    connectionCallback_(shared_from_this());
}

// 连接销毁
void TcpConnection::connectDestroyed()
{
    if (state_ == kConnected)
    {
        setState(kDisconnected);
        channel_->disableAll(); // 把channel的所有感兴趣的事件，从poller中del掉
        connectionCallback_(shared_from_this());
    }
    channel_->remove(); // 把channel从poller中删除掉
}
```

#### 数据发送

数据如果能直接发送，那就直接发送，如果发送不了，那就把失败的部分写到写缓存区，然后注册epollout可写回调

```C++
// 正常来说是buffer的入参，并转成json发送出去
void TcpConnection::send(const std::string &buf)
{
    if (state_ == kConnected)
    {
        if (loop_->isInLoopThread())
        {
            sendInLoop(buf.c_str(), buf.size());
        }
        else     // 有的场景特殊，需要把fd的发送事件收集起来，一起发送
        {
            loop_->runInLoop(std::bind(
                &TcpConnection::sendInLoop,
                this,
                buf.c_str(),
                buf.size()
            )); 
        }
    }
}

/**
 * 发送数据  应用写的快， 而内核发送数据慢， 需要把待发送数据写入缓冲区， 而且设置了水位回调
 */ 
void TcpConnection::sendInLoop(const void* data, size_t len)
{
    ssize_t nwrote = 0;
    size_t remaining = len;
    bool faultError = false;

    // 之前调用过该connection的shutdown，不能再进行发送了
    if (state_ == kDisconnected)
    {
        LOG_ERROR("disconnected, give up writing!");
        return;
    }

    // 如果channel_没有设置可写事件（代码逻辑是可写事件回调是从发送缓存区写数据到内核），并且缓存区没有它待发送的数据，那就直接将数据写到内核，其他情况都是发送缓冲区的数据
    // 刚开始封装成channel没设置对写事件感兴趣  =》 只是connection中有一个channel对象，并且为这个channel对象设置读写、关闭、错误回调，并没设置感兴趣的事件
    if (!channel_->isWriting() && outputBuffer_.readableBytes() == 0)  // buff可读（发送缓冲区）为0才能发送，因为上一次的可能还没发送出去
    {
        nwrote = ::write(channel_->fd(), data, len);   // 这种系统函数不是buff写内存了嘛 =》 不写buff，直接发送
        if (nwrote >= 0)       // 发送成功了
        {
            remaining = len - nwrote;    // 剩余可写长度（发送长度？）
            if (remaining == 0 && writeCompleteCallback_)     // 既然在这里数据全部发送完成，调用写入完成回调，就不用再给channel设置epollout事件了
            {
                // epollout事件表示一个文件描述符上的写操作已经就绪，可以进行写操作了，但我都发送完成了，就不用注册可写事件
                loop_->queueInLoop(
                    std::bind(writeCompleteCallback_, shared_from_this())
                );
            }    // 这里不用来个else注册写事件，在后面
        }
        else // nwrote < 0
        {
            nwrote = 0;
            if (errno != EWOULDBLOCK)
            {
                LOG_ERROR("TcpConnection::sendInLoop");
                if (errno == EPIPE || errno == ECONNRESET) // SIGPIPE  RESET
                {
                    faultError = true;
                }
            }
        }
    }

    // 没有错误，且当前这没有把数据全部发送出去，剩余的数据需要保存到缓冲区当中，然后给channel
    // 注册epollout事件，poller发现tcp的发送缓冲区有空间，会通知相应的sock-channel，调用writeCallback_回调方法
    // 也就是调用TcpConnection::handleWrite方法，把发送缓冲区中的数据全部发送完成
    if (!faultError && remaining > 0) 
    {
        // 目前发送缓冲区剩余的待发送数据的长度+这次send()每发送完的，超过了高水位，说明内核处理不过来，就需要为这个连接channel调用高水位回调
        size_t oldLen = outputBuffer_.readableBytes();
        if (oldLen + remaining >= highWaterMark_     // 这是可以将多次未发送完成的消息全部放到缓存区里
            && oldLen < highWaterMark_    // 之前的如果大于高水位，那么之前就调用了高水位回调了
            && highWaterMarkCallback_)
        {
            loop_->queueInLoop(
                std::bind(highWaterMarkCallback_, shared_from_this(), oldLen+remaining) 
            );
        }
        outputBuffer_.append((char*)data + nwrote, remaining);
        if (!channel_->isWriting())
        {
            channel_->enableWriting(); // 这里一定要注册channel的写事件，否则poller不会给channel通知epollout
        }
}
```

写回调：内核的发送缓冲区如果有空间，就会产生epollout事件，用户态会把用户态缓存区的数据写道内核态的缓冲区

```c++
void TcpConnection::handleWrite()
{
    if (channel_->isWriting())
    {
        int savedErrno = 0;
        ssize_t n = outputBuffer_.writeFd(channel_->fd(), &savedErrno);
        if (n > 0)
        {
            outputBuffer_.retrieve(n);
            if (outputBuffer_.readableBytes() == 0)    // 发送完成
            {
                channel_->disableWriting();    // 发送完成，注销可写事件，下次还是直接发送
                if (writeCompleteCallback_)    // 调用发送完成回调
                {
                    // 唤醒loop_对应的thread线程，执行回调
                    loop_->queueInLoop(
                        std::bind(writeCompleteCallback_, shared_from_this())
                    );
                }
                // 如果此时tcpconnection对象调用了shutdown方法关闭这个channel，则要等这个channel的数据发送完成才可以。
                if (state_ == kDisconnecting)   
                {
                    shutdownInLoop();
                }
            }
        }
        else
        {
            LOG_ERROR("TcpConnection::handleWrite");
        }
    }
    else
    {
        LOG_ERROR("TcpConnection fd=%d is down, no more writing \n", channel_->fd());
    }
}

// 服务器关闭连接
void TcpConnection::shutdown()
{
    if (state_ == kConnected)
    {
        setState(kDisconnecting);
        loop_->runInLoop(
            std::bind(&TcpConnection::shutdownInLoop, this)
        );
    }
}

void TcpConnection::shutdownInLoop()
{
    if (!channel_->isWriting()) // 说明outputBuffer中的数据已经全部发送完成
    {
        socket_->shutdownWrite(); // 服务器关闭连接，也就会关闭写端，发生事件回调，回调handleClose，注销channel上的所有事件
    }
}

// poller => channel::closeCallback => TcpConnection::handleClose
void TcpConnection::handleClose()
{
    LOG_INFO("TcpConnection::handleClose fd=%d state=%d \n", channel_->fd(), (int)state_);
    setState(kDisconnected);
    channel_->disableAll();

    TcpConnectionPtr connPtr(shared_from_this());
    connectionCallback_(connPtr); // 执行连接关闭的回调
    closeCallback_(connPtr); // 关闭连接的回调  执行的是TcpServer::removeConnection回调方法 
}
```

##### 接收数据

一个连接成功建立后就会注册可读回调，接收数据先放到缓存区，如果有可读事件发生，但读出来的数据长度为0，那么是客户端要关闭连接了

```C++
void TcpConnection::handleRead(Timestamp receiveTime)
{
    int savedErrno = 0;
    ssize_t n = inputBuffer_.readFd(channel_->fd(), &savedErrno);
    if (n > 0)
    {
        // 已建立连接的用户，有可读事件发生了，调用用户传入的回调操作onMessage
        messageCallback_(shared_from_this(), &inputBuffer_, receiveTime);
    }
    else if (n == 0)
    {
        handleClose();
    }
    else
    {
        errno = savedErrno;
        LOG_ERROR("TcpConnection::handleRead");
        handleError();
    }
}
```


#### Tcpserver

##### 主要变量

1. baseLoop: 用户自定义mainLoop、acceptor: 监听新连接事件
2. threadPool_： EventLoopThreadPool线程池
3. ipPort：ip和port，name:服务名
4. connections_：所有连接的map，nextConnId_：下一个轮询的线程
5. 回调（偏业务的回调）：
    - 新连接回调：connectionCallback_
    - 读写消息回调：messageCallback_
    - 消息发送完成回调：writeCompleteCallback_
    - 线程初始化回调：threadInitCallback_

##### 初始化

```C++
static EventLoop* CheckLoopNotNull(EventLoop *loop)
{
    if (loop == nullptr)
    {
        LOG_FATAL("%s:%s:%d mainLoop is null! \n", __FILE__, __FUNCTION__, __LINE__);
    }
    return loop;
}

TcpServer::TcpServer(EventLoop *loop,
                const InetAddress &listenAddr,   
                const std::string &nameArg,      
                Option option)                          // 端口重用
                : loop_(CheckLoopNotNull(loop))        // 这是把主线程的mainloop
                , ipPort_(listenAddr.toIpPort())        // 绑定ip和端口       
                , name_(nameArg)                          // 设置名称
                , acceptor_(new Acceptor(loop, listenAddr, option == kReusePort))    // 初始化acceptor，监听端口重用
                , threadPool_(new EventLoopThreadPool(loop, name_))      // 线程池初始化
                , connectionCallback_()                    // 连接建立回调
                , messageCallback_()                    // 消息读写回调
                , nextConnId_(1)                        // 下一个轮询的线程
                , started_(0)                                  // 暂未启动
{
    // 为acceptor的新连接事件绑定回调，回调在tcpserver实现
    // 当有先用户连接时，会执行TcpServer::newConnection回调   =》 轮询选择一个subloop，唤醒subloop，将当前connfd封装成channel分发给subloop
    acceptor_->setNewConnectionCallback(std::bind(&TcpServer::newConnection, this, 
        std::placeholders::_1, std::placeholders::_2));
}

TcpServer::~TcpServer()
{
    for (auto &item : connections_)
    {
        // 这个局部的shared_ptr智能指针对象，出右括号，可以自动释放new出来的TcpConnection对象资源了
        TcpConnectionPtr conn(item.second); 
        item.second.reset();

        // 销毁连接
        conn->getLoop()->runInLoop(
            std::bind(&TcpConnection::connectDestroyed, conn)
        );
    }
}
```

##### 服务启动与关闭

启动：
```c++
// 设置底层subloop的个数  =>  传了3
void TcpServer::setThreadNum(int numThreads)
{
    threadPool_->setThreadNum(numThreads); 
}

// 开启服务器监听   loop.loop()
void TcpServer::start()
{
    if (started_++ == 0) // 防止一个TcpServer对象被start多次
    {
        threadPool_->start(threadInitCallback_); // 启动底层的loop线程池,这里的线程回调没初始化，可以在testserver.cpp中初始化
        // get() 返回accpter的原始指针Acceptor*，应该就表示只能由Acceptor对象调用，因为就像listen的第一个参数是this，this绑定死了，以后不用写acceptor_.get().listen()了
        // 启动主线程的mainloop，并开启连接监听
        loop_->runInLoop(std::bind(&Acceptor::listen, acceptor_.get()));
    }
}

```

关闭：

```c++
void TcpServer::removeConnection(const TcpConnectionPtr &conn)
{
    loop_->runInLoop(
        std::bind(&TcpServer::removeConnectionInLoop, this, conn)
    );
}

void TcpServer::removeConnectionInLoop(const TcpConnectionPtr &conn)
{
    LOG_INFO("TcpServer::removeConnectionInLoop [%s] - connection %s\n",
    name_.c_str(), conn->name().c_str());
    
    connections_.erase(conn->name());
    EventLoop *ioLoop = conn->getLoop();
    ioLoop->queueInLoop(
        std::bind(&TcpConnection::connectDestroyed, conn)
)   ;
}
```

##### 连接回调

通过连接成功的socketfd获取绑定的服务器ip和端口信息（tcb）,创建TcpConnection连接对象，然后给这个对象设置连接建立（与关闭）回调、读写消息回调、写入完成回调，然后唤醒子线程，执行connectEstablished回调

注意tcpserver的connectionCallback_回调也是业务上的回调，而connectEstablished是代码逻辑上的回调（connectEstablished最终也会在tcpconnection中调用connectionCallback_）

```c++
// 有一个新的客户端的连接，acceptor会执行这个回调操作
void TcpServer::newConnection(int sockfd, const InetAddress &peerAddr)
{
    // 轮询算法，选择一个subLoop，来管理channel
    EventLoop *ioLoop = threadPool_->getNextLoop(); 
    char buf[64] = {0};
    snprintf(buf, sizeof buf, "-%s#%d", ipPort_.c_str(), nextConnId_);
    ++nextConnId_;
    std::string connName = name_ + buf;

    LOG_INFO("TcpServer::newConnection [%s] - new connection [%s] from %s \n",
        name_.c_str(), connName.c_str(), peerAddr.toIpPort().c_str());

    // 通过sockfd获取其绑定的本机的ip地址和端口信息
    sockaddr_in local;
    ::bzero(&local, sizeof local);
    socklen_t addrlen = sizeof local;
    if (::getsockname(sockfd, (sockaddr*)&local, &addrlen) < 0)
    {
        LOG_ERROR("sockets::getLocalAddr");
    }
    InetAddress localAddr(local);

    // 根据连接成功的sockfd，创建TcpConnection连接对象
    TcpConnectionPtr conn(new TcpConnection(
                            ioLoop,
                            connName,
                            sockfd,   // Socket Channel
                            localAddr,
                            peerAddr));
    connections_[connName] = conn;
    // 下面的回调都是用户设置给TcpServer=>TcpConnection=>Channel=>Poller=>notify channel调用回调
    conn->setConnectionCallback(connectionCallback_);
    conn->setMessageCallback(messageCallback_);
    conn->setWriteCompleteCallback(writeCompleteCallback_);

    // 设置了如何关闭连接的回调   conn->shutDown()
    conn->setCloseCallback(
        std::bind(&TcpServer::removeConnection, this, std::placeholders::_1)
    );

    // 直接调用TcpConnection::connectEstablished，绑定TcpConnection和channel，执行上面绑定的connectionCallback_函数（服务器指定的）
    // 连接建立，读写消息，发送完成事件回调都是服务器传入的
    ioLoop->runInLoop(std::bind(&TcpConnection::connectEstablished, conn));
}
```


#### 编写用例

定义一个回响服务：
- 创建一个loop
- 创建一个回响tcpserver服务对象：
  - 将上面创建的loop作为mainLoop，设置subLoop的数量，
  - 设置对应的连接建立、读写、发送完成回调函数
  - 设置监听的ip和端口
- 运行服务：
  - 创建事件线程池，创建subLoop
  - 开启连接监听
- 运行mainLoop，监听新连接

```c++
class EchoServer
{
public:
    EchoServer(EventLoop *loop,
            const InetAddress &addr, 
            const std::string &name)
        : server_(loop, addr, name)
        , loop_(loop)
    {
        // 注册回调函数
        server_.setConnectionCallback(
            std::bind(&EchoServer::onConnection, this, std::placeholders::_1)
        );

        server_.setMessageCallback(
            std::bind(&EchoServer::onMessage, this,
                std::placeholders::_1, std::placeholders::_2, std::placeholders::_3)
        );

        // 设置合适的loop线程数量 loopthread
        server_.setThreadNum(3);  // EventLoopThreadPool的参数
    }
    void start()
    {
        server_.start();
    }
private:
    // 连接建立或者断开的回调
    void onConnection(const TcpConnectionPtr &conn)
    {
        if (conn->connected())
        {
            LOG_INFO("Connection UP : %s", conn->peerAddress().toIpPort().c_str());
        }
        else
        {
            LOG_INFO("Connection DOWN : %s", conn->peerAddress().toIpPort().c_str());
        }
    }

    // 可读写事件回调
    void onMessage(const TcpConnectionPtr &conn,
                Buffer *buf,
                Timestamp time)
    {
        std::string msg = buf->retrieveAllAsString();
        conn->send(msg);
        conn->shutdown(); // 写端   EPOLLHUP =》 closeCallback_
    }

    EventLoop *loop_;
    TcpServer server_;
};

int main()
{
    EventLoop loop;    // 调用EventLoop的构造函数
    InetAddress addr(8000);
    EchoServer server(&loop, addr, "EchoServer-01"); // Acceptor non-blocking listenfd  create bind 
    server.start(); // listen  loopthread  listenfd => acceptChannel => mainLoop =>
    loop.loop(); // 启动mainLoop的底层Poller

    return 0;
}
```