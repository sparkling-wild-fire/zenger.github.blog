# GRPC

## GRPC基本原理

向服务器请求，像调用本地函数一样

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307132151219.png" alt="202307132151219" width="450px">

其中，Protobuf用来做序列化（比如你要调用的函数和参数），然后通过HTTP2.0进行数据传输

### gRPC的一些特性
1. gRPC基于`服务的思想`：定义一个服务，描述这个服务的方法以及入参出参，服务器端有这个服务的具体实现，客户端保有一个存根（？），提供与服务端相同的服务
2. gRPC默认采用`protocol buffer`作为`IDL`(Interface Description Lanage)接口描述语言,服务之间通信的数据序列化和反序列化也是基于`protocol buffer`的，因为protocol buffer的特殊性，所以gRPC
   框架是跨语言的通信框架(与编程语言无关性)，也就是说用Java开发的基于gRPC的服务，可以用 GoLang编程语言调用
3. gRPC同时支持`同步调用和异步调用`
   - 同步RPC调用时会一直阻塞直到服务端处理完成返回结果
   - 异步RPC是客户端调用服务端时不等待服务段处理完成返回，而是服务端处理完成后主动回调客户端告诉客户端处理完成
4. gRPC是`基于http2`协议实现的，http2协议提供了很多新的特性，并且在性能上也比http1提搞了许多，所以gRPC的性能是非常好的
5. gRPC并`没有直接实现负载均衡和服务发现的功能`，但是已经提供了自己的设计思路。已经为命名解析和负载均衡提供了接口
6. 基于http2协议的特性：gRPC允许定义如下四类服务方法
   - 一元RPC：客户端发送一次请求，等待服务端响应结构，会话结束，就像一次普通的函数调用
      这样简单
   - 服务端流式RPC：客户端发起一起请求，服务端会返回一个流，客户端会从流中读取一系列消
      息，直到没有结果为止
   - 客户端流式RPC：客户端提供一个数据流并写入消息发给服务端，一旦客户端发送完毕，就等
      待服务器读取这些消息并返回应答
   - 双向流式RPC：客户端和服务端都一个数据流，都可以通过各自的流进行读写数据，这两个流
      是相互独立的，客户端和服务端都可以按其希望的任意顺序独写

### 数据封装和数据传输问题

网络传输中的内容封装数据体积问题

JSON：
- 优点：在body中用JSON对内容进行编码，极易跨语言，不需要约定特定的复杂编码格式和Stub文件。在版本兼容性上非常友好，扩展也很容易。
- 缺点：JSON难以表达复杂的参数类型，如结构体等；数据冗余和低压缩率使得传输性能差。

gRPC对此的解决方案是丢弃json、xml这种传统策略，使用 Protocol Buffer，是Google开发的一种跨语言、跨平台、可扩展的用于序列化数据协议。

IDL样例文件：
```C++
// XXXX.proto
// rpc服务的类 service关键字， Test服务类名
service Test {
    // rpc 关键字，rpc的接口
    rpc HowRpcDefine (Request) returns (Response) ; // 定义一个RPC方法
}
// message 类，c++ class
message Request {
    //类型 | 字段名字| 标号
    int64 user_id = 1;
    string name = 2;
}
message Response {
    repeated int64 ids = 1; // repeated 表示数组
    Value info = 2; // 可嵌套对象
    map<int, Value> values = 3; // 可输出map映射
}
message Value {
    bool is_man = 1;
    int age = 2;
}
```

包含方法定义、入参、出参。可以看出有几个明确的特点：
- 有明确的`类型`，支持的类型有多种
- 每个field会有名字
- 每个field有一个`数字标号`，一般按顺序排列(下文编解码会用到这个点)
- 能表达`数组、map映射`等类型
- 通过`嵌套message`可以表达复杂的对象
- 方法、参数的定义落到一个.proto 文件中，`依赖双方需要同时持有这个文件，并依此进行编解码`

protobuf作为一个以跨语言为目标的序列化方案，protobuf能做到多种语言以同一份proto文件作为约
定，不用A语言写一份，B语言写一份，各个依赖的服务将proto文件原样拷贝一份即可。

但.proto文件并不是代码，不能执行，要想直接跨语言是不行的，必须得有对应语言的中间代码才行，
中间代码要有以下能力：
- 将message转成对象，例如C++里是class，golang里是struct，需要各自表达后，才能被理解
- 需要有进行编解码的代码，能解码内容为自己语言的对象、能将对象编码为对应的数据

### 网络传输效率问题

grpc采用HTTP2.0，相对于HTTP1.0 在 更快的传输 和 更低的成本 两个目标上做了改进。有以下几个基本
点：
- HTTP2 未改变HTTP的语义(如GET/POST等)，只是在传输上做了优化
- 引入帧、流的概念，在TCP连接中，可以区分出多个request/response
- 一个域名只会有一个TCP连接，借助帧、流可以实现多路复用，降低资源消耗
- 引入二进制编码，降低header带来的空间占用

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307132211713.png" alt="202307132211713" width="450px">

### GRPC 4种模式

####  一元RPC模式

一个请求一个响应（发送完响应后，服务器端会以 trailer 元数据的形式将其状态发送给客户端，从而标记流的结束）

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307132213894.png" alt="202307132213894" width="450px">

#### 服务器端流RPC模式

一个请求多个响应（以 trailer 元数据结束）

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307132214906.png" alt="202307132214906" width="450px">

#### 客户端流RPC模式

多个请求一个响应，服务端收到一条消息就可以发送响应了，并不需要全部接受完
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307132216235.png" alt="202307132216235" width="450px">

####  双向流RPC模式

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307132217023.png" alt="202307132217023" width="450px">


### GRPC同步和异步

基本概念图

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307132218864.png" alt="202307132218864" width="450px">

### 需要事先约定调用的语义

### 需要网络传输

### 需要约定网络传输中的内容格式

## GRPC实践

### 同步调用

### 异步调用