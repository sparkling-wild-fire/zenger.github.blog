# Otade����������̨�Խ�SMP

O3����̫�����Խ����еĽ���ģ�������������ɵ�Otrade�ͻ���

## O3���ݴ���

��̨�������;��ͬһ�ݴ��룬�������ڲ�ͬ�ķ�֧�Ͽ����������󽫴�����кϲ�

### O3���ݱ���

1. ��̬���ݣ���ί�з����ֱ��ͨ���ű�����

2. ��̬���ݣ���֤ȯѯ�۱�����Otradeʱ��ͨ��F2�����ҳ��ѯO3��
   - ÿ��������Ҫ��յ����ݣ�������ҪƵ����ѯ�����ݣ���ί�б��½�һ�Ŷ�Ӧ���ڴ�������ݵ��뵽�ڴ����ݿ���
   - ��Ҫ�־û������ݣ����½�ʵ������ݴ�ʵ���������;��
     - ͬʱд�ڴ���ʵ���
     - hsdb�����ȡ�����ļ��е�����ʱ���
   - ��ѯƵ�ʱȽϵͣ�ֻ����ʵ����簴ť��ֻ��ҳ���ʱ��Ż���

### O3����ͬ��

1. ��������,�������Ƶ�����ͨ�����٣����Ի���Ҫ��ȥ����һ��O3,������ص�����sql
2. ����ͬ��������ô���������������⣩
3. ���߽�ϣ�����ָ���ָ�����ر���Ҫ�����񣬶�ʱͬ��������Ҫ��ֹ��ָ��©����

## �Խ�SMP������

### ���䴦��

Otarde�Խ��ⲿϵͳ����Ҫ���ⲿϵͳ����һ���ⲿϵͳ�ţ��������־����ǶԽӵ���һ��ϵͳ�����ϵͳ����Ҫ�����ڵ�����ʱ����·��

Otrade�ڲ���ͨ������OSPFЭ��ȥ����ͬģ���µķ���ģ�ÿ�������Ӧһ��ID,�Խ�ÿ��ϵͳ��Ҫ����һ���ŶΣ��磨402000~403999��������ID���ںŶ��ڵĶ��ǶԽ�SMP�ķ���

### �̻߳���

Ϊ��ֹsmp������࣬������ͨģ����̣߳���Proc�̳߳���������������̣߳�ÿ���߳�������smp�Ĵ���ֻ���������߳���������

| �߳�����     | 	�����߳��� |     ģ��Ӣ����  |   ģ��������   | ��ע     | so   |
|-----------|--------|  ---|---|--------|----------------------|
| 30	       | 8      |  smp_access  |    SMP����  | �Խ�SMP��صĲ�ѯ�����ýӿڣ����ܺŶ�404000~404099 | s_ls_smp_accessflow  | 
| 31	       | 8      |smp_access  |    SMP����  | smp����Ϣ���ƴ��� | s_ls_smp_messagepush | 
| 32        | 8      |smp_access  |    SMP����  | SMP��ص�OT��Ϣ�����ʽΪstp.smp.xxx | s_ls_smp_messageaccess | 

ÿ���̶߳�Ӧһ������ģ�飬ÿ��ģ������һ��so��Otrade��������ʱ����so�еķ�����ص�Proc�̳߳ص��߳����У�

������ĳһ������ʱ������·��ɸѡ���Ὣ��ε��÷ַ���Proc��Proc���һ���ַ�����Ӧ���߳����С�


### �Խ�SMP΢����

smp������ע�ᵽzookeeper�ϣ�Otrade��Ҫͨ��΢����������ͬһ��zk��ȥ��smp�ķ��񣬵�����ʱ����Ҫָ��GSV:
- group:ͬһ�����ܺŵĲ�ͬʵ��
- service:�������ڷֲ�ʽ����
- version:����İ汾��

### SMP����

smp����Ϣ���͵�mc��mt����smp���͵���Ϣ�����յ���Ϣ����mc��Ϣת����F2����,ȡF2���е�message_body�������书�ܺŽ���ֵ��ת����������������͵�mt��smp��Ϣ�����̣߳�
mt���������жϣ�����Ǳ�����ֱ���˳���
Ȼ��stp��Ϣͨ��PubMsgByPacker()���͵�mc, mc����Ϣ���͵��ͻ���, �ͻ��˽��������еĹ����ֶΣ��ж���������費��Ҫ���գ�����Ա���룩

```C++
// ��Ϣ���ķ�������Ϣ
struct MCData{
    char* topic;
    void* data;
    int length;
    int sec;
    int usec;
    uint64 deliveryTag;//��ʾ��Ϣ���к�
};

IF2UnPacker* unpacker = pack_svr_->GetUnPacker(mc_data->data, mc_data->length);
```


������Ϣ������Ϣ������ֶ�message_body, ����ȡ��ʱ��Ҳȡ����ֶνṹ��message_body:
```txt
@unpacker = lpPackService->GetUnPacker(p_msg_body,pi_msg_body);
// ������ʱʱ��30s
iReturnCode = lpContext->PubMsgByPacker(@topic_name,@unpacker,CNST_TIMEOUT);
```

mc���Զ����̣߳�
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
				LogError("��������" << topic_name << "ʧ�ܣ�ԭ��" << mc_client_->GetErrMsg(iRet) << ", �Ժ�����");
            tmp.push_back(std::make_pair(topic_name, sub_param));
        }
        else
        {
            if (sub_param) {
                LogInfo("��������" << topic_name << "�ɹ�, ��������:" << sub_param);
            } else {
                LogInfo("��������" << topic_name << "�ɹ�");
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
<!--mt��Ϣ����-->
<adapter name="SMP" version="20240408" subsys_no="1003">
<disposer file="SMP/disposer.xml"/>
<message file="SMP/message.xml">
    <receiver class="MessageReceiver_MicroSvrMC" subscriber="otrade_smp_msg" />
</message>
</adapter>
```

adapter���������ߣ�
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


#### ע������

1. ����smp������ʱ����Ҫ��mcע�ᵽzookeeper��

2. ������ȷ�Ĺ����ֶΣ��紥����Ʊ�ɽ�ͳ�ƺ󣬻ᷢ5����Ϣ������ֻ�в���Ա�ֶβ�ͬ

3. HUIǰ����Ϣ���棺smpweb����ǰ�˻��Ƚ�������Ϣ����������6s����Ϣ����ˢ��һ�Σ�ΪɶҪ��Ƶ����