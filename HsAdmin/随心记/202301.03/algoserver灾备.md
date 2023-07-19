# algoserver 灾备恢复


## 为什么要进行灾备

最终的目的是处理非终态的子单委托，策略新建一个方案后拆分出多个子单，这些子单由`策略服务器`写入UFT（是吗？）

但是`接入平台`（如宽途），在接收外部请求，需要处理这些子单的时候，发现策略服务器对应的`策略站点`挂了，那么这些子单就无法处理了，需要马上重启`策略服务器`(为什么不只启动这一个策略站点呢？)

tip: 如果不进行灾备，需要在平台日初逻辑中处理方案缓存消息（通常为子单消息）（方案缓存消息存在哪里？为什么是缓存消息而不是缓存数据，是未处理的消息吗？）

## 灾备方式：

平台通过如下两种方式触发重试：
- 定时触发（设置定时任务，请求重建）
- 登录触发（新站点需要登录平台，登录时增加异步调用逻辑进行恢复）


恢复流程：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230712144150.png" alt="20230712144150" width="450" >

1. 子单委托恢复，不需要特定的策略来恢复
2. 策略本身不支持灾备，则不会进行恢复
3. 缓存恢复？ 缓存消息不都是子单消息？



## 日志梳理

平台：
5180509
15180028
45180009: 策略站点查询   =》 除了查询条件，为啥都是空值
35180402 ： 向站点（进程中的线程）发送消息`asset.algo.recover_scheme`  =》 结束

策略：
AlgoDealThread.cpp：收到主推消息（如线程1收到主推消息），为啥只有27方案号的(应该是从小到大一个一个来)  => 所有方案都会进行灾备吗？
AlgoOrder.cpp：处理方案信息，创建的方案号都是0吗  =》 应该是重建错了，应该是传过来的方案号
Login.cpp：登录，返回站点序号6
调用5180268：宽途映射账户查询（根据方案id查询） =》 查询方案下所有的账户信息  =》也就是方案明细下，所有account_info中的账户？
...
方案创建成功 =》 51802020(方案状态) =》 5180246 =》 策略站点成功接管方案ID[31]

灾备插入子单完成，向平台推送方案完成消息  =》 5180224 （方案恢复消息，确定不是回调，怎么做到这个消息是这个函数消费的） =》 AsynCallServer()异步调用

休眠 =》 是这个方案的站点线程休眠吧



方案重建 => 多线程 

方案委托量,成交量恢复：`方案证券汇总方向委托信息表、方案证券方向委托信息表`



策略的OnSchemeInit => ?
int CSchemeMessageProc::OnSchemeInit(IF2UnPacker* pUnPacker, std::string& sOutParam) =>
int CSchemeImpl::OnSchemeInit(IF2UnPacker* pUnPacker, std::string& sOutParam)    =>  这个pUnPacker哪个平台给他的
    => int CSchemeImpl::GatherSchemeStocksInfo(IF2UnPacker* pUnPacker, std::string& sErrMsg)   