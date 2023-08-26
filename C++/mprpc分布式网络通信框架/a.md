# mprpc设计

业界有不少优秀的rpc框架,如百度的brpc、谷歌的grpc,本项目基于muduo高性能网络库（epoll+线程池）和Protobuf开发，命名为mprpc，另外用zk作为服务注册中心

- muduo:网络通信
- Protobuf:数据序列化（也可采用json）

主要技术栈：

- RPC远程过程调用原理和实现
- Protobuf数据序列化和反序列化协议
- Zookeeper分布式一致性协调服务以及应用
- mudo网络编程
- CMake构建项目集成编译环境

## 集群与分布式

集群：每一台服务器独立运行一个工程的所有模块。

分布式：一个工程拆分了很多模块，每一个模块独立部署运行在一个服务器主机上，所有服务器协同工
作共同提供服务，每一台服务器称作分布式的一个节点，根据节点的并发要求，对一个节点可以再做节
点模块集群部署。

现在有一个聊天系统，部署在单机上，有如下功能：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202308072227704.png" alt="202308072227704" width="450px">

单机服务器存在如下缺点：

1. 在请求并发量比较大时，受限于硬件资源，一台服务器处理不过来
2. 一个模块出现问题，该模块只需要修改一个参数就可以修复，但是整个项目单元里的模块都需要编译部署
3. 有些模块时IO密集型（需要带宽），有些时CPU密集型（需要内存大，核数多）的，各模块对硬件的资源需求不一样

通过集群，可解决缺点1：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202308072235779.png" alt="202308072235779" width="450px">

通过服务进行分布式节点部署，可解决缺点2和3：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202308082222923.png" alt="202308082222923" width="450px">

部分服务节点请求量很大，也可以通过部署集群来解决，同时，也可以将一些请求量比较大的服务部署到请求量小的服务器节点（如用户管理服务部署到server2），以充分利用服务器资源：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202308082225205.png" alt="202308082225205" width="450px">

此外，服务器一般都会配置容灾，至少会配一个主备，一个集群节点挂了，会启动备节点进行服务

但是，分布式节点之间的服务怎么进行通信是个问题，如，用户管理模块想知道本用户有哪些好友，则需要向server2请求

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202308082235858.png" alt="202308082235858" width="450px">

## RPC通信原理

RPC（Remote Procedure Call Protocol）远程过程调用协议

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202308082238459.png" alt="202308082238459" width="450px">

- local call: 如server1调用GetUserFriendLists,但是这个方法是个远程方法，server1需要通过注册中心（如zk）才能知道这个方法在哪个服务节点上
- pack_argument: 当server1知道请求的函数在server2后，需要将调用的函数、参数打包（序列化）通过网络传递给server2，
- 打包好数据后，就需要将包体的字节流通过网络（mudo网络库）传输到请求服务器了


mprpc框架主要包含两个部分的内容：

黄色部分：stub,设计rpc方法参数的打包和解析，也就是数据的序列化和反序列化，使用Protobuf。
- protobuf二进制存储，xml和json都是文本存储，相较而言比较省空间
- json的数据 =>  name:"zhang san",pwd:"12345" protobuf不需要存储name、pwd等键信息，因为服务节点2知道服务节点1发送包体的数据结构。

绿色部分：网络部分，包括寻找rpc服务主机，发起rpc调用请求和响应rpc调用结果，使用muduo网络库和zookeeper服务配置中心（专门做服务发现）。

