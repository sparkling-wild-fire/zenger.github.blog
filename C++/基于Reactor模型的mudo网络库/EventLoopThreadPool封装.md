# EventLoopThreadPool��װ

EventLoopThreadPool���Ƕ�EventLoopThread�Ĺ����ˣ���Ҫ��EventLoopThread�ĳ�ʼ�����̸߳��ز��ԣ����Ĳ�����ѯ�ķ�ʽ

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250102150822.png" alt="20250102150822" width="850">

�����̻߳ᴴ��һ��baseEventLoop,���������̳߳�ʱ�����baseEventLoop��ȼ���listenfd��Ҳ�����connectionfd��

## EventLoopThreadPool

EventLoopThreadPool����ɳ�ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250102152407.png" alt="20250102152407" width="850">

���У�baseLoop�����̴߳�����baseLoop,Ҳ�����ڷ������������̳߳�ʱ�����baseLoop��ȼ���listenfd��Ҳ�����connectionfd��

## ����

�������EventLoopThread,ÿ��epollerһ��ʼ�������ִ��epoll_wait()��������״̬������ռ��CPU,���ǵȴ����߳���epoll�е�wakeupfdд�����ݣ�
����ϵͳ�Ż�֪ͨepoll�������߳�

```c++
void EventLoopThreadPool::start(const ThreadInitCallback &cb)
{
    started_ = true;
    // ��������˶���̣߳��ͻ������ѭ��������������
    for (int i = 0; i < numThreads_; ++i)
    {
        char buf[name_.size() + 32];
        snprintf(buf, sizeof buf, "%s%d", name_.c_str(), i);
        EventLoopThread *t = new EventLoopThread(cb, buf);
        threads_.push_back(std::unique_ptr<EventLoopThread>(t));
        loops_.push_back(t->startLoop()); // �ײ㴴���̣߳���һ���µ�EventLoop�������ظ�loop�ĵ�ַ
    }
    // ���������ֻ��һ���̣߳�������baseloop
    if (numThreads_ == 0 && cb)
    {
        cb(baseLoop_);
    }
}
```

## �̷ַ߳�

�ڵ��߳�ģʽ�£�baseLoop����connectionfd,���߳�ģʽ�£����߳�����ѯ�ķ�ʽ��connectionfd���뵽���̵߳�epoll

```c++
// ��������ڶ��߳��У�baseLoop_Ĭ������ѯ�ķ�ʽ����channel��subloop
EventLoop* EventLoopThreadPool::getNextLoop()
{
    EventLoop *loop = baseLoop_;
    if (!loops_.empty()) // ͨ����ѯ��ȡ��һ�������¼���loop
    {
        loop = loops_[next_];
        ++next_;
        if (next_ >= loops_.size())
        {
            next_ = 0;
        }
    }
    return loop;    // ���û�����ö���̣߳��Ǿͷ���mianloop��������fd������mainloop��
}
```