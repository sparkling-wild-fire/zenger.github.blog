# etcd

etc 在Linux系统中是文件目录名；加个d就是指配置服务

提供高可用性（一般通过集群的方式，一个节点挂了，另起一个节点）、强一致性的kv数据存储服务

基于Go语言实现，主要用于：
- 共享配置：配置文件的存储分发
- 服务发现：etcd监听服务提供方，当新增一个服务提供方时，etcd能够发现这个服务(怎么发现的 ?)
- 集群监控：集群监控中心连接etcd，etcd管理所有节点的状态变更，当一个节点宕机，etcd能够发现并通知监控中心
- leader选举：一个leader节点宕机，选举一个新的leader（Raft共识算法）
- 分布式锁：保证分布式系统临界资源同时只被一个微服务（一个进程）访问，在这个临界资源的上下文加锁 (基于几种机制)

## etcd架构

### v2和v3版本比较

- v3使用`gRPC+protobuf`取代http+json通信，提高通信效率
  - gRPC只需要一条连接（采用http2，多路复用），http是每个请求建立一条连接
  - protobuf加解密比json加解密速度得到数量级的提升，且包体更小
- v3使用`lease`（租约）替换key ttl自动过期机制
  - 租约：设置一个过期实体，并绑定多个key，过期实体到期了，绑定的key全都删除
- v3支持`事务`（mini的事务）和`多版本并发控制`（一致性非锁定读）的磁盘数据库（数据更加安全）；而v2是简单的kv内存数据库
  - 类似mysql的mvcc：写操作都是要加锁，但是每次读操作也加锁效率太低，不加锁又不安全，所以需要设置不同的隔离级别，按照不同的规则读取
- v3是扁平的kv结构；v2是类型文件系统的存储结构
  - 在zk里面，节点间是以文件形式设置各个节点的关系；如node、子节点node/node1、子节点node/node2
  - 在etcd v3，取名字直接就是node、node1、node2 （通过get node --prefix可全部访问出来）

### 架构

因为要提供高可用性，通常采用分布式集群的方式：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304131134535.png" alt="202304131134535" width="450px">

1. gRPC Server,主要处理两件事
- 接收clinet的请求，解析protobuf协议
- 处理集群间消息的传递

2. wal（write ahead log、预写式日志）实现事务日志的标准方法：负责etcd的修改，数据同步（snapshot），

执行写操作前先写日志，跟mysql中redo类型，wal实现的是顺序写。而若采用B+树写（etcd采用B+树存储），则涉及多次io以及随机写）

=> 先写日志，异步写磁盘

3. snapshot快照数据：类似redis中主从复制的rdb数据恢复，由leader生成snapshot并发送给follower

4. boltdb：类似mysql中的存储引擎innodb，用来存储，并支持事务
   - 为每一个key创建一个索引，每一个索引创建一颗B+树（etcd支持多个版本，该B+树存储了key所对应的版本数据）
   - 为什么key的版本数据都用B+树存储呢？

## etcd操作

- 值操作：key的put、get（支持key的区间查询）、del
- 监听：
- 租约：用于集群监控以及服务注册发现
  - grant：创建租约实体
  - keep-alive：通过不断发送心跳包，让这个实体一直保持活跃
  - list、revoke、timetolive(获取租约信息)
- 事务：类似CAS
  - `IF-THEN-ELSE`依次提醒你输入三个命令：compares、success_action、failure_action
  - 成功或失败都可以执行多条命令（这些命令保证了原子性）
- 锁：有三个服务A,B,C连接etcd
  - 设置变量，获取锁 get key lock --prifix
  - 三个竞争者中，A持有锁，B突然宕机，那么C就不会监听B的锁删除，而是监听A
- 数据版本号机制：
  - revision:每次修改key都会将版本+1
  - mod_revision:每次发生选举，都会将选举任期+1
  - kvs:
    - create_revision:创建数据时的版本号
    - mod_revision:修改数据时的版本号
    - version：当前版本号，标识该val修改了多少次

## etcd分布式锁

### 几个机制
1. Leas机制

   设置一个过期实体，并绑定多个key，过期实体到期了，绑定的key全都删除

   Lease机制可以保证分布式锁的安全性：为锁的key配置租约，即使锁的持有者宕机不能释放锁，也会因租约到期而释放
2. Revision机制

   每个key带有一个 Revision 号，每进行一次事务便+1（也就是每次增删改都会+1），它是全局唯一的， 通过 Revision 的大小就可以知道进行写操作的顺序

   在实现分布式锁时，多个客户端同时抢锁， 根据 Revision 号大小依次获得锁，可以避免 “羊群效应” ，实现`公平锁`。


