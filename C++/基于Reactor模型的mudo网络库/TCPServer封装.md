# TCPServer��װ

����֮ǰ�����������ʵ�֣�TCPServer������ܹ�ͼΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250104192928.png" alt="20250104192928" width="850">

## TCPServer

TCPServer����Ҫ��ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250104185034.png" alt="20250104185034" width="850">

TCPServer��Ҫ�����þ��ǽ��������������������γ�һ���걸�ķ��������������̳߳��߳���������ʼ���������������̳߳غͿ������Ӽ������������ӵ�

TCPServer�Ķ���Ĺ�����ǳ�ʼ��������Ա������start_���������̳߳غ�BaseEventLoop�Ƿ�����

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

// ��������������
void TcpServer::start()
{
    if (started_++ == 0) // ��ֹһ��TcpServer����start���
    {
        threadPool_->start(threadInitCallback_); // �����ײ��loop�̳߳�,������̻߳ص�û��ʼ��
        // get() ����accpter��ԭʼָ��Acceptor*
        loop_->runInLoop(std::bind(&Acceptor::listen, acceptor_.get()));
    }
}
```

����ĵľ���ʵ�ּ����������ӽ�����Ļص�ʵ��,����ʵ��Ҳ����channel�ķַ�����

��acceptro���������Ӻ󣬴���connectionChanel,���ûص�(��ͬ��TCPServer�в�ͬ��ʵ��)�Ϳɶ��¼���������뵽��Ӧ��epoller��

```c++
// ��һ���µĿͻ��˵����ӣ�acceptor��ִ������ص�����
void TcpServer::newConnection(int sockfd, const InetAddress &peerAddr)
{
    // ��ѯ�㷨��ѡ��һ��subLoop��������channel
    EventLoop *ioLoop = threadPool_->getNextLoop(); 
    char buf[64] = {0};
    snprintf(buf, sizeof buf, "-%s#%d", ipPort_.c_str(), nextConnId_);
    ++nextConnId_;
    std::string connName = name_ + buf;

    LOG_INFO("TcpServer::newConnection [%s] - new connection [%s] from %s \n",
        name_.c_str(), connName.c_str(), peerAddr.toIpPort().c_str());

    // ͨ��sockfd��ȡ��󶨵ı�����ip��ַ�Ͷ˿���Ϣ
    sockaddr_in local;
    ::bzero(&local, sizeof local);
    socklen_t addrlen = sizeof local;
    if (::getsockname(sockfd, (sockaddr*)&local, &addrlen) < 0)
    {
        LOG_ERROR("sockets::getLocalAddr");
    }
    InetAddress localAddr(local);

    // �������ӳɹ���sockfd������TcpConnection���Ӷ���
    TcpConnectionPtr conn(new TcpConnection(
                            ioLoop,
                            connName,
                            sockfd,   // Socket Channel
                            localAddr,
                            peerAddr));
    connections_[connName] = conn;
    // ����Ļص������û����ø�TcpServer=>TcpConnection=>Channel=>Poller=>notify channel���ûص�
    conn->setConnectionCallback(connectionCallback_);
    conn->setMessageCallback(messageCallback_);
    conn->setWriteCompleteCallback(writeCompleteCallback_);

    // ��������ιر����ӵĻص�   conn->shutDown()
    conn->setCloseCallback(
        std::bind(&TcpServer::removeConnection, this, std::placeholders::_1)
    );

    // ֱ�ӵ���TcpConnection::connectEstablished
    ioLoop->runInLoop(std::bind(&TcpConnection::connectEstablished, conn));
}
```

