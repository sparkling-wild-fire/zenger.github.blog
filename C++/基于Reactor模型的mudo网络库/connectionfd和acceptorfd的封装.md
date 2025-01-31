# acceptorChannel和connectionChannel的实现

connectionChannel和acceptorChannel内都组合了一个Channel

## acceptorChannel

acceptorChannel和其他Channel一样，会进行事件和回调绑定，并加入到baseEventLoop,
但是由于acceptor的作用是进行连接监听，只需要设置可读事件即可，可读事件触发后，将新的连接加入到subEventLoop,其主要成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250103100841.png" alt="20250103100841" width="850">

### acceptorChannel构造

创建acceptor对象时，主线程会创建一个非阻塞的套接字listenSocket（不然主线程会阻塞），然后将listenfd绑定事件和回调封装成Channel，
并将这个Channl插入到baseEventLoop

监听状态默认为false，当整个TCPServer服务启动后，才开始监听

```c++
static int createNonblocking()
{
    // SOCK_NONBLOCK非阻塞
    int sockfd = ::socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK | SOCK_CLOEXEC, 0);
    if (sockfd < 0) 
    {
        LOG_FATAL("%s:%s:%d listen socket create err:%d \n", __FILE__, __FUNCTION__, __LINE__, errno);  
    }
}

Acceptor::Acceptor(EventLoop *loop, const InetAddress &listenAddr, bool reuseport)
    : loop_(loop)
    , acceptSocket_(createNonblocking()) // socket
    , acceptChannel_(loop, acceptSocket_.fd())
    , listenning_(false)
{
    acceptSocket_.setReuseAddr(true);
    acceptSocket_.setReusePort(true);
    acceptSocket_.bindAddress(listenAddr); // bind
    // TcpServer::start() Acceptor.listen
    acceptChannel_.setReadCallback(std::bind(&Acceptor::handleRead, this));
}
```

### 监听与回调

开启listenfd的可读监听事件存入baseEventLoop中，当可读事件触发时，调用连接建立回调，这个回调决定了线程分发策略，
也就是subEventLoop的选择策略，在上层TCPServer中设置

```c++
void Acceptor::listen()
{
    listenning_ = true;
    acceptSocket_.listen(); // listen
    acceptChannel_.enableReading(); // 注册读事件
}

// listenfd有事件发生了，就是有新用户连接了
void Acceptor::handleRead()
{
    InetAddress peerAddr;
    int connfd = acceptSocket_.accept(&peerAddr);   // fd可能被用完  =》 集群 、 提高fd数量
    if (connfd >= 0)
    {
        if (newConnectionCallback_)
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

## connectionChannel

connectionChannel也就是在listenfd监听到事件后，并成功建立了与客户端的连接后产生的channel，需要处理一些业务逻辑。

其主要成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250103111520.png" alt="20250103111520" width="850">

主线程接收到一个新连接后，将socket_封装成channel，分发到subEventLoop,如果在单线程模式下，就分发到baseEventLoop，

- name_:由客户端的ip和port构成，标识一个连接，TCPServer在管理connectionChannel时，可通过name_进行快速查找
- state_:连接状态主要包括未连接、连接中、已连接、已断开，一些动作只能在特定的连接状态进行


### 三大回调
- 新连接回调connectionCallback_：当新连接产生时调用（如：打印连接信息）
- 读写消息回调messageCallback_：当connectionfd上有读写事件时触发
- 流量控制回调highWaterMarkCallback_：当用户态缓冲区的数据量到达一定量时触发（如：让线程休眠几秒）

### 两个缓冲区
- 数据接收缓冲区inputBuffer：当fd发生可读事件时触发，如服务器接收到一个rpc函数调用请求，此时，将触发fd的可读事件回调，读取调用请求，并发送响应

其实现逻辑为：

```c++
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

messageCallback_的实现取决于TCPServer要实现的功能，如rpc调用服务器，echo回响服务器（代码逻辑如下）

```c++
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
```

- 数据发送缓冲区outputBuffer：当fd发生可写事件时，如果数据量不能一次性发送完成，剩余的数据会缓存到用户态发送缓冲区，
如果此时数据量达到一定量，会进行流量控制；若缓冲区容量不足，则会进行缓冲区扩容；

数据发送流程：  =>  markdown流程图？
```c++
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

    // 表示channel_第一次开始写数据，而且缓冲区没有待发送数据
    if (!channel_->isWriting() && outputBuffer_.readableBytes() == 0) 
    {
        // 先尝试一次性发送出去
        nwrote = ::write(channel_->fd(), data, len); 
        if (nwrote >= 0)       // 发送成功了
        {
            remaining = len - nwrote;    // 未发送出去的
            if (remaining == 0 && writeCompleteCallback_)    // 如果发送完成，调用发送完成回调
            {
                loop_->queueInLoop(
                    std::bind(writeCompleteCallback_, shared_from_this())
                );
            }
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
    // 说明当前这一次write，并没有把数据全部发送出去，剩余的数据需要保存到缓冲区当中
    // 注册epollout事件，poller发现tcp的发送缓冲区有空间，调用TcpConnection::handleWrite方法，把发送缓冲区中的数据全部发送完成
    if (!faultError && remaining > 0) 
    {
        // 目前发送缓冲区剩余的待发送数据的长度
        size_t oldLen = outputBuffer_.readableBytes();
        if (oldLen + remaining >= highWaterMark_
            && oldLen < highWaterMark_   
            && highWaterMarkCallback_)    // 流量控制条件
        {
            loop_->queueInLoop(
                std::bind(highWaterMarkCallback_, shared_from_this(), oldLen+remaining)   // 比如让休眠几秒不发送数据
            );
        }
        outputBuffer_.append((char*)data + nwrote, remaining);
        if (!channel_->isWriting())
        {
            channel_->enableWriting(); // 这里要注册channel的写事件
        }
    }
}
```

如果数据一次无法发送完成，则注册poller写事件，将buffer上的数据发送到内核，注意，如果是通过写事件回调触发数据发送的，一定是发送缓冲区的数据，
sendInLoop()一般不通过epoll触发，而是业务逻辑控制的，比如poller监听到可读事件后，对请求进行处理后，调用channel的sendInLoop()发送数据。

所以可写事件的回调逻辑为：

将buffer上的数据写入内核，发送完成后将channel的可写事件取消，并调用发送完成回调

```c++
void TcpConnection::handleWrite()
{
    if (channel_->isWriting())
    {
        int savedErrno = 0;
        // 写fd时，将buffer上的数据写到内核
        ssize_t n = outputBuffer_.writeFd(channel_->fd(), &savedErrno);
        if (n > 0)
        {
            outputBuffer_.retrieve(n);
            if (outputBuffer_.readableBytes() == 0)   
            {
                channel_->disableWriting();    // 取消channel的可写事件回调
                if (writeCompleteCallback_)    // 发送完成回调
                {
                    // 唤醒loop_对应的thread线程，执行回调
                    loop_->queueInLoop(
                        std::bind(writeCompleteCallback_, shared_from_this())
                    );
                }
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
```