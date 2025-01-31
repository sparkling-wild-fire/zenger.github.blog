# rpc请求发送

grpc通过rpcChannel的CallMethod方法进行rpc调用，因此基于rpcChannel创建MpRpcChannel,并重写CallMethod方法

```c++
// 所有通过stub代理对象调用的rpc方法，都走到这里了，统一做rpc方法调用的数据数据序列化和网络发送 
void MprpcChannel::CallMethod(const google::protobuf::MethodDescriptor* method,
                                google::protobuf::RpcController* controller, 
                                const google::protobuf::Message* request,
                                google::protobuf::Message* response,
                                google::protobuf:: Closure* done)
{
    // 1. 序列化请求
    const google::protobuf::ServiceDescriptor* sd = method->service();
    std::string service_name = sd->name(); // service_name
    std::string method_name = method->name(); // method_name

    // 定义rpc的请求header: service_name + method_name + args_size + args_str
    mprpc::RpcHeader rpcHeader;
    rpcHeader.set_service_name(service_name);
    rpcHeader.set_method_name(method_name);
    rpcHeader.set_args_size(args_size);
    // ...
    send_rpc_str += args_str; // args
    
    // 2. 连接zk,发送服务
    ZkClient zkCli;
    zkCli.Start();
    //  /UserServiceRpc/Login
    std::string method_path = "/" + service_name + "/" + method_name;
    // 127.0.0.1:8000
    std::string host_data = zkCli.GetData(method_path.c_str());
    int idx = host_data.find(":");
    
    // 3. tcp编程，连接caller
    int clientfd = socket(AF_INET, SOCK_STREAM, 0);  // ipv4,tcp协议族，默认阻塞
    std::string ip = host_data.substr(0, idx);
    uint16_t port = atoi(host_data.substr(idx+1, host_data.size()-idx).c_str());
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    server_addr.sin_addr.s_addr = inet_addr(ip.c_str());
    if (-1 == connect(clientfd, (struct sockaddr*)&server_addr, sizeof(server_addr)))
    {
        return;
    }

    // 4. 连接rpc服务节点，发送请求
    if (-1 == send(clientfd, send_rpc_str.c_str(), send_rpc_str.size(), 0))
    {
        return;
    }
    // 5. 接收rpc请求的响应值
    char recv_buf[1024] = {0};
    int recv_size = 0;
    if (-1 == (recv_size = recv(clientfd, recv_buf, 1024, 0)))
    {
        return;
    }

    // 6. 反序列化rpc调用的响应数据
    if (!response->ParseFromArray(recv_buf, recv_size))
    {
        return;
    }
    // 7. 关闭连接
    close(clientfd);
}
```