3. Prefix机制

例如，一个名为 /etcd/lock 的锁，两个争抢它的客户端进行写操作， 实际写入的 key 分别为：key1="/etcd/lock/UUID1"，key2="/etcd/lock/UUID2"。

其中，UUID 表示全局唯一的 ID，确保两个 key 的唯一性。

写操作都会成功，但返回的 Revision 不一样， 那么，如何判断谁获得了锁呢？

通过前缀 /etcd/lock 查询，返回包含两个 key-value 对的的 KeyValue 列表， 同时也包含它们的 Revision，通过 Revision 大小，客户端可以判断自己是否获得锁。

4. Watch机制

Watch 机制支持 Watch 某个固定的 key，也支持 Watch 一个范围（前缀机制），当被 Watch 的 key 或范围发生变化，客户端将收到通知。

在实现分布式锁时，如果抢锁失败，可通过 Prefix 机制返回的 Key-Value 列表获得 Revision 比自己小且相差最小的 key（称为 pre-key）， 对 pre-key 进行监听，
因为只有它释放锁，自己才能获得锁，如果Watch到pre-key的DELETE事件，则说明pre-key已经释放，自己将持有锁。

5. 事务

### etcd分布式锁的实现流程

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304131700630.png" alt="202304131700630" width="450px">

1. 客户端创建连接，创建key
   - 客户端连接etcd，以/etcd/lock为前缀创建全局唯一的key，假设第一个客户端对应的 key="/etcd/lock/UUID1"，第二个为 key="/etcd/lock/UUID2"
2. 创建租约，自动续租
   - 客户端分别为自己的key创建租约，创建一个定时任务作为`心跳`
3. 获取锁，有写前缀和写key两种方式：
  - 写key：
     - 创建事务：IF etcd服务端存在指定key（create_revision大于0）, Then put ELSE 返回抢锁失败
  - 写前缀：
      - 执行put操作，将key写入etcd，etcd返回返回revision，假设分别为1，2，客户端记录下来，以接下来判断自己是否获得锁
      - 客户端以前缀/etcd/lock key-Value 列表，判断自己 key 的 Revision 是否为当前列表中 最小的，如果是则认为获得锁
  - 如果未获取锁,否则监听列表中前一个 Revision 比自己小的 key 的删除事件，一旦监听到删除事件或者因租约失效而删除的事件，则自己获得锁
4. 执行业务逻辑，最后删除对应的key释放锁

`总结`：
连接etcd的客户端创建自己的key，在租期内通过事务去抢锁；
如果自己的key在etcd服务器中的revision是最小的，则抢锁成功；
否则监听revision小于自己且最临近的key，监听这个key是否被删除

## etcd存储原理与读写机制

### 存储原理

etcd 为每个key创建一个索引;一个索引对应着一个B+树; B+树key为 revision，B+节点存储的
值为value; 之所以用B+树，是为了支持前缀匹配：`get key --prefix`

B+树存储着key的版本信息从而实现了etcd的 mvcc; etcd不会任由版本信息膨胀，通过定期的compaction来清理历史数据

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304131705766.png" alt="202304131705766" width="450px">

为了加速索引数据，在内存中维持着一个B树，B树key为key，value为该key的revision，
查询key时，会先去查找revision，然后根据key和recision去找value


总结：
- 内存中：B-树，如设置key的值，要去B-树查找对应的revision
- 磁盘中：预写日志，将value写入B+树 (B+树在磁盘中？)

思考：mysql的mvcc是通过什么实现的 => undolog
mysql B+ 树存储什么内容？

### 读写机制

串行写，并发读

并发读写时（读写同时进行），读操作是通过 B+ 树 mmap 访问磁盘数据；写操作走日志复制流
程；可以得知如果此时读操作走 B 树出现脏读幻读问题；通过 B+ 树访问磁盘数据其实访问的事务
开始前的数据，由 mysql 可重复读隔离级别下 MVCC 读取规则可知能避免脏读和幻读问题；

并发读时，可走内存B树

## Raft共识算法

包含两个流程：leader选举和日志复制

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304131756444.png" alt="202304131756444" width="450px">

数据一致性：客户端要写一个`set 5`,leader会先预写日志，然后征得其他follower节点半数以上的同意，才会执行这个事务。
执行完成后后，leader将修改成功结果返回客户端，同时给其他follower发送消息，通知他们也执行该事务。

### 选举

原则：少数服从多数

记不住，需要的时候再查资料：
[参考链接](https://zhuanlan.zhihu.com/p/383555591)







