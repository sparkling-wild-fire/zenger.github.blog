# rpcProvider实现

rpc框架中，分为被调用方callee和调用方caller，一台服务器既可以是caller也可以是calee,而rpcProvider对象，是用于作为callee角色的

其主要成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250105161919.png" alt="20250105161919" width="850">

其中，ServiceInfo定义如下：
```c++
// service服务类型信息
struct ServiceInfo
{
    google::protobuf::Service *m_service; // 保存服务对象
    std::unordered_map<std::string, const google::protobuf::MethodDescriptor*> m_methodMap; // 保存服务方法
};
```


## rpcProvider启动与服务注册

首先rpcProvider需要借用TCPServer进行请求的接收，因此需要先运行TCPServer提供rpc网络调用服务

此外，callee通过创建zkNode注册服务,先将protobuf定义的服务和方法进行统一管理，然后注册到zk

```c++
// 这里是框架提供给外部使用的，可以发布rpc方法的函数接口
void RpcProvider::NotifyService(google::protobuf::Service *service)
{
    ServiceInfo service_info;
    // 获取了服务对象的描述信息
    const google::protobuf::ServiceDescriptor *pserviceDesc = service->GetDescriptor();
    // 获取服务的名字
    std::string service_name = pserviceDesc->name();
    // 获取服务对象service的方法的数量
    int methodCnt = pserviceDesc->method_count();
    // std::cout << "service_name:" << service_name << std::endl;
    LOG_INFO("service_name:%s", service_name.c_str());
    for (int i=0; i < methodCnt; ++i)
    {
        // 获取了服务对象指定下标的服务方法的描述（抽象描述） UserService   Login
        const google::protobuf::MethodDescriptor* pmethodDesc = pserviceDesc->method(i);
        std::string method_name = pmethodDesc->name();
        service_info.m_methodMap.insert({method_name, pmethodDesc});

        LOG_INFO("method_name:%s", method_name.c_str());
    }
    service_info.m_service = service;
    m_serviceMap.insert({service_name, service_info});
}
```

运行rpc服务器，启动TCPServer,设置回调（核心的是消息读写回调）,将服务注册到zk,其中serverName注册为永久性节点，防止节点下线后，其他节点注册了这个目录，而method注册为临时节点，
以确保节点下线后，caller就无法发现服务了

```c++
// 启动rpc服务节点，开始提供rpc远程网络调用服务
void RpcProvider::Run()
{
    // 1. 读取配置文件rpcserver的信息
    std::string ip = MprpcApplication::GetInstance().GetConfig().Load("rpcserverip");
    uint16_t port = atoi(MprpcApplication::GetInstance().GetConfig().Load("rpcserverport").c_str());
    muduo::net::InetAddress address(ip, port);

    // 2. 创建TcpServer对象
    muduo::net::TcpServer server(&m_eventLoop, address, "RpcProvider");
    // 绑定连接回调和消息读写回调方法  分离了网络代码和业务代码
    server.setConnectionCallback(std::bind(&RpcProvider::OnConnection, this, std::placeholders::_1));
    server.setMessageCallback(std::bind(&RpcProvider::OnMessage, this, std::placeholders::_1, 
            std::placeholders::_2, std::placeholders::_3));
    // 设置muduo库的线程数量
    server.setThreadNum(4);

    // 3. 把当前rpc节点上要发布的服务全部注册到zk上面，让rpc client可以从zk上发现服务
    // session timeout   30s     zkclient 网络I/O线程  1/3 * timeout 时间发送ping消息
    ZkClient zkCli;
    zkCli.Start();
    // service_name为永久性节点，method_name为临时性节点
    for (auto &sp : m_serviceMap) 
    {
        // /service_name   /UserServiceRpc
        std::string service_path = "/" + sp.first;
        zkCli.Create(service_path.c_str(), nullptr, 0);    // 创建service
        for (auto &mp : sp.second.m_methodMap)
        {
            // /service_name/method_name   /UserServiceRpc/Login 存储当前这个rpc服务节点主机的ip和port
            std::string method_path = service_path + "/" + mp.first;
            char method_path_data[128] = {0};
            sprintf(method_path_data, "%s:%d", ip.c_str(), port);
            // ZOO_EPHEMERAL表示znode是一个临时性节点
            zkCli.Create(method_path.c_str(), method_path_data, strlen(method_path_data), ZOO_EPHEMERAL);
        }
    }

    // rpc服务端准备启动，打印信息
    std::cout << "RpcProvider start service at ip:" << ip << " port:" << port << std::endl;
    // 4. 启动网络服务
    server.start();
    m_eventLoop.loop(); 
}
```

### rpcProvider消息处理

当caller的请求到达caller后，将触发这个连接的可读事件，执行消息读写回调

```c++
// 已建立连接用户的读写事件回调 如果远程有一个rpc服务的调用请求，那么OnMessage方法就会响应
void RpcProvider::OnMessage(const muduo::net::TcpConnectionPtr &conn, 
                            muduo::net::Buffer *buffer, 
                            muduo::Timestamp)
{
    // 1. 网络上接收的远程rpc调用请求的字符流,解析成serverName、methodName、args
    std::string recv_buf = buffer->retrieveAllAsString();
    // ...
    service_name = rpcHeader.service_name();
    method_name = rpcHeader.method_name();
    args_size = rpcHeader.args_size();
    std::string args_str = recv_buf.substr(4 + header_size, args_size);
    // 2. 获取service对象和method对象
    auto it = m_serviceMap.find(service_name);
    auto mit = it->second.m_methodMap.find(method_name);
    google::protobuf::Service *service = it->second.m_service; // 获取service对象  new UserService
    const google::protobuf::MethodDescriptor *method = mit->second; // 获取method对象  Login

    // 3. 生成rpc方法调用的请求request和响应response参数
    google::protobuf::Message *request = service->GetRequestPrototype(method).New();
    google::protobuf::Message *response = service->GetResponsePrototype(method).New();

    // 4. 绑定一个Closure的回调函数SendRpcResponse
    google::protobuf::Closure *done = google::protobuf::NewCallback<RpcProvider, 
                                                                    const muduo::net::TcpConnectionPtr&, 
                                                                    google::protobuf::Message*>
                                                                    (this, 
                                                                    &RpcProvider::SendRpcResponse, 
                                                                    conn, response);

    // 5. 在框架上根据远端rpc请求，调用当前rpc节点上发布的方法
    service->CallMethod(method, nullptr, request, response, done);
}
```

在方法调用完成后，将响应通过Closure回调序列化后发送回去，并断开连接

```c++
// Closure的回调操作，用于序列化rpc的响应和网络发送
void RpcProvider::SendRpcResponse(const muduo::net::TcpConnectionPtr& conn, google::protobuf::Message *response)
{
    std::string response_str;
    if (response->SerializeToString(&response_str)) // response进行序列化
    {
        // 序列化成功后，通过网络把rpc方法执行的结果发送会rpc的调用方
        conn->send(response_str);
    }
    conn->shutdown(); // 模拟http的短链接服务，由rpcprovider主动断开连接
}
```




