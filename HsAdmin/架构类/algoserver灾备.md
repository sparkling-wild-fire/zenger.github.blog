# algoserver灾备

## 结构体

MsgDealThread.h

1. 消息结构体
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
                LogError("SubscriberMsg申请内存空间失败");
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
    //重载<<
    friend std::ostream& operator<<(std::ostream &out, TReqMsg* p_obj);

    std::string sTopicName;     // 1.主题编号
    void *pDateBuf;							// 2.包体数据，使用UnPack解包
    int Buflen;									//包体长度
    std::string sSchemeID;			//方案ID
    int iMsgNo;
    EReqMsgType m_eMsgType;         // 3.消息类型
    void* m_pTimeTask;    // 4.消息需要处理其他任务，定时任务对象
};
```

2. 线程类

必须：全局的消息队列与消息队列锁

```C++
class CSchemeCreateThread:public CThread
{
public:
    long Run();
    static const int WAIT_TIME = 10;
    int AddMsg(TReqMsg *msg);
private:
    CThreadMutex m_MsgMutex;
    std::list<TReqMsg*> m_MsgList;  //全局的消息队列
    std::map<std::string, int> m_schemeDeleteTime;  //方案删除等待时间 
};

//消息处理线程，处理来自接入平台的各类消息
class CMsgDealThread:public CThread
{
    public:
        CMsgDealThread(const char *sName);   // m_schemeCreateThread = new CSchemeCreateThread();
        virtual ~CMsgDealThread();
    public:
        long Run();
    private:
        std::list<TReqMsg*> m_MsgList;  //全局的消息队列
        CThreadMutex m_MsgListMutex; 		//消息队列锁
    public:
        int AddMsg(TReqMsg *Msg);
        std::string m_sThreadName;
        int m_iMsgNo;
        CEvent m_event_run;         //线程运行信号
        CSchemeCreateThread* m_schemeCreateThread;
};
```

## 流程

- algo
  - MsgDealThread.cpp
    - CMsgDealThread::Run()

```C++
long CMsgDealThread::Run()
{
    // 1. 取消息队列while
    while(!IsTerminated())
    {
        // 2.略初始化时加载策略参数，加载完成才能处理新建方案消息，g_InitUserParamsIsFinished=1表示加载完成
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
        // 3. 从队列中提取消息，为空超时等待
        if(m_MsgList.size() == 0)
        {
//            FBASE2::SleepX(10);
//        	  continue;
            if (EVENT_OK != m_event_run.Wait(100)) // 等待超时时间100ms
            {
                continue;
            }
        }
        // 4. 有的消息队列是一个一个取，这里是一段一段取
        std::list<TReqMsg*> temp_msg_list;
        {	
            CAutoMutex _autolock(&m_MsgListMutex);
            m_MsgList.swap(temp_msg_list);
            m_event_run.Reset();
        }
        // 5. 消息处理
        std::list<TReqMsg*>::iterator iter = temp_msg_list.begin();
        for(; iter != temp_msg_list.end(); ++iter)
        {
            TReqMsg *lpMsg = *iter;
            // 消息处理
            // ...
            // 5.1 根据消息类型做不同处理
            if(lpMsg->sTopicName == MSGTYPE_ALGOJR_DAILY_INIT){
                // ...
                // 5.2 特殊消息（如新建方案）取负载最小的线程进行处理
                CAlgoDealThread *lpDealThread = g_AlgoDealThreadPool->GetMinDealThread();
                if(lpDealThread)
                {
                    // ...
                    CAlgoOrder *lpOrder = lpDealThread->CreateScheme(lpMsg->sSchemeID);    // 创建方案
                }
            }
            if(...){
                // ...
            }
            // 6，消息处理后，进行下一步操作
            {
                //这里使用全局方案索引的锁来保证方案不被删除。那么在方案删除的时候，必须对该锁进行加锁。
                CAutoMutex _autolock(g_pOrderIndexLock);										
                CAlgoOrder *lpOrder = FindOrderBySchemeID_NoLock(lpMsg->sSchemeID);
                if(lpOrder)
                {
                	LogDebug("全局消息成功扔给方案" << lpMsg->sSchemeID);
                    // g_AlgoDealThreadPool->AddMsg(ReqMsg, m_iThreadNo);线程池的一个处理后续逻辑
                    // 放入新的消息队列m_ReqMsgList
                    // 创建方案的线程也是线程池的吗
                    lpOrder->AddMsg(lpMsg);     // 又加到m_MsgList了
                } 
                // 6.1 删除消息
                delete lpMsg;
                continue;
            }
            // 7. 也可以执行一些定时任务
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
    // ReqMsg => 主题消息:主题[asset.algo.recover_scheme], 编号[1]]  ????
    LogDebug("线程" << m_iThreadNo << "收到"<<ReqMsg<< "]");   

    m_ReqMsgList.push_back(ReqMsg);   // 消息还是平台发的
    m_event_run.Set();

    return RET_OK;
}
```


后续，转到

- algo
  - AlgoDealThread.cpp
    - Run()