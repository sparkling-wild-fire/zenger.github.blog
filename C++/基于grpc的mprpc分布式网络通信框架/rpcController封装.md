# rpcController��װ

MprpcController�Ƕ�RpcController�ķ�װ��������¼rpc���õĹ��̣����¼���ô�����Ϣ��

```c++
class MprpcController : public google::protobuf::RpcController
{
public:
    // ...
    void MprpcController::SetFailed(const std::string& reason)
    {
        m_failed = true;
        m_errText = reason;
    }
private:
    bool m_failed; // RPC����ִ�й����е�״̬
    std::string m_errText; // RPC����ִ�й����еĴ�����Ϣ
};
```


