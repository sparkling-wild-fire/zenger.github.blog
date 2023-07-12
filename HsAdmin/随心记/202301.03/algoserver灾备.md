# algoserver 灾备恢复

5180509
15180028
45180009: 策略站点查询   =》 除了查询条件，为啥都是空值
35180402 ： 向站点（进程中的线程）发送消息`asset.algo.recover_scheme`  =》 结束

策略：
AlgoDealThread.cpp：收到主推消息（如线程1收到主推消息），为啥只有27方案号的(应该是从小到大一个一个来)
AlgoOrder.cpp：处理方案信息，创建的方案号都是0吗  =》 应该是重建错了，应该是传过来的方案号
Login.cpp：登录，返回站点序号6
调用5180268：宽途映射账户查询（根据方案id查询） =》 查询方案下所有的账户信息  =》也就是方案明细下，所有account_info中的账户？
...
方案创建成功 =》 51802020(方案状态) =》 5180246 =》 策略站点成功接管方案ID[31]

灾备插入子单完成，向平台推送方案完成消息  =》 5180224 （方案恢复消息，确定不是回调，怎么做到这个消息是这个函数消费的） =》 AsynCallServer()异步调用

休眠 =》 是这个方案的站点线程休眠吧

怎么把之前的方案全部删除

方案重建 => 多线程 

方案委托量,成交量恢复：`方案证券汇总方向委托信息表、方案证券方向委托信息表`



策略的OnSchemeInit => ?
int CSchemeMessageProc::OnSchemeInit(IF2UnPacker* pUnPacker, std::string& sOutParam) =>
int CSchemeImpl::OnSchemeInit(IF2UnPacker* pUnPacker, std::string& sOutParam)    =>  这个pUnPacker哪个平台给他的
    => int CSchemeImpl::GatherSchemeStocksInfo(IF2UnPacker* pUnPacker, std::string& sErrMsg)   