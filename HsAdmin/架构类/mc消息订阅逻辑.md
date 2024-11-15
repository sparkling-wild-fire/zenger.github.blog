# mc��Ϣ�����߼�

## ΢������api

microsvr_interface.h

## �������˳��

AdapterManager::Initialize begin

Adapter::Initialize begin
```txt
Adapter::Initialize begin.
    subsys_no:1003
    SMP������û����������.
MessageManager::Initialize begin.
    MessageManager::dispatch_thread_num_:8
    ���ڽ��������[0]��������Ϣ����������
    ��[0]����������Ϣ��������������Ϊ[MessageReceiver_MicroSvrMC@0]
MessageReceiver_MicroSvrMC::Initialize begin
MessageReceiver_MicroSvrMC::Initialize end.
MessageManager::InitializeMessage begin../adapters/SMP/message.xml
Message_MC::Initialize begin.
    ��������[smp.flow.bubbleremind]
Message_MC::Initialize end.
Message_MC::Initialize begin.
    ��������[smp.hq.status]
......
[CRES|message_manager.cpp|InitializeMessage|307#139706377803584]MessageManager::InitializeMessage end.
[CRES|message_manager.cpp|Initialize|153#139706377803584]MessageManager::Initialize end.
Ȼ����ǳ�ʼ�����ܺŵ��õ���Щ������
```

���������־��`2024-11-05-alg_tran_mt_zenger-alg_tran_mt_zenger-0--1.log`

## �������

ע��·��
�ж�f2����Ƿ�ע��ɹ�    
m_lpCallWorker  �Ǹ�ʲô�߳�
ͨ��m_lpAdapterManager��ȡ�����е��������
    ������������������ݹ���������Ϣ��������
��adapter_manager����micro���   һ�����������ʱ��OnStart()��ȥAddPlugin()

```c++
/// ����
void CAdapterManagerSvrImpl::OnStart(PFOnSetTimeOut pfOnSetTimeOut)
{
    if (pfOnSetTimeOut)
        pfOnSetTimeOut(5000);

    // ��·�ɲ��ע��
    RegSvr();

    if (!m_lpF2Core)
    {
        printf("[Error:] f2core plugin is null \n");
        return;
    }
    if (m_lpCallWorker)
        m_lpCallWorker->Start();
    // ��ʱ������Ѿ���ʼ���ɹ������Ի�ȡ������ʵ������ȡ������������ʵ�����ƣ����ݲ��ʵ�����ƻ�ȡ���ʵ��
    const AdaptersList &adapters = m_lpAdapterManager->adapters();
    for (AdaptersList::const_iterator it = adapters.begin(); it != adapters.end(); ++it)
    {
        LogDebug("��������[" << it->first << "]������");
        DataManager *data_manager = (it->second)->data_manager();
        if (data_manager)
        {
            if (SetDataManagerDepend(data_manager->plugin_names()))
            {
                // �������������ֵ�����������ݹ����������������ݹ���������������������ݹ���
                data_manager->set_plugin_manager(this);
            }
            else
            {
                return;
            }
            // ����������������UFT���ݸ����߳�
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

        LogDebug("��������[" << it->first << "]����������");
    }

    if (m_bIsFrontAdapter)
    {
        LogFlow("����ǰ������");
        m_lpAdapterThread->Start();

        LogFlow("����ǰ�������̳߳�,�߳���Ϊ:" << m_iFATThreadNum);
        m_lpFAThreadPool->Start();

        m_vctFATFunctions = CGlobalStorage::GetInstance()->GetFATFunctions();
        LogFlow("ǰ��������ת�����ܺ��б��СΪ" << m_vctFATFunctions.size());
    }
}
```

## ��Ϣ������

MessageManager  =>  std::vector<MessageReceiver*> receivers_;

�����ԣ�MessageReceiver_MicroSvrMC

������Ϣ������push�����������飬������������Ϊ��class_name + "@" + inttostr(idx)
���������name���ԣ�name����Ϊname���ԣ���SMP

��������SMP��Ϣ��������ֻ��һ����nameΪSMP,IDX=0,��Ϣ����������this?(set_message_manager)

=>  ��ȡmessage file   =>  Ҳ�����յ�ʲô��Ϣ��ʲô���������仹��procɶ��

```c++
void MessageManager::InitializeMessage(const std::string& filename, Status* status) {}
```

