# rpcController封装

MprpcController是对RpcController的封装，用来记录rpc调用的过程，如记录调用错误信息，

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
    bool m_failed; // RPC方法执行过程中的状态
    std::string m_errText; // RPC方法执行过程中的错误信息
};
```


