# mc消息订阅逻辑

## 微服务插件api

microsvr_interface.h

## 插件启动顺序

AdapterManager::Initialize begin

Adapter::Initialize begin
```txt
Adapter::Initialize begin.
    subsys_no:1003
    SMP适配器没有配置数据.
MessageManager::Initialize begin.
    MessageManager::dispatch_thread_num_:8
    正在解析处理第[0]个适配消息接收器对象
    第[0]个适配器消息接收器对象命名为[MessageReceiver_MicroSvrMC@0]
MessageReceiver_MicroSvrMC::Initialize begin
MessageReceiver_MicroSvrMC::Initialize end.
MessageManager::InitializeMessage begin../adapters/SMP/message.xml
Message_MC::Initialize begin.
    新增主题[smp.flow.bubbleremind]
Message_MC::Initialize end.
Message_MC::Initialize begin.
    新增主题[smp.hq.status]
......
[CRES|message_manager.cpp|InitializeMessage|307#139706377803584]MessageManager::InitializeMessage end.
[CRES|message_manager.cpp|Initialize|153#139706377803584]MessageManager::Initialize end.
然后就是初始化功能号调用的那些东西了
```

插件运行日志：`2024-11-05-alg_tran_mt_zenger-alg_tran_mt_zenger-0--1.log`

## 插件启动

注册路由
判断f2插件是否注册成功    
m_lpCallWorker  是个什么线程
通过m_lpAdapterManager获取到所有的适配对象
    设置适配的依赖：数据管理器、消息管理器、
那adapter_manager依赖micro插件   一个插件启动的时候OnStart()，去AddPlugin()

```c++
/// 启动
void CAdapterManagerSvrImpl::OnStart(PFOnSetTimeOut pfOnSetTimeOut)
{
    if (pfOnSetTimeOut)
        pfOnSetTimeOut(5000);

    // 向路由插件注册
    RegSvr();

    if (!m_lpF2Core)
    {
        printf("[Error:] f2core plugin is null \n");
        return;
    }
    if (m_lpCallWorker)
        m_lpCallWorker->Start();
    // 此时各插件已经初始化成功，可以获取所需插件实例，获取适配器所需插件实例名称，依据插件实例名称获取插件实例
    const AdaptersList &adapters = m_lpAdapterManager->adapters();
    for (AdaptersList::const_iterator it = adapters.begin(); it != adapters.end(); ++it)
    {
        LogDebug("设置适配[" << it->first << "]的依赖");
        DataManager *data_manager = (it->second)->data_manager();
        if (data_manager)
        {
            if (SetDataManagerDepend(data_manager->plugin_names()))
            {
                // 将插件管理器赋值给适配器数据管理器，适配器数据管理器依赖插件来进行数据管理
                data_manager->set_plugin_manager(this);
            }
            else
            {
                return;
            }
            // 启动适配器数据向UFT数据更新线程
            m_lpUFTDataUpdater->Start();
            m_lpUFTDataUpdater->RegisterData(data_manager);
        }

        MessageManager *message_manager = (it->second)->message_manager();
        if (message_manager)
        {
            if (SetDataManagerDepend(message_manager->plugin_names()))
            {
                message_manager->set_plugin_manager(this);
            }
            else
            {
                return;
            }
        }

        LogDebug("设置适配[" << it->first << "]的依赖结束");
    }

    if (m_bIsFrontAdapter)
    {
        LogFlow("启动前置适配");
        m_lpAdapterThread->Start();

        LogFlow("启动前置适配线程池,线程数为:" << m_iFATThreadNum);
        m_lpFAThreadPool->Start();

        m_vctFATFunctions = CGlobalStorage::GetInstance()->GetFATFunctions();
        LogFlow("前置适配需转换功能号列表大小为" << m_vctFATFunctions.size());
    }
}
```

## 消息管理器

MessageManager  =>  std::vector<MessageReceiver*> receivers_;

类属性：MessageReceiver_MicroSvrMC

创建消息接收器push到接收器数组，接收器的名称为：class_name + "@" + inttostr(idx)
如果配置了name属性，name更新为name属性，如SMP

所以现在SMP消息接收器，只有一个，name为SMP,IDX=0,消息管理器就是this?(set_message_manager)

=>  读取message file   =>  也就是收到什么消息调什么函数，适配还是proc啥的

