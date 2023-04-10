# GRPC

采用http2

http1.0支持长连接，但如果第一个请求发送了没有响应，就会影响第二个请求的发送

http1.1支持管道，即一个连接允许发送多个请求，但请求的响应必须与请求保持一致

http2采用分帧分流的方式，实现多路复用，支持乱序响应，多个请求互不干扰

grpc采用http2，而不是采用TCP长连接

- 可以支持短连接
- 在head中方便嵌入ssl

GRPC特点：
- 基于IDL定义服务，通过proto3工具生成指定语言的数据结构，服务端接口以及客户端stub
- 基于标准的http2/设计，支持双向流、消息头压缩，单tcp的多路复用，服务端送等特性
- 序列化支持protobuffer,json,protobuffer是一种无关语言的高性能序列化框架，基于`http2+protobuffer`,保证了rpc调用的高性能

GPRC应用场景：
- 分布式场景：低延迟和高吞吐量，非常适用于效率至关重要的轻型微服务
- 点对点实时通信：对双向流媒体提供出色的支持，实时推送消息而无需轮询
- 网路流量受限场景：protobuffer序列化后的消息小

节省空间，比如IDL定义了数据结构
Messgae Data{
    string r1=1;
    string r2=2;
}

发送给服务器时，protobuffer只需要发送value就行，因为服务器也有一个这样的结构

protobuffer(ptb吧):流类型

定义好结构体和服务后，编译

##  gRPC_API

在某一端处理复杂 => 任务拆分

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304111722617.png" alt="202304111722617" width="450px">


