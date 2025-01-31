# Socket封装

socket是对fd的封装，主要包括以下方法：

1. `ip+port`绑定

其中sockaddr_in是一个底层的网络地址类，包括ip和端口

`bind(sockfd_, (sockaddr*)localaddr.getSockAddr(), sizeof(sockaddr_in))`

2. 连接监听

`listen(sockfd_, 1024)`

3. 创建connectionfd并返回

对返回的connfd需要设置非阻塞，即采用多路复用+非阻塞IO的模式（poller + non-blocking IO）

为什么多路复用要结合非阻塞IO: 虽然多路复用已经通知线程fd是否可读可写了，但是在从内核态将数据拷贝到用户态的过程中，还是可能发生阻塞。

accept4函数：
1. sockfd 是要接收连接请求的监听套接字的文件描述符；addr 和 addrlen分别是指向存储客户端地址的结构体和结构体大小的指针；flags 是一个用于设置标志位的整数。
2. accept4函数的第一个参数addr是用来存储接受到的客户端地址信息的。它是一个指向sockaddr结构体的指针，该结构体用于存储网络地址信息，包括IP地址和端口号等。
3. 在调用accept4函数之前，我们需要先创建一个套接字，并将其绑定到一个本地地址上。当客户端连接到服务器时，accept4函数会接受这个连接，并将客户端的地址信息存储到addr参数所指向的内存中。

客户端地址怎么传入的呢？这个函数什么时候被调用的？

```c++
int Socket::accept(InetAddress *peeraddr)
{
    sockaddr_in addr;  
    socklen_t len = sizeof addr;
    bzero(&addr, sizeof addr);   // 将地址清0

    int connfd = ::accept4(sockfd_, (sockaddr*)&addr, &len, SOCK_NONBLOCK | SOCK_CLOEXEC);
    if (connfd >= 0)
    {
        peeraddr->setSockAddr(addr);   // 通过入参把客户端地址返回回去
    }
    return connfd;   // 把fd返回回去
}
```

4. 关闭读端或写端

控制fd是否允许发送或接受数据

`shutdown(sockfd_, SHUT_WR)`

5. 其他属性设置

如fd读写超时时间、端口重用等

`setsockopt(sockfd_, SOL_SOCKET, SO_REUSEPORT, &optval, sizeof optval)`
