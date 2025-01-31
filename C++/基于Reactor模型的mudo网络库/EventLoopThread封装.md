# EventLoopThread封装

reactor模型采取`one loop per thread`的思想，每个EventLoopThread线程都创建一个EventLoop，创建EventLoop，还要创建一个线程进行绑定

EventLoopThread组成成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231170520.png" alt="20241231170520" width="850">

## Thread对象

其主要成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231165109.png" alt="20241231165109" width="850">


创建Thead线程主要是创建EventLoop，为确保EventLoop创建完成，主线程才退出，需要通过信号量进行控制

```c++
void Thread::start()  // 一个Thread对象，记录的就是一个新线程的详细信息  => 也就是头文件定义的都有
{
    started_ = true;
    sem_t sem;
    sem_init(&sem, false, 0);
    // 开启线程
    // 这里的时候主线程直接执行完了，但是子线程还没执行，所以要利用信号量进行主线程与子线程的通信
    thread_ = std::shared_ptr<std::thread>(new std::thread([&](){    
        // 获取线程的tid值
        tid_ = CurrentThread::tid();  
        sem_post(&sem);
        // 在子线程中线程
        func_(); 
    }));
    // 这里必须等待获取上面新创建的线程的tid值
    sem_wait(&sem);
}
```

## EventLoopThread对象

有了EventLoop和Thread的基础，就能封装EventLoopThread了


EventLoopThread组成成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231170520.png" alt="20241231170520" width="850">

EventLoopThread的创建，参数初始化：

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

线程的入口函数，也就是thread_对象在start时，创建一个子线程，在这个子线程中创建一个epoll_wait的epoll：

```c++
// 在单独的新线程里面运行的
void EventLoopThread::threadFunc()
{
    EventLoop loop; // 创建一个独立的eventloop，和上面的线程是一一对应的，one loop per thread

    if (callback_)
    {
        callback_(&loop);  // 把loop传给你这个回调函数
    }

    {
        // 多个线程执行这个入口方法需要加锁,保险的做法是将上面loop初始化也加锁
        std::unique_lock<std::mutex> lock(mutex_);  
        loop_ = &loop;
        cond_.notify_one();  // 通知主线程，要这个loop创建完成后，才能追加到epoll向量中
    }

    // 开启事件循环，epoll_wait()
    loop.loop();               
    std::unique_lock<std::mutex> lock(mutex_);   
    loop_ = nullptr;    // 当这个loop退出后，将loop_置为空
}
```
