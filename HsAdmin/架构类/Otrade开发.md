# Otade交易数据中台对接SMP

O3体量太大，所以将其中的交易模块抽离出来，集成到Otrade客户端

## O3数据处理

后台代码与宽途用同一份代码，分三期在不同的分支上开发，开发后将代码进行合并

### O3数据表导入

1. 静态数据，如委托方向表，直接通过脚本打入

2. 动态数据，如证券询价表，启动Otrade时，通过F2插件分页查询O3：
   - 每次启动需要清空的数据，或者需要频繁查询的数据，如委托表，新建一张对应的内存表，将数据导入到内存数据库中
   - 需要持久化的数据，需新建实体表，数据存实体表有两种途径
     - 同时写内存表和实体表
     - hsdb插件读取配置文件中的落库表定时落库
   - 查询频率比较低，只设置实体表，如按钮表，只打开页面的时候才会查表

### O3数据同步

1. 接收主推,接收主推的数据通常很少，所以还需要再去查找一遍O3,调表加载的适配sql
2. 定义同步任务（怎么解决数据量大的问题）
3. 二者结合，比如指令表，指令是特别重要的任务，定时同步任务主要防止有指令漏掉了

## 对接SMP监控组件

### 适配处理

Otarde对接外部系统，需要给外部系统设置一个外部系统号，用来区分具体是对接的哪一套系统，这个系统号主要用于在调服务时进行路由

Otrade内部是通过类似OSPF协议去调不同模块下的服务的，每个服务对应一个ID,对接每个系统需要划分一个号段，如（402000~403999），服务ID处于号段内的都是对接SMP的服务

### 线程划分

为防止smp请求过多，阻塞普通模块的线程，在Proc线程池组件中新增三组线程，每组线程三个，smp的处理只在这三个线程组中运行

| 线程组编号     | 	分组线程数 |     模块英文名  |   模块中文名   | 备注     | so   |
|-----------|--------|  ---|---|--------|----------------------|
| 30	       | 8      |  smp_access  |    SMP接入  | 对接SMP相关的查询和设置接口，功能号段404000~404099 | s_ls_smp_accessflow  | 
| 31	       | 8      |smp_access  |    SMP接入  | smp的消息主推处理 | s_ls_smp_messagepush | 
| 32        | 8      |smp_access  |    SMP接入  | SMP相关的OT消息主题格式为stp.smp.xxx | s_ls_smp_messageaccess | 

每组线程对应一个代码模块，每个模块编译成一个so，Otrade启动加载时，将so中的服务加载到Proc线程池的线程组中，

当调用某一个服务时，经过路由筛选，会将这次调用分发到Proc，Proc会进一步分发到对应的线程组中。


### 对接SMP微服务

smp将服务注册到zookeeper上，Otrade需要通过微服务插件连接同一套zk，去调smp的服务，调服务时，需要指定GSV:
- group:同一个功能号的不同实现
- service:服务所在分布式机器
- version:服务的版本号

### SMP主推

smp将消息发送到mc，mt订阅smp推送的消息，接收到消息后（由mc消息转换成F2包）,取F2包中的message_body，调适配功能号进行值域转换等适配操作，发送到mt的smp消息主推线程，
mt进行主备判断，如果是备机则直接退出，
然后将stp消息通过PubMsgByPacker()发送到mc, mc将消息推送到客户端, 客户端将根据其中的过滤字段，判断这个主推需不需要接收（操作员代码）

```C++
// 消息中心发布的消息
struct MCData{
    char* topic;
    void* data;
    int length;
    int sec;
    int usec;
    uint64 deliveryTag;//表示消息序列号
};

IF2UnPacker* unpacker = pack_svr_->GetUnPacker(mc_data->data, mc_data->length);
```


发送消息都将消息打包到字段message_body, 所以取的时候也取这个字段结构体message_body:
```txt
@unpacker = lpPackService->GetUnPacker(p_msg_body,pi_msg_body);
// 新增超时时间30s
iReturnCode = lpContext->PubMsgByPacker(@topic_name,@unpacker,CNST_TIMEOUT);
```

mc尝试订阅线程：
```c++
void CMicroSvrRetryThread::DoRetry() {
    if (NULL == subscriber_ && NULL != cb_) {
        subscriber_ = cb_->OnRetrySubscriberCreate();
        if (NULL == subscriber_) {
            return;
        } else {
            cb_->OnSubscriberCreated();
        }
    }
    
    std::list<McSubParam> tmp;
    std::list<McSubParam>::iterator it = retry_list_.begin();
    for (; it != retry_list_.end(); ++it) {
        std::string topic_name = (*it).first;
        IMicSvrSubscribeParam* sub_param = (*it).second;

        int iRet = subscriber_->SubscribeTopic(sub_param, 30000);
        if (iRet <= 0)
        {
			if (NULL != mc_client_)
				LogError("订阅主题" << topic_name << "失败，原因" << mc_client_->GetErrMsg(iRet) << ", 稍后重试");
            tmp.push_back(std::make_pair(topic_name, sub_param));
        }
        else
        {
            if (sub_param) {
                LogInfo("订阅主题" << topic_name << "成功, 过滤条件:" << sub_param);
            } else {
                LogInfo("订阅主题" << topic_name << "成功");
            }
            if (sub_param) {
                sub_param->Release();
            }
        }
    }

    retry_list_.swap(tmp);
    if (retry_list_.empty()) {
        done_ = true;
    }
}
```


```xml
<!--mt消息订阅-->
<adapter name="SMP" version="20240408" subsys_no="1003">
<disposer file="SMP/disposer.xml"/>
<message file="SMP/message.xml">
    <receiver class="MessageReceiver_MicroSvrMC" subscriber="otrade_smp_msg" />
</message>
</adapter>
```

adapter创建订阅者：
```c++
IMicSvrSubscriber* MessageReceiver_MicroSvrMC::CreateSubscribe() {
    if (mc_client_)
    {
        if (NULL == subscriber_) {
            subscriber_ = mc_client_->NewSubscriber(subcallback_, (char*)subscriber_name_.c_str(), 30000);
        }
        if (NULL == subscriber_) {
            // 无法创建订阅者不在retry线程重试，后续考虑由数据加载例程进行重试
            string log = "无法创建订阅者[" + subscriber_name_ + "]，错误原因:";
            log += mc_client_->GetMCLastError();
            log += ", 稍后重试";
            //CHANGE_STATUS_LOG(status, STATUS_ERROR_INTERNAL, log);
            LogError(log);
            return NULL;
        }
    }
    else
    {
        LogError("mc_client_为NULL");
    }

    return subscriber_;
}
```


#### 注意事项

1. 接收smp的主推时，需要加mc注册到zookeeper上

2. 设置正确的过滤字段：如触发股票成交统计后，会发5条消息，它们只有操作员字段不同

3. HUI前端消息缓存：smpweb界面前端会先将所有消息缓存起来，6s将消息汇总刷新一次（为啥要降频？）