```c++
void MessageManager::Initialize(xml_node<>* init_node, Status* init_status) {
    LogDebug("MessageManager::Initialize begin.");
    xml_attribute<>* attribute = init_node->first_attribute("dispatch_thread_num");
    dispatch_thread_num_ = DEFAULT_THREAD_POOL_SIZE;
    //�߳�������Ϊ��alg_tran_mt.xml�л�ȡ
    dispatch_thread_num_ = CGlobalStorage::GetInstance()->GetAdapterDispatchThreadNum();
    LogDebug("MessageManager::dispatch_thread_num_:" << dispatch_thread_num_);
    // dispatch_thread_pool_ = new CThreadPool(this, dispatch_thread_num_);
    xml_node<>* node = init_node->first_node("receiver");
    CHECK_NODE(init_node, node, "receiver", init_status);

    int idx = 0;
    while (NULL != node) {
        LogDebug("���ڽ��������[" << idx << "]��������Ϣ����������");
        attribute = node->first_attribute("class");
        CHECK_ATTRIBUTE(node, attribute, "class", init_status);
        string class_name = null_safe(attribute->value());
        // typedef HandlerManager<MessageReceiver, CreateMessageReceiver> MessageReceiverManager;
        MessageReceiver* receiver = MessageReceiverManager::GetInstance()->GetHandler(class_name);

        if (!receiver) {
            CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "�޷�������������Ϣ����������" + class_name);
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
                CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "��[" + inttostr(idx) + "]����������Ϣ��������������[name]Ϊ��");
                return;
            }
        } 

		receiver_name_map_.insert(std::make_pair(name, receivers_.size() - 1));
        LogDebug("��[" << idx << "]����������Ϣ��������������Ϊ[" << name << "]");

        attribute = node->first_attribute("default");
        if (NULL != attribute && pchar_to_string(attribute->value()) == "true") {
            if (default_receiver_idx_ < 0) {
                default_receiver_idx_ = idx;
                LogDebug("������������Ϣ����������[" << name << "]ΪĬ��");
            } else {
                CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "��������������Ϣ����������[" + name + "]ΪĬ��, ��Ҫ�ظ�����");
                return;
            }
        }

        receiver->set_name(name);
        receiver->set_idx(idx);
        receiver->set_message_manager(this);
        receiver->Initialize(node, init_status); 
        if (STATUS_OK != init_status->error_no) {
            CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "��������Ϣ����������[" + name + "]��ʼ��ʧ��[" + init_status->error_info + "]");
            return;
        }

        ++idx;
        node = node->next_sibling("receiver");
    }

    if (default_receiver_idx_ < 0 ) {
        if (receivers_.size() > 1) {
            CHANGE_STATUS_LOG(init_status, STATUS_ERROR_INTERNAL, "��������Ϣ���������ó���һ��ʱ����ָ��Ĭ��");
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



## �����߼�

�ж�mc_client_�Ƿ��ʼ���ɹ�  =>

����һ��������     =>  ����������ʧ�ܣ����������ض����߳�

������Ϣ  => 


```c++
void MessageReceiver_MC::Subscribe(Status* status) {
    LogDebug("MessageReceiver_MC::Subscribe begin.");

    // ����������
    if (!mc_client_) {
        CHANGE_STATUS_LOG(status, STATUS_ERROR_INTERNAL, "SID_MCCLIENTAPI ���ʵ��Ϊ��");
        return;
    }
   
    subscriber_ = CreateSubscribe();
    if (NULL == subscriber_) {
        retry_thread_ = CMcRetryThread::GetInstance(mc_client_, subscriber_, this);
        if (retry_thread_) {
            retry_thread_->Start();
        } else {
            LogError("���������ض����߳�ʧ��");
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

### mc_client�ĳ�ʼ��

mc_client_ʲôʱ���ʼ���� IMCClient* mc_client_;   =>  һ��������Ҫ�õ�mc���ͻ��ʼ��һ��mc����

IMCClient���������src�����ڣ���Դ��mc��so��
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


### ����һ��������

��mc�Ľӿڣ�����һ�������ߣ�NewSubscriber(subcallback_, (char*)subscriber_name_.c_str(), 30000);

���ĵ�ʱ��Ū���ص������Ǹ�ɶ��set_plugin_manager�����õģ��������ߵ����ƾ�����Դ��adapter�����ļ���

```c++
IMicSvrSubscriber* MessageReceiver_MicroSvrMC::CreateSubscribe() {
    if (mc_client_)
    {
        if (NULL == subscriber_) {
            subscriber_ = mc_client_->NewSubscriber(subcallback_, (char*)subscriber_name_.c_str(), 30000);
        }
        if (NULL == subscriber_) {
            // �޷����������߲���retry�߳����ԣ��������������ݼ������̽�������
            string log = "�޷�����������[" + subscriber_name_ + "]������ԭ��:";
            log += mc_client_->GetMCLastError();
            log += ", �Ժ�����";
            //CHANGE_STATUS_LOG(status, STATUS_ERROR_INTERNAL, log);
            LogError(log);
            return NULL;
        }
    }
    else
    {
        LogError("mc_client_ΪNULL");
    }
    return subscriber_;
}
```

### ����mc����

subscriber_��һ��mc�ṩ�Ľӿڶ���GetTopic��ȡmc����˵�����������Ϣ��mcapi_plugin_interface.h��

Ȼ��������ض��ĵ����⣬������mcȷʵ���ڵ�����

Ϊɶ�⻹Ҫ������һ��retry_thread_�߳�,�����CMicroSvrRetryThread��start()���������ٿ���

```c++
void MessageReceiver_MicroSvrMC::OnSubscriberCreated() {
    if (!subscriber_)
    {
        LogError("��Ϣָ��subscriber_Ϊ��");
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
        LogFlow("û����Ҫ���ĵ���Ϣ");
        return;
    }

    for (Messages::const_iterator it_message = messages->begin(); 
            it_message != messages->end(); ++it_message) {
        Message_MC* message = dynamic_cast<Message_MC*>(it_message->second);

		if (NULL == message)
		{
			LogError("��Ϣָ��messageΪ��");
			return ;
		}
        const Message_MC::McTopics& topics = message->topics();
        Message_MC::McTopics::const_iterator it = topics.begin();
        for (; it != topics.end(); ++it) {
            if (valid_topics.count(it->first) == 0) {
                LogError("��Ϣ���Ĳ���������[" << it->first << "], ����");
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

�̶߳����߼�ThreadSubScribe()�ͷ�����Ϣ���߼�Ҳ�ٿ��£�`message_receiver.cpp` , `data_updater.cpp`

�������Ķ��������ƾ���adapters�е�subscriber

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