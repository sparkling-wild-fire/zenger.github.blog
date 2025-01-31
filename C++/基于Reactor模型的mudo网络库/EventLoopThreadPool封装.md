# EventLoopThreadPool封装

EventLoopThreadPool就是对EventLoopThread的管理了，主要是EventLoopThread的初始化和线程负载策略，本文采用轮询的方式

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250102150822.png" alt="20250102150822" width="850">

在主线程会创建一个baseEventLoop,当不开启线程池时，这个baseEventLoop会既监听listenfd，也会监听connectionfd。

## EventLoopThreadPool

EventLoopThreadPool的组成成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20250102152407.png" alt="20250102152407" width="850">

其中，baseLoop是主线程创建的baseLoop,也就是在服务器不启用线程池时，这个baseLoop会既监听listenfd，也会监听connectionfd。

## 启动

创建多个EventLoopThread,每个epoller一开始都会进入执行epoll_wait()进如休眠状态，不会占用CPU,而是等待主线程向epoll中的wakeupfd写入数据，
操作系统才会通知epoll唤醒子线程

```c++
void EventLoopThreadPool::start(const ThreadInitCallback &cb)
{
    started_ = true;
    // 如果设置了多个线程，就会在这个循环，不会进下面的
    for (int i = 0; i < numThreads_; ++i)
    {
        char buf[name_.size() + 32];
        snprintf(buf, sizeof buf, "%s%d", name_.c_str(), i);
        EventLoopThread *t = new EventLoopThread(cb, buf);
        threads_.push_back(std::unique_ptr<EventLoopThread>(t));
        loops_.push_back(t->startLoop()); // 底层创建线程，绑定一个新的EventLoop，并返回该loop的地址
    }
    // 整个服务端只有一个线程，运行着baseloop
    if (numThreads_ == 0 && cb)
    {
        cb(baseLoop_);
    }
}
```

## 线程分发

在单线程模式下，baseLoop监听connectionfd,多线程模式下，主线程以轮询的方式将connectionfd加入到子线程的epoll

```c++
// 如果工作在多线程中，baseLoop_默认以轮询的方式分配channel给subloop
EventLoop* EventLoopThreadPool::getNextLoop()
{
    EventLoop *loop = baseLoop_;
    if (!loops_.empty()) // 通过轮询获取下一个处理事件的loop
    {
        loop = loops_[next_];
        ++next_;
        if (next_ >= loops_.size())
        {
            next_ = 0;
        }
    }
    return loop;    // 如果没有设置多个线程，那就返回mianloop，就所有fd都放在mainloop中
}
```