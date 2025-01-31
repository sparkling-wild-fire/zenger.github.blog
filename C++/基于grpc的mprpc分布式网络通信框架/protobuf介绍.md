# protobuf����

gRPC ��һ�������ܡ���Դ��ͨ�õ�Զ�̹��̵��ã�RPC����ܣ���Google����

Protocol Buffers �� gRPC �е�Ӧ��
Protocol Buffers��Protobuf����һ�ָ�Ч���������л���ܣ����ڶ���ṹ�����ݵĸ�ʽ���� gRPC �У�Protobuf �������ӿڶ������ԣ�IDL�������ڶ������ӿں���Ϣ��ʽ
�������� Protobuf �� gRPC �еľ���Ӧ�ã�

1. ����������Ϣ��
  ʹ��.proto �ļ��������ӿں���Ϣ�ṹ�����磬����һ�����񷽷������������Ӧ��Ϣ��
  ͨ�� protoc ������������ .proto �ļ����ɿͻ��˺ͷ���˵Ĵ��룬��Щ��������������л��ͷ����л����ࡣ
2. ���л��ͷ����л���
  Protobuf ���������Ӧ��Ϣ���л�Ϊ�����Ƹ�ʽ���д��䣬���ָ�ʽ�� XML �� JSON �����ա�����Ч��
  �ڽ��նˣ�Protobuf �����������ݷ����л�Ϊ��Ϣ�����Ա�Ӧ�ó�����
3. ������֧�֣�
  ���� Protobuf �������޹صģ����ɵĴ�������ڶ��ֱ��������ʹ�ã���ʹ�� gRPC �����ڲ�ͬ�����Ի�����ʵ�ֿͻ��˺ͷ�������ͨ�š�


## protobuf�ӿڶ���

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

// �������
service FiendServiceRpc
{
    rpc GetFriendsList(GetFriendsListRequest) returns(GetFriendsListResponse);
}
```

message��service���ᷭ���class����������ݲ�ͬ��messageһ�����ڶ����������Ӧ��service����ʵ�ʵ�������Ա����
����GetFriendsListResponse�У�c++�Ὣresult�����ResultCode���ͣ�repeated bytes friends�ᷭ���vector����,������add_friends�ȶ�Ӧ�ķ���

## protobuf��������

message�������ɣ�
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

ͨ��New�����������������Response��Ӧ����Ĵ���һ����

service�������ɣ�

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

1. Stub: ͳһͨ��stub����rpc����
2. ServiceDescriptor���洢protobuf��service��Ϣ
3. CallMethod: rpc����ͳһͨ��CallMethod����
4. GetRequestPrototype��GetResponsePrototype����ȡmessage�������Ӧ���ԣ��Ա�method���󴴽