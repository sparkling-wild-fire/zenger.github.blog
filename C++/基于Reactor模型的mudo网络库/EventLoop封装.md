# EventLoop��װ

reactorģ�Ͳ�ȡ`one loop per thread`��˼�룬ÿ��EventLoopThread�̶߳�����һ��EventLoop

## EventLoop

EventLoop�Ƕ�epoller�Ľ�һ����װ��Ŀǰ��������epoller�ĵ������У����ҪӦ���ڸ߲�����������Ҫ��һ����װ������Ҫ��Ա����Ϊ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231144120.png" alt="20241231144120" width="850">

���У�activeChannels��ʾ�����¼���channel��Ҳ����epoll_wait���ص��¼�


### �ص�����

pendingFactors��ʾ����ִ�еĻص�������Դ�������棺
1. activeChannels�󶨵Ļص�
2. �ϲ���׷�ӵ������ص�������Ӧ������ɺ����־��ӡ�ص���buffer�ڴ治��Ŀռ�����ص������ӶϿ�ɾ��һ��channel(main�߳̿��̵߳���)

��Եڶ�������������������߳����߳�׷�ӵĻص�������׷��`pendingFactors`ʱ��Ҫ����

```c++
// ��cb��������У�����loop���ڵ��̣߳�ִ��cb
void EventLoop::queueInLoop(Functor cb)
{
    {
        std::unique_lock<std::mutex> lock(mutex_);    // ���߳�Ҳ���subLoop�ӻص����������Է�����ôʵ�ֵ��أ�
        pendingFunctors_.emplace_back(cb);
    }
    
    // ������Ӧ�ģ���Ҫִ������ص�������loop���߳���
    if (!isInLoopThread() || callingPendingFunctors_) 
    {
        wakeup(); // ����loop�����߳�
    }
}
```

������Ӧ�߳�׷�ӻص�����Ҫ�����̻߳���

��callingPendingFunctors_����˼�ǣ���ǰloop����ִ�лص������ص�ȫ����ִ����ɺ�epoll_wait()�ܹ����̷��أ�ִ���¼���Ļص����罫�����Ӽ���epoll��

### ���ѻ���

�̻߳��ѻ�����ʵ��һ����Ϣ֪ͨ���ƣ���ͨ����EventLoop������һ��ע��ɶ��¼���wakeupChannelʵ�ֵ�,Ϊwakeupfd����ע��ɶ��¼�����ע��ɶ��¼��ص�

tip: ���������Ҫ��4��fd
1. wakeupfd�����ڶ��߳���Ϣ֪ͨ������handleRead()�ص����ǽ�fd�ϵ��ں˻��������ݶ�ȡ����
2. acceptorfd�����ڽ�������connectionfd���뵽epoll������handleRead()�ص����Ǳ���EventLoops
3. connectionfd���ⲿ���ӵ�fd����������ͨ�ţ�����handleRead()�ص�һ�����ڴ���ҵ���߼�
4. epollfd�����ڲ���epoll������Ҫ�ص�,���Բ���Ҫ��װ��channel

```c++
// ÿһ��eventloop��������wakeupchannel��EPOLLIN�� �¼���
wakeupChannel_->enableReading();
// ����wakeupfd���¼������Լ������¼���Ļص�����
wakeupChannel_->setReadCallback(std::bind(&EventLoop::handleRead, this));     // ��eventloop����

void EventLoop::handleRead()
{
  // ��8�ֽڣ�fdΪint
  uint64_t one = 1;
  ssize_t n = read(wakeupFd_, &one, sizeof one);   // ��һ��socket��epoll�͸�֪���ˣ�
  if (n != sizeof one)
  {
    LOG_ERROR("EventLoop::handleRead() reads %lu bytes instead of 8", n);
  }
}
```

�����߳̽��յ�һ�������Ӻ�ѡ��һ��EventLoopʵ���������е�һ��wakeupfd_дһ�����ݣ�wakeupChannel�ͷ������¼�����ǰloop�߳̾ͻᱻ����

```c++
void EventLoop::wakeup()
{
    uint64_t one = 1;
    ssize_t n = write(wakeupFd_, &one, sizeof one);
    if (n != sizeof one)
    {
        LOG_ERROR("EventLoop::wakeup() writes %lu bytes instead of 8 \n", n);
    }
}
```





