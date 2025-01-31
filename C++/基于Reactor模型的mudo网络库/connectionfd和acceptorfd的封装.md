# acceptorChannel��connectionChannel��ʵ��

connectionChannel��acceptorChannel�ڶ������һ��Channel

## acceptorChannel

acceptorChannel������Channelһ����������¼��ͻص��󶨣������뵽baseEventLoop,
��������acceptor�������ǽ������Ӽ�����ֻ��Ҫ���ÿɶ��¼����ɣ��ɶ��¼������󣬽��µ����Ӽ��뵽subEventLoop,����Ҫ��ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250103100841.png" alt="20250103100841" width="850">

### acceptorChannel����

����acceptor����ʱ�����̻߳ᴴ��һ�����������׽���listenSocket����Ȼ���̻߳���������Ȼ��listenfd���¼��ͻص���װ��Channel��
�������Channl���뵽baseEventLoop

����״̬Ĭ��Ϊfalse��������TCPServer���������󣬲ſ�ʼ����

```c++
static int createNonblocking()
{
    // SOCK_NONBLOCK������
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

### ������ص�

����listenfd�Ŀɶ������¼�����baseEventLoop�У����ɶ��¼�����ʱ���������ӽ����ص�������ص��������̷ַ߳����ԣ�
Ҳ����subEventLoop��ѡ����ԣ����ϲ�TCPServer������

```c++
void Acceptor::listen()
{
    listenning_ = true;
    acceptSocket_.listen(); // listen
    acceptChannel_.enableReading(); // ע����¼�
}

// listenfd���¼������ˣ����������û�������
void Acceptor::handleRead()
{
    InetAddress peerAddr;
    int connfd = acceptSocket_.accept(&peerAddr);   // fd���ܱ�����  =�� ��Ⱥ �� ���fd����
    if (connfd >= 0)
    {
        if (newConnectionCallback_)
        {
            // ��ѯ�ҵ�subLoop�����ѣ��ַ���ǰ���¿ͻ��˵�Channel(�����ӻص���tcpserver������)
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

connectionChannelҲ������listenfd�������¼��󣬲��ɹ���������ͻ��˵����Ӻ������channel����Ҫ����һЩҵ���߼���

����Ҫ��ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250103111520.png" alt="20250103111520" width="850">

���߳̽��յ�һ�������Ӻ󣬽�socket_��װ��channel���ַ���subEventLoop,����ڵ��߳�ģʽ�£��ͷַ���baseEventLoop��

- name_:�ɿͻ��˵�ip��port���ɣ���ʶһ�����ӣ�TCPServer�ڹ���connectionChannelʱ����ͨ��name_���п��ٲ���
- state_:����״̬��Ҫ����δ���ӡ������С������ӡ��ѶϿ���һЩ����ֻ�����ض�������״̬����


### ����ص�
- �����ӻص�connectionCallback_���������Ӳ���ʱ���ã��磺��ӡ������Ϣ��
- ��д��Ϣ�ص�messageCallback_����connectionfd���ж�д�¼�ʱ����
- �������ƻص�highWaterMarkCallback_�����û�̬������������������һ����ʱ�������磺���߳����߼��룩

### ����������
- ���ݽ��ջ�����inputBuffer����fd�����ɶ��¼�ʱ����������������յ�һ��rpc�����������󣬴�ʱ��������fd�Ŀɶ��¼��ص�����ȡ�������󣬲�������Ӧ

��ʵ���߼�Ϊ��

```c++
void TcpConnection::handleRead(Timestamp receiveTime)
{
    int savedErrno = 0;
    ssize_t n = inputBuffer_.readFd(channel_->fd(), &savedErrno);
    if (n > 0)
    {
        // �ѽ������ӵ��û����пɶ��¼������ˣ������û�����Ļص�����onMessage
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

messageCallback_��ʵ��ȡ����TCPServerҪʵ�ֵĹ��ܣ���rpc���÷�������echo����������������߼����£�

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

    // �ɶ�д�¼��ص�
    void onMessage(const TcpConnectionPtr &conn,
                Buffer *buf,
                Timestamp time)
    {
        std::string msg = buf->retrieveAllAsString();
        conn->send(msg);
        conn->shutdown(); // д��   EPOLLHUP =�� closeCallback_
    }
```

- ���ݷ��ͻ�����outputBuffer����fd������д�¼�ʱ���������������һ���Է�����ɣ�ʣ������ݻỺ�浽�û�̬���ͻ�������
�����ʱ�������ﵽһ������������������ƣ����������������㣬�����л��������ݣ�

���ݷ������̣�  =>  markdown����ͼ��
```c++
void TcpConnection::sendInLoop(const void* data, size_t len)
{
    ssize_t nwrote = 0;
    size_t remaining = len;
    bool faultError = false;

    // ֮ǰ���ù���connection��shutdown�������ٽ��з�����
    if (state_ == kDisconnected)
    {
        LOG_ERROR("disconnected, give up writing!");
        return;
    }

    // ��ʾchannel_��һ�ο�ʼд���ݣ����һ�����û�д���������
    if (!channel_->isWriting() && outputBuffer_.readableBytes() == 0) 
    {
        // �ȳ���һ���Է��ͳ�ȥ
        nwrote = ::write(channel_->fd(), data, len); 
        if (nwrote >= 0)       // ���ͳɹ���
        {
            remaining = len - nwrote;    // δ���ͳ�ȥ��
            if (remaining == 0 && writeCompleteCallback_)    // ���������ɣ����÷�����ɻص�
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
    // ˵����ǰ��һ��write����û�а�����ȫ�����ͳ�ȥ��ʣ���������Ҫ���浽����������
    // ע��epollout�¼���poller����tcp�ķ��ͻ������пռ䣬����TcpConnection::handleWrite�������ѷ��ͻ������е�����ȫ���������
    if (!faultError && remaining > 0) 
    {
        // Ŀǰ���ͻ�����ʣ��Ĵ��������ݵĳ���
        size_t oldLen = outputBuffer_.readableBytes();
        if (oldLen + remaining >= highWaterMark_
            && oldLen < highWaterMark_   
            && highWaterMarkCallback_)    // ������������
        {
            loop_->queueInLoop(
                std::bind(highWaterMarkCallback_, shared_from_this(), oldLen+remaining)   // ���������߼��벻��������
            );
        }
        outputBuffer_.append((char*)data + nwrote, remaining);
        if (!channel_->isWriting())
        {
            channel_->enableWriting(); // ����Ҫע��channel��д�¼�
        }
    }
}
```

�������һ���޷�������ɣ���ע��pollerд�¼�����buffer�ϵ����ݷ��͵��ںˣ�ע�⣬�����ͨ��д�¼��ص��������ݷ��͵ģ�һ���Ƿ��ͻ����������ݣ�
sendInLoop()һ�㲻ͨ��epoll����������ҵ���߼����Ƶģ�����poller�������ɶ��¼��󣬶�������д���󣬵���channel��sendInLoop()�������ݡ�

���Կ�д�¼��Ļص��߼�Ϊ��

��buffer�ϵ�����д���ںˣ�������ɺ�channel�Ŀ�д�¼�ȡ���������÷�����ɻص�

```c++
void TcpConnection::handleWrite()
{
    if (channel_->isWriting())
    {
        int savedErrno = 0;
        // дfdʱ����buffer�ϵ�����д���ں�
        ssize_t n = outputBuffer_.writeFd(channel_->fd(), &savedErrno);
        if (n > 0)
        {
            outputBuffer_.retrieve(n);
            if (outputBuffer_.readableBytes() == 0)   
            {
                channel_->disableWriting();    // ȡ��channel�Ŀ�д�¼��ص�
                if (writeCompleteCallback_)    // ������ɻص�
                {
                    // ����loop_��Ӧ��thread�̣߳�ִ�лص�
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