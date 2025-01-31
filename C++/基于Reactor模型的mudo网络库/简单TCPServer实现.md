# ��TCPServerʵ��

����TCPServerʵ��һ���򵥵Ļ��������EchoServer��Ҳ���Ƿ������յ�ʲô��Ϣ�򷵻�ʲô��Ϣ

����Ҫ�ṩ����Ĳ������̳߳����������ӻص�����д�¼��ص�

����ʵ�֣�

```c++
class EchoServer
{
public:
    EchoServer(EventLoop *loop,
            const InetAddress &addr, 
            const std::string &name)
        , loop_(loop){
        // ע��ص�����
        server_.setConnectionCallback(
            std::bind(&EchoServer::onConnection, this, std::placeholders::_1)
        );
        server_.setMessageCallback(
            std::bind(&EchoServer::onMessage, this,
                std::placeholders::_1, std::placeholders::_2, std::placeholders::_3)
        );
        // ���ú��ʵ�loop�߳����� loopthread
        server_.setThreadNum(3);  // EventLoopThreadPool�Ĳ���
    }
    void start()
    {
        server_.start();
    }
private:
    // ���ӽ������߶Ͽ��Ļص�
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
    EventLoop *loop_;
    TcpServer server_;
};
```


EchoServer��������

```c++
int main()
{
    EventLoop loop;    // ����EventLoop�Ĺ��캯��
    InetAddress addr(8000);
    EchoServer server(&loop, addr, "EchoServer-01"); // Acceptor non-blocking listenfd  create bind 
    server.start(); // listen  loopthread  listenfd => acceptChannel => mainLoop =>
    loop.loop(); // ����mainLoop�ĵײ�Poller

    return 0;
}
```