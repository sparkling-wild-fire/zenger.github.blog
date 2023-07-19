# algoserver�ֱ�

## �ṹ��

MsgDealThread.h

1. ��Ϣ�ṹ��
```C++
struct TReqMsg
{	
public:
    TReqMsg(void *lpData, int nLength)
    {
        pDateBuf = NULL;
        Buflen = nLength;
        if (lpData)
        {
            pDateBuf = (void*)malloc(Buflen);
            if(pDateBuf == NULL )
            {
                LogError("SubscriberMsg�����ڴ�ռ�ʧ��");
            }
            else
            {
                memcpy(pDateBuf,lpData,Buflen);
            }
        }
        
        iMsgNo = 0;
        m_eMsgType = MsgType_UnDefine;
        m_pTimeTask = NULL;
    }

    ~TReqMsg()
    {
        try
        {
            if (pDateBuf)
            {
                free(pDateBuf);
                pDateBuf = NULL;
            }
        }
        catch (...)
        {

        }
    }
    //����<<
    friend std::ostream& operator<<(std::ostream &out, TReqMsg* p_obj);

    std::string sTopicName;     // 1.������
    void *pDateBuf;							// 2.�������ݣ�ʹ��UnPack���
    int Buflen;									//���峤��
    std::string sSchemeID;			//����ID
    int iMsgNo;
    EReqMsgType m_eMsgType;         // 3.��Ϣ����
    void* m_pTimeTask;    // 4.��Ϣ��Ҫ�����������񣬶�ʱ�������
};
```

2. �߳���

���룺ȫ�ֵ���Ϣ��������Ϣ������

```C++
class CSchemeCreateThread:public CThread
{
public:
    long Run();
    static const int WAIT_TIME = 10;
    int AddMsg(TReqMsg *msg);
private:
    CThreadMutex m_MsgMutex;
    std::list<TReqMsg*> m_MsgList;  //ȫ�ֵ���Ϣ����
    std::map<std::string, int> m_schemeDeleteTime;  //����ɾ���ȴ�ʱ�� 
};

//��Ϣ�����̣߳��������Խ���ƽ̨�ĸ�����Ϣ
class CMsgDealThread:public CThread
{
    public:
        CMsgDealThread(const char *sName);   // m_schemeCreateThread = new CSchemeCreateThread();
        virtual ~CMsgDealThread();
    public:
        long Run();
    private:
        std::list<TReqMsg*> m_MsgList;  //ȫ�ֵ���Ϣ����
        CThreadMutex m_MsgListMutex; 		//��Ϣ������
    public:
        int AddMsg(TReqMsg *Msg);
        std::string m_sThreadName;
        int m_iMsgNo;
        CEvent m_event_run;         //�߳������ź�
        CSchemeCreateThread* m_schemeCreateThread;
};
```

## ����

- algo
  - MsgDealThread.cpp
    - CMsgDealThread::Run()

```C++
long CMsgDealThread::Run()
{
    // 1. ȡ��Ϣ����while
    while(!IsTerminated())
    {
        // 2.�Գ�ʼ��ʱ���ز��Բ�����������ɲ��ܴ����½�������Ϣ��g_InitUserParamsIsFinished=1��ʾ�������
        bool bContinue = false;
        {
            CAutoMutex _autolock(g_IsDealMsgLock);
            if(g_InitUserParamsIsFinished == 0)
            {
                bContinue = true;
            }
        }
        if (bContinue)
        {
            FBASE2::SleepX(10);
            continue;
        }
        // 3. �Ӷ�������ȡ��Ϣ��Ϊ�ճ�ʱ�ȴ�
        if(m_MsgList.size() == 0)
        {
//            FBASE2::SleepX(10);
//        	  continue;
            if (EVENT_OK != m_event_run.Wait(100)) // �ȴ���ʱʱ��100ms
            {
                continue;
            }
        }
        // 4. �е���Ϣ������һ��һ��ȡ��������һ��һ��ȡ
        std::list<TReqMsg*> temp_msg_list;
        {	
            CAutoMutex _autolock(&m_MsgListMutex);
            m_MsgList.swap(temp_msg_list);
            m_event_run.Reset();
        }
        // 5. ��Ϣ����
        std::list<TReqMsg*>::iterator iter = temp_msg_list.begin();
        for(; iter != temp_msg_list.end(); ++iter)
        {
            TReqMsg *lpMsg = *iter;
            // ��Ϣ����
            // ...
            // 5.1 ������Ϣ��������ͬ����
            if(lpMsg->sTopicName == MSGTYPE_ALGOJR_DAILY_INIT){
                // ...
                // 5.2 ������Ϣ�����½�������ȡ������С���߳̽��д���
                CAlgoDealThread *lpDealThread = g_AlgoDealThreadPool->GetMinDealThread();
                if(lpDealThread)
                {
                    // ...
                    CAlgoOrder *lpOrder = lpDealThread->CreateScheme(lpMsg->sSchemeID);    // ��������
                }
            }
            if(...){
                // ...
            }
            // 6����Ϣ����󣬽�����һ������
            {
                //����ʹ��ȫ�ַ���������������֤��������ɾ������ô�ڷ���ɾ����ʱ�򣬱���Ը������м�����
                CAutoMutex _autolock(g_pOrderIndexLock);										
                CAlgoOrder *lpOrder = FindOrderBySchemeID_NoLock(lpMsg->sSchemeID);
                if(lpOrder)
                {
                	LogDebug("ȫ����Ϣ�ɹ��Ӹ�����" << lpMsg->sSchemeID);
                    // g_AlgoDealThreadPool->AddMsg(ReqMsg, m_iThreadNo);�̳߳ص�һ����������߼�
                    // �����µ���Ϣ����m_ReqMsgList
                    // �����������߳�Ҳ���̳߳ص���
                    lpOrder->AddMsg(lpMsg);     // �ּӵ�m_MsgList��
                } 
                // 6.1 ɾ����Ϣ
                delete lpMsg;
                continue;
            }
            // 7. Ҳ����ִ��һЩ��ʱ����
            uint64 timetmp = GetMill();
            if (timetmp - m_lLastDoRutineTime >= 10)
            {
                // ...
            }
        }
    }
}

int CAlgoDealThread::AddMsg(TReqMsg* ReqMsg)
{
    CAutoMutex _autolock(&m_pReqMsgListLock);
    // ReqMsg => ������Ϣ:����[asset.algo.recover_scheme], ���[1]]  ????
    LogDebug("�߳�" << m_iThreadNo << "�յ�"<<ReqMsg<< "]");   

    m_ReqMsgList.push_back(ReqMsg);   // ��Ϣ����ƽ̨����
    m_event_run.Set();

    return RET_OK;
}
```


������ת��

- algo
  - AlgoDealThread.cpp
    - Run()