```c++
void MessageManager::InitializeMessage(const std::string& filename, Status* status) {}
```

```c++
void MessageManager::Initialize(xml_node<>* init_node, Status* init_status) {
    LogDebug("MessageManager::Initialize begin.");
    xml_attribute<>* attribute = init_node->first_attribute("dispatch_thread_num");
    dispatch_thread_num_ = DEFAULT_THREAD_POOL_SIZE;
    //线程数量改为从alg_tran_mt.xml中获取
    dispatch_thread_num_ = CGlobalStorage::GetInstance()->GetAdapterDispatchThreadNum();
    LogDebug("MessageManager::dispatch_thread_num_:" << dispatch_thread_num_);
    // dispatch_thread_pool_ = new CThreadPool(this, dispatch_thread_num_);
    xml_node<>* node = init_node->first_node("receiver");
    CHECK_NODE(init_node, node, "receiver", init_status);

    int idx = 0;
    while (NULL != node) {
        LogDebug("正在解析处理第[" << idx << "]个适配消息接收器对象");
        attribute = node->first_attribute("class");
        CHECK_ATTRIBUTE(node, attribute, "class", init_status);
        string class_name = null_safe(attribute->value());
        // typedef HandlerManager<MessageReceiver, CreateMessageReceiver> MessageReceiverManager;
        MessageReceiver* receiver = MessageReceiverManager::GetInstance()->GetHandler(class_name);

        if (!receiver) {
            CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "无法创建适配器消息接收器对象" + class_name);
            return;
        }

        receivers_.push_back(receiver);
        if (!receiver->plugin_name().empty()) {
            plugin_names_.insert(receiver->plugin_name());
        }

        std::string name = class_name + "@" + inttostr(idx);
        attribute = node->first_attribute("name");
        if (attribute) {
            name = null_safe(attribute->value());
            if (name.empty()) {
                CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "第[" + inttostr(idx) + "]个适配器消息接收器对象属性[name]为空");
                return;
            }
        } 

		receiver_name_map_.insert(std::make_pair(name, receivers_.size() - 1));
        LogDebug("第[" << idx << "]个适配器消息接收器对象命名为[" << name << "]");

        attribute = node->first_attribute("default");
        if (NULL != attribute && pchar_to_string(attribute->value()) == "true") {
            if (default_receiver_idx_ < 0) {
                default_receiver_idx_ = idx;
                LogDebug("设置适配器消息接收器对象[" << name << "]为默认");
            } else {
                CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "已设置适配器消息接收器对象[" + name + "]为默认, 不要重复设置");
                return;
            }
        }

        receiver->set_name(name);
        receiver->set_idx(idx);
        receiver->set_message_manager(this);
        receiver->Initialize(node, init_status); 
        if (STATUS_OK != init_status->error_no) {
            CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "适配器消息接收器对象[" + name + "]初始化失败[" + init_status->error_info + "]");
            return;
        }

        ++idx;
        node = node->next_sibling("receiver");
    }

    if (default_receiver_idx_ < 0 ) {
        if (receivers_.size() > 1) {
            CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "适配器消息接收器配置超过一个时必须指定默认");
            return;
        } else {
            default_receiver_idx_ = 0;
        }
    }
    attribute = init_node->first_attribute("file");
    CHECK_ATTRIBUTE(init_node, attribute, "file", init_status);
    file_ = attribute->value();

    string file = kAdaptersPath + file_;
    InitializeMessage(file, init_status);

    LogDebug("MessageManager::Initialize end.");
}
```



## 订阅逻辑

判断mc_client_是否初始化成功  =>

创建一个订阅者     =>  创建订阅者失败，创建主题重订阅线程

订阅消息  => 


```c++
void MessageReceiver_MC::Subscribe(Status* status) {
    LogDebug("MessageReceiver_MC::Subscribe begin.");

    // 创建订阅者
    if (!mc_client_) {
        CHANGE_STATUS_LOG(status, STATUS_ERROR_INTERNAL, "SID_MCCLIENTAPI 插件实例为空");
        return;
    }
   
    subscriber_ = CreateSubscribe();
    if (NULL == subscriber_) {
        retry_thread_ = CMcRetryThread::GetInstance(mc_client_, subscriber_, this);
        if (retry_thread_) {
            retry_thread_->Start();
        } else {
            LogError("创建主题重订阅线程失败");
        }
        return;
    }

    OnSubscriberCreated();
    if (retry_thread_) {
        retry_thread_->Start();
    }
    LogDebug("MessageReceiver_MC::Subscribe end.");
}
```

