# 简单TCPServer实现

利用TCPServer实现一个简单的回响服务器EchoServer，也就是服务器收到什么消息则返回什么消息

其需要提供具体的参数：线程池数量、连接回调、读写事件回调

具体实现：

```c++
class EchoServer
{
public:
    EchoServer(EventLoop *loop,
            const InetAddress &addr, 
            const std::string &name)
        , loop_(loop){
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
```


EchoServer的启动：

```c++
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