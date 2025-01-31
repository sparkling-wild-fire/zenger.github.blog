# rpcProviderʵ��

rpc����У���Ϊ�����÷�callee�͵��÷�caller��һ̨�������ȿ�����callerҲ������calee,��rpcProvider������������Ϊcallee��ɫ��

����Ҫ��ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250105161919.png" alt="20250105161919" width="850">

���У�ServiceInfo�������£�
```c++
// service����������Ϣ
struct ServiceInfo
{
    google::protobuf::Service *m_service; // ����������
    std::unordered_map<std::string, const google::protobuf::MethodDescriptor*> m_methodMap; // ������񷽷�
};
```


## rpcProvider���������ע��

����rpcProvider��Ҫ����TCPServer��������Ľ��գ������Ҫ������TCPServer�ṩrpc������÷���

���⣬calleeͨ������zkNodeע�����,�Ƚ�protobuf����ķ���ͷ�������ͳһ����Ȼ��ע�ᵽzk

```c++
// �����ǿ���ṩ���ⲿʹ�õģ����Է���rpc�����ĺ����ӿ�
void RpcProvider::NotifyService(google::protobuf::Service *service)
{
    ServiceInfo service_info;
    // ��ȡ�˷�������������Ϣ
    const google::protobuf::ServiceDescriptor *pserviceDesc = service->GetDescriptor();
    // ��ȡ���������
    std::string service_name = pserviceDesc->name();
    // ��ȡ�������service�ķ���������
    int methodCnt = pserviceDesc->method_count();
    // std::cout << "service_name:" << service_name << std::endl;
    LOG_INFO("service_name:%s", service_name.c_str());
    for (int i=0; i < methodCnt; ++i)
    {
        // ��ȡ�˷������ָ���±�ķ��񷽷������������������� UserService   Login
        const google::protobuf::MethodDescriptor* pmethodDesc = pserviceDesc->method(i);
        std::string method_name = pmethodDesc->name();
        service_info.m_methodMap.insert({method_name, pmethodDesc});

        LOG_INFO("method_name:%s", method_name.c_str());
    }
    service_info.m_service = service;
    m_serviceMap.insert({service_name, service_info});
}
```

����rpc������������TCPServer,���ûص������ĵ�����Ϣ��д�ص���,������ע�ᵽzk,����serverNameע��Ϊ�����Խڵ㣬��ֹ�ڵ����ߺ������ڵ�ע�������Ŀ¼����methodע��Ϊ��ʱ�ڵ㣬
��ȷ���ڵ����ߺ�caller���޷����ַ�����

```c++
// ����rpc����ڵ㣬��ʼ�ṩrpcԶ��������÷���
void RpcProvider::Run()
{
    // 1. ��ȡ�����ļ�rpcserver����Ϣ
    std::string ip = MprpcApplication::GetInstance().GetConfig().Load("rpcserverip");
    uint16_t port = atoi(MprpcApplication::GetInstance().GetConfig().Load("rpcserverport").c_str());
    muduo::net::InetAddress address(ip, port);

    // 2. ����TcpServer����
    muduo::net::TcpServer server(&m_eventLoop, address, "RpcProvider");
    // �����ӻص�����Ϣ��д�ص�����  ��������������ҵ�����
    server.setConnectionCallback(std::bind(&RpcProvider::OnConnection, this, std::placeholders::_1));
    server.setMessageCallback(std::bind(&RpcProvider::OnMessage, this, std::placeholders::_1, 
            std::placeholders::_2, std::placeholders::_3));
    // ����muduo����߳�����
    server.setThreadNum(4);

    // 3. �ѵ�ǰrpc�ڵ���Ҫ�����ķ���ȫ��ע�ᵽzk���棬��rpc client���Դ�zk�Ϸ��ַ���
    // session timeout   30s     zkclient ����I/O�߳�  1/3 * timeout ʱ�䷢��ping��Ϣ
    ZkClient zkCli;
    zkCli.Start();
    // service_nameΪ�����Խڵ㣬method_nameΪ��ʱ�Խڵ�
    for (auto &sp : m_serviceMap) 
    {
        // /service_name   /UserServiceRpc
        std::string service_path = "/" + sp.first;
        zkCli.Create(service_path.c_str(), nullptr, 0);    // ����service
        for (auto &mp : sp.second.m_methodMap)
        {
            // /service_name/method_name   /UserServiceRpc/Login �洢��ǰ���rpc����ڵ�������ip��port
            std::string method_path = service_path + "/" + mp.first;
            char method_path_data[128] = {0};
            sprintf(method_path_data, "%s:%d", ip.c_str(), port);
            // ZOO_EPHEMERAL��ʾznode��һ����ʱ�Խڵ�
            zkCli.Create(method_path.c_str(), method_path_data, strlen(method_path_data), ZOO_EPHEMERAL);
        }
    }

    // rpc�����׼����������ӡ��Ϣ
    std::cout << "RpcProvider start service at ip:" << ip << " port:" << port << std::endl;
    // 4. �����������
    server.start();
    m_eventLoop.loop(); 
}
```

### rpcProvider��Ϣ����

��caller�����󵽴�caller�󣬽�����������ӵĿɶ��¼���ִ����Ϣ��д�ص�

```c++
// �ѽ��������û��Ķ�д�¼��ص� ���Զ����һ��rpc����ĵ���������ôOnMessage�����ͻ���Ӧ
void RpcProvider::OnMessage(const muduo::net::TcpConnectionPtr &conn, 
                            muduo::net::Buffer *buffer, 
                            muduo::Timestamp)
{
    // 1. �����Ͻ��յ�Զ��rpc����������ַ���,������serverName��methodName��args
    std::string recv_buf = buffer->retrieveAllAsString();
    // ...
    service_name = rpcHeader.service_name();
    method_name = rpcHeader.method_name();
    args_size = rpcHeader.args_size();
    std::string args_str = recv_buf.substr(4 + header_size, args_size);
    // 2. ��ȡservice�����method����
    auto it = m_serviceMap.find(service_name);
    auto mit = it->second.m_methodMap.find(method_name);
    google::protobuf::Service *service = it->second.m_service; // ��ȡservice����  new UserService
    const google::protobuf::MethodDescriptor *method = mit->second; // ��ȡmethod����  Login

    // 3. ����rpc�������õ�����request����Ӧresponse����
    google::protobuf::Message *request = service->GetRequestPrototype(method).New();
    google::protobuf::Message *response = service->GetResponsePrototype(method).New();

    // 4. ��һ��Closure�Ļص�����SendRpcResponse
    google::protobuf::Closure *done = google::protobuf::NewCallback<RpcProvider, 
                                                                    const muduo::net::TcpConnectionPtr&, 
                                                                    google::protobuf::Message*>
                                                                    (this, 
                                                                    &RpcProvider::SendRpcResponse, 
                                                                    conn, response);

    // 5. �ڿ���ϸ���Զ��rpc���󣬵��õ�ǰrpc�ڵ��Ϸ����ķ���
    service->CallMethod(method, nullptr, request, response, done);
}
```

�ڷ���������ɺ󣬽���Ӧͨ��Closure�ص����л����ͻ�ȥ�����Ͽ�����

```c++
// Closure�Ļص��������������л�rpc����Ӧ�����緢��
void RpcProvider::SendRpcResponse(const muduo::net::TcpConnectionPtr& conn, google::protobuf::Message *response)
{
    std::string response_str;
    if (response->SerializeToString(&response_str)) // response�������л�
    {
        // ���л��ɹ���ͨ�������rpc����ִ�еĽ�����ͻ�rpc�ĵ��÷�
        conn->send(response_str);
    }
    conn->shutdown(); // ģ��http�Ķ����ӷ�����rpcprovider�����Ͽ�����
}
```