### mc_client的初始化

mc_client_什么时候初始化的 IMCClient* mc_client_;   =>  一个插件如果要用到mc，就会初始化一个mc对象

IMCClient这个类是在src不存在，来源于mc的so吧
```c++
void MessageReceiver_MicroSvrMC::set_plugin_manager(PluginManager* _plugin_manager) {
    plugin_manager_ = _plugin_manager;
    mc_client_ = (IMicroSvrCall*)plugin_manager_->GetPlugin(plugin_name_);
    esb_message_factory_ = (IESBMessageFactory*)plugin_manager_->GetPlugin(SID_ESB_MESSAGEFACTORY);
    pack_svr_ = (IF2PackSvr*)plugin_manager_->GetPlugin(SID_F2PACKSVR);
    subcallback_->set_esb_message_factory(esb_message_factory_);
    subcallback_->set_receiver(this);
}
```


### 创建一个订阅者

调mc的接口，创建一个订阅者：NewSubscriber(subcallback_, (char*)subscriber_name_.c_str(), 30000);

订阅的时候弄个回调函数是干啥（set_plugin_manager里设置的），订阅者的名称就是来源于adapter配置文件吧

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

### 订阅mc主题

subscriber_是一个mc提供的接口对象，GetTopic获取mc服务端的所有主题消息（mcapi_plugin_interface.h）

然后遍历本地订阅的主题，订阅在mc确实存在的主题

为啥这还要再启动一次retry_thread_线程,这个类CMicroSvrRetryThread的start()函数可以再看下

```c++
void MessageReceiver_MicroSvrMC::OnSubscriberCreated() {
    if (!subscriber_)
    {
        LogError("消息指针subscriber_为空");
        return ;
    }
    IF2UnPacker* unpacker = subscriber_->GetTopic(false, 3000);
    std::set<std::string> valid_topics;
	/*lint -e{9119}*/
    while (!unpacker->IsEOF()) {
        valid_topics.insert(null_safe(unpacker->GetStr("TopicName")));
        unpacker->Next();
    }
    Messages* messages = message_manager_->messages(this->idx());
    if (NULL == messages) {
        LogFlow("没有需要订阅的消息");
        return;
    }

    for (Messages::const_iterator it_message = messages->begin(); 
            it_message != messages->end(); ++it_message) {
        Message_MC* message = dynamic_cast<Message_MC*>(it_message->second);

		if (NULL == message)
		{
			LogError("消息指针message为空");
			return ;
		}
        const Message_MC::McTopics& topics = message->topics();
        Message_MC::McTopics::const_iterator it = topics.begin();
        for (; it != topics.end(); ++it) {
            if (valid_topics.count(it->first) == 0) {
                LogError("消息中心不存在主题[" << it->first << "], 跳过");
                continue;
            }
            if (it->second.size() > 0) {
                Message_MC::McTopicFilters::const_iterator fit = it->second.begin();
                for (; fit != it->second.end(); ++fit) {
                    McTopicFilter* filter = (McTopicFilter*)(*fit);
                    this->Subscribe(it->first, filter);
                }
            } else {
                this->Subscribe(it->first, NULL);
            }
        }
    }
}
```

线程订阅逻辑ThreadSubScribe()和发送消息的逻辑也再看下：`message_receiver.cpp` , `data_updater.cpp`

接收器的订阅者名称就是adapters中的subscriber

```c++
void MessageReceiver_MicroSvrMC::Initialize(xml_node<>* init_node, Status* init_status) {
    LogDebug("MessageReceiver_MicroSvrMC::Initialize begin.");
    xml_attribute<>* attribute = init_node->first_attribute("subscriber");
    CHECK_ATTRIBUTE(init_node, attribute, "subscriber", init_status);
    subscriber_name_ = attribute->value();
    attribute = init_node->first_attribute("sub_system_no");
    if (NULL != attribute && NULL != attribute->value()) {
        sub_system_no_ = atoi(attribute->value());
    } else {
        sub_system_no_ = -1;
    }
    LogDebug("MessageReceiver_MicroSvrMC::Initialize end.");
}
```