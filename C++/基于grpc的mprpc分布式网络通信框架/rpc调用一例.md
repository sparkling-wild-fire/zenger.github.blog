# rpc����

��friend.protoΪ���ӣ�

## callee

```c++
class FriendService : public fixbug::FiendServiceRpc
{
public:
    // �ṩ������rpc�ڵ���õķ���
    std::vector<std::string> GetFriendsList(uint32_t userid)
    {
        std::cout << "do GetFriendsList service! userid:" << userid << std::endl;
        std::vector<std::string> vec;
        vec.push_back("gao yang");
        vec.push_back("liu hong");
        vec.push_back("wang shuo");
        return vec;
    }

    // ��дgrpc::protobuf���ɵĻ��෽��
    void GetFriendsList(::google::protobuf::RpcController* controller,
                       const ::fixbug::GetFriendsListRequest* request,
                       ::fixbug::GetFriendsListResponse* response,
                       ::google::protobuf::Closure* done)
    {
        uint32_t userid = request->userid();
        std::vector<std::string> friendsList = GetFriendsList(userid);
        // mutable_result() => CreateMaybeMessage
        response->mutable_result()->set_errcode(0);
        response->mutable_result()->set_errmsg("");
        for (std::string &name : friendsList)
        {
            std::string *p = response->add_friends();
            *p = name;
        }
        done->Run();
    }
};

int main(int argc, char **argv)
{
    // ���ÿ�ܵĳ�ʼ������
    MprpcApplication::Init(argc, argv);
    // provider��һ��rpc���������󡣰ѷ��񷢲���rpc�ڵ���
    RpcProvider provider;
    provider.NotifyService(new FriendService());
    // ����һ��rpc���񷢲��ڵ㣬Run�Ժ󣬽��̽�������״̬���ȴ�Զ�̵�rpc��������
    provider.Run();
    return 0;
}
```

## caller

```c++
int main(int argc, char **argv)
{
    // �������������Ժ���ʹ��mprpc���������rpc������ã�һ����Ҫ�ȵ��ÿ�ܵĳ�ʼ��������ֻ��ʼ��һ�Σ�
    MprpcApplication::Init(argc, argv);
    // ��ʾ����Զ�̷�����rpc����
    fixbug::FiendServiceRpc_Stub stub(new MprpcChannel());
    // rpc�������������
    fixbug::GetFriendsListRequest request;
    request.set_userid(1000);
    // rpc��������Ӧ
    fixbug::GetFriendsListResponse response;
    // ����rpc�����ĵ���  ͬ����rpc���ù���  MprpcChannel::callmethod
    MprpcController controller;
    stub.GetFriendsList(&controller, &request, &response, nullptr); // RpcChannel->RpcChannel::callMethod ������������rpc�������õĲ������л������緢��

    // һ��rpc������ɣ������õĽ��,��ȡcontroller�еĴ�����Ϣ
    if (controller.Failed())
    {
        std::cout << controller.ErrorText() << std::endl;
    }
    else
    {
        if (0 == response.result().errcode())
        {
            std::cout << "rpc GetFriendsList response success!" << std::endl;
            int size = response.friends_size();
            for (int i=0; i < size; ++i)
            {
                std::cout << "index:" << (i+1) << " name:" << response.friends(i) << std::endl;
            }
        }
        else
        {
            std::cout << "rpc GetFriendsList response error : " << response.result().errmsg() << std::endl;
        }
    }

    return 0;
}
```