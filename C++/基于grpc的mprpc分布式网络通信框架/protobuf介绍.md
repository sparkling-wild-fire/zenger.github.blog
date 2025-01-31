# protobuf介绍

gRPC 是一个高性能、开源和通用的远程过程调用（RPC）框架，由Google开发

Protocol Buffers 在 gRPC 中的应用
Protocol Buffers（Protobuf）是一种高效的数据序列化框架，用于定义结构化数据的格式。在 gRPC 中，Protobuf 被用作接口定义语言（IDL），用于定义服务接口和消息格式
。以下是 Protobuf 在 gRPC 中的具体应用：

1. 定义服务和消息：
  使用.proto 文件定义服务接口和消息结构。例如，定义一个服务方法及其请求和响应消息。
  通过 protoc 编译器，根据 .proto 文件生成客户端和服务端的代码，这些代码包括用于序列化和反序列化的类。
2. 序列化和反序列化：
  Protobuf 将请求和响应消息序列化为二进制格式进行传输，这种格式比 XML 和 JSON 更紧凑、更高效。
  在接收端，Protobuf 将二进制数据反序列化为消息对象，以便应用程序处理。
3. 跨语言支持：
  由于 Protobuf 是语言无关的，生成的代码可以在多种编程语言中使用，这使得 gRPC 可以在不同的语言环境中实现客户端和服务器的通信。


## protobuf接口定义

friend.proto:

```protobuf
syntax = "proto3";
package fixbug;
option cc_generic_services = true;

message ResultCode
{
    int32 errcode = 1; 
    bytes errmsg = 2;
}

message GetFriendsListRequest
{
    uint32 userid = 1;
}

message GetFriendsListResponse
{
    ResultCode result = 1;
    repeated bytes friends = 2;
}

// 定义服务
service FiendServiceRpc
{
    rpc GetFriendsList(GetFriendsListRequest) returns(GetFriendsListResponse);
}
```

message和service都会翻译成class，翻译的内容不同，message一般用于定义请求和响应，service定义实际的类和类成员方法
，如GetFriendsListResponse中，c++会将result翻译成ResultCode类型，repeated bytes friends会翻译成vector向量,并生成add_friends等对应的方法

## protobuf代码生成

message代码生成：
```c++
class GetFriendsListRequest :
    public ::PROTOBUF_NAMESPACE_ID::Message {
public:
    /***
     * else code
     */
    GetFriendsListRequest* New(::PROTOBUF_NAMESPACE_ID::Arena* arena) const final {
        return CreateMaybeMessage<GetFriendsListRequest>(arena);
    }
};
```

通过New函数，创建请求对象，Response响应对象的创建一样的

service代码生成：

```c++
class FiendServiceRpc : public ::PROTOBUF_NAMESPACE_ID::Service {
 protected:
  // This class should be treated as an abstract interface.
  /***
   * else code
   */
  typedef FiendServiceRpc_Stub Stub;
  static const ::PROTOBUF_NAMESPACE_ID::ServiceDescriptor* descriptor();
  virtual void GetFriendsList(::PROTOBUF_NAMESPACE_ID::RpcController* controller,
                       const ::fixbug::GetFriendsListRequest* request,
                       ::fixbug::GetFriendsListResponse* response,
                       ::google::protobuf::Closure* done);
  // implements Service ----------------------------------------------
  const ::PROTOBUF_NAMESPACE_ID::ServiceDescriptor* GetDescriptor();
  void CallMethod(const ::PROTOBUF_NAMESPACE_ID::MethodDescriptor* method,
                  ::PROTOBUF_NAMESPACE_ID::RpcController* controller,
                  const ::PROTOBUF_NAMESPACE_ID::Message* request,
                  ::PROTOBUF_NAMESPACE_ID::Message* response,
                  ::google::protobuf::Closure* done);
  const ::PROTOBUF_NAMESPACE_ID::Message& GetRequestPrototype(
    const ::PROTOBUF_NAMESPACE_ID::MethodDescriptor* method) const;
  const ::PROTOBUF_NAMESPACE_ID::Message& GetResponsePrototype(
    const ::PROTOBUF_NAMESPACE_ID::MethodDescriptor* method) const;
};
```

1. Stub: 统一通过stub进行rpc调用
2. ServiceDescriptor：存储protobuf的service信息
3. CallMethod: rpc调用统一通过CallMethod调用
4. GetRequestPrototype和GetResponsePrototype：获取message请求和响应属性，以便method对象创建