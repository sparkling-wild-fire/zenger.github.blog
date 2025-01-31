# EventLoop封装

reactor模型采取`one loop per thread`的思想，每个EventLoopThread线程都创建一个EventLoop

## EventLoop

EventLoop是对epoller的进一步封装，目前仅仅满足epoller的单独运行，如果要应用在高并发环境，需要进一步封装，其主要成员对象为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231144120.png" alt="20241231144120" width="850">

其中，activeChannels表示发生事件的channel，也就是epoll_wait返回的事件


### 回调机制

pendingFactors表示正在执行的回调，其来源于两方面：
1. activeChannels绑定的回调
2. 上层框架追加的其他回调：如响应发送完成后的日志打印回调、buffer内存不足的空间调整回调、连接断开删除一个channel(main线程跨线程调用)

针对第二种情况，可能是其他线程向本线程追加的回调，所以追加`pendingFactors`时需要加锁

```c++
// 把cb放入队列中，唤醒loop所在的线程，执行cb
void EventLoop::queueInLoop(Functor cb)
{
    {
        std::unique_lock<std::mutex> lock(mutex_);    // 主线程也会给subLoop加回调，但从语言方面怎么实现的呢？
        pendingFunctors_.emplace_back(cb);
    }
    
    // 唤醒相应的，需要执行上面回调操作的loop的线程了
    if (!isInLoopThread() || callingPendingFunctors_) 
    {
        wakeup(); // 唤醒loop所在线程
    }
}
```

而往对应线程追加回调后，需要将该线程唤醒

而callingPendingFunctors_的意思是：当前loop正在执行回调，当回调全都被执行完成后，epoll_wait()能够立刻返回，执行新加入的回调（如将新连接加入epoll）

### 唤醒机制

线程唤醒机制其实是一种消息通知机制，是通过在EventLoop中设置一个注册可读事件的wakeupChannel实现的,为wakeupfd设置注册可读事件，并注册可读事件回调

tip: 本网络库主要有4种fd
1. wakeupfd，用于多线程消息通知，它的handleRead()回调就是将fd上的内核缓存区数据读取出来
2. acceptorfd，用于将新连接connectionfd加入到epoll，它的handleRead()回调就是遍历EventLoops
3. connectionfd，外部连接的fd，用于网络通信，它的handleRead()回调一般用于处理业务逻辑
4. epollfd，用于操作epoll，不需要回调,所以不需要封装成channel

```c++
// 每一个eventloop都将监听wakeupchannel的EPOLLIN读 事件了
wakeupChannel_->enableReading();
// 设置wakeupfd的事件类型以及发生事件后的回调操作
wakeupChannel_->setReadCallback(std::bind(&EventLoop::handleRead, this));     // 本eventloop对象

void EventLoop::handleRead()
{
  // 读8字节，fd为int
  uint64_t one = 1;
  ssize_t n = read(wakeupFd_, &one, sizeof one);   // 读一个socket，epoll就感知到了，
  if (n != sizeof one)
  {
    LOG_ERROR("EventLoop::handleRead() reads %lu bytes instead of 8", n);
  }
}
```

如主线程接收到一个新连接后，选择一个EventLoop实例，向其中的一个wakeupfd_写一个数据，wakeupChannel就发生读事件，当前loop线程就会被唤醒

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





