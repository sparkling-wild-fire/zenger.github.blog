# TCPServer封装

有了之前各对象的完整实现，TCPServer的整体架构图为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250104192928.png" alt="20250104192928" width="850">

## TCPServer

TCPServer的主要成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250104185034.png" alt="20250104185034" width="850">

TCPServer主要的作用就是将各个对象整合起来，形成一个完备的服务器，如设置线程池线程数量、初始化各个对象、启动线程池和开启连接监听、管理连接等

TCPServer的对象的构造就是初始化上述成员，其中start_用来控制线程池和BaseEventLoop是否启动

```c++
TcpServer::TcpServer(EventLoop *loop,
                const InetAddress &listenAddr,
                const std::string &nameArg,
                Option option)
                : loop_(CheckLoopNotNull(loop))
                , ipPort_(listenAddr.toIpPort())
                , name_(nameArg)
                , acceptor_(new Acceptor(loop, listenAddr, option == kReusePort))
                , threadPool_(new EventLoopThreadPool(loop, name_))
                , connectionCallback_()
                , messageCallback_()
                , nextConnId_(1)
                , started_(0)
{
    acceptor_->setNewConnectionCallback(std::bind(&TcpServer::newConnection, this, 
        std::placeholders::_1, std::placeholders::_2));
}

// 开启服务器监听
void TcpServer::start()
{
    if (started_++ == 0) // 防止一个TcpServer对象被start多次
    {
        threadPool_->start(threadInitCallback_); // 启动底层的loop线程池,这里的线程回调没初始化
        // get() 返回accpter的原始指针Acceptor*
        loop_->runInLoop(std::bind(&Acceptor::listen, acceptor_.get()));
    }
}
```

最核心的就是实现监听到新连接建立后的回调实现,它的实现也就是channel的分发策略

当acceptro监听到连接后，创建connectionChanel,设置回调(不同的TCPServer有不同的实现)和可读事件，将其加入到对应的epoller中

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

    // 直接调用TcpConnection::connectEstablished
    ioLoop->runInLoop(std::bind(&TcpConnection::connectEstablished, conn));
}
```

