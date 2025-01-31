# EventLoopThread��װ

reactorģ�Ͳ�ȡ`one loop per thread`��˼�룬ÿ��EventLoopThread�̶߳�����һ��EventLoop������EventLoop����Ҫ����һ���߳̽��а�

EventLoopThread��ɳ�ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231170520.png" alt="20241231170520" width="850">

## Thread����

����Ҫ��ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231165109.png" alt="20241231165109" width="850">


����Thead�߳���Ҫ�Ǵ���EventLoop��Ϊȷ��EventLoop������ɣ����̲߳��˳�����Ҫͨ���ź������п���

```c++
void Thread::start()  // һ��Thread���󣬼�¼�ľ���һ�����̵߳���ϸ��Ϣ  => Ҳ����ͷ�ļ�����Ķ���
{
    started_ = true;
    sem_t sem;
    sem_init(&sem, false, 0);
    // �����߳�
    // �����ʱ�����߳�ֱ��ִ�����ˣ��������̻߳�ûִ�У�����Ҫ�����ź����������߳������̵߳�ͨ��
    thread_ = std::shared_ptr<std::thread>(new std::thread([&](){    
        // ��ȡ�̵߳�tidֵ
        tid_ = CurrentThread::tid();  
        sem_post(&sem);
        // �����߳����߳�
        func_(); 
    }));
    // �������ȴ���ȡ�����´������̵߳�tidֵ
    sem_wait(&sem);
}
```

## EventLoopThread����

����EventLoop��Thread�Ļ��������ܷ�װEventLoopThread��


EventLoopThread��ɳ�ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231170520.png" alt="20241231170520" width="850">

EventLoopThread�Ĵ�����������ʼ����

```c++
EventLoopThread::EventLoopThread(const ThreadInitCallback &cb, 
        const std::string &name)
        : loop_(nullptr)
        , exiting_(false)
        , thread_(std::bind(&EventLoopThread::threadFunc, this), name)   // this
        , mutex_()
        , cond_()
        , callback_(cb)
{

}
```

�̵߳���ں�����Ҳ����thread_������startʱ������һ�����̣߳���������߳��д���һ��epoll_wait��epoll��

```c++
// �ڵ��������߳��������е�
void EventLoopThread::threadFunc()
{
    EventLoop loop; // ����һ��������eventloop����������߳���һһ��Ӧ�ģ�one loop per thread

    if (callback_)
    {
        callback_(&loop);  // ��loop����������ص�����
    }

    {
        // ����߳�ִ�������ڷ�����Ҫ����,���յ������ǽ�����loop��ʼ��Ҳ����
        std::unique_lock<std::mutex> lock(mutex_);  
        loop_ = &loop;
        cond_.notify_one();  // ֪ͨ���̣߳�Ҫ���loop������ɺ󣬲���׷�ӵ�epoll������
    }

    // �����¼�ѭ����epoll_wait()
    loop.loop();               
    std::unique_lock<std::mutex> lock(mutex_);   
    loop_ = nullptr;    // �����loop�˳��󣬽�loop_��Ϊ��
}
```
