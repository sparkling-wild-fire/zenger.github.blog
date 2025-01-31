# Epolller封装

常见的网络模型分为select、poll和epoller，为便于扩展，首先抽象出一个poller，后续select、poll可在poller上进行扩展，本文实现的是epoller

## poller

poller主要作用就是进行事件监听，而fd已经绑定事件封装成channel,所以poller的主要工作就是管理它的Channel
其结构成员主要有：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231134512.png" alt="20241231134512" width="850">

其主要成员函数为Channel的增删改查，这在下一节进行细节说明

## Epoller

### epoll主要函数

- epoll_create():创建一个epoll实例，返回一个文件描述符，这个文件描述符将用于后续的epoll操作
- epoll_ctl():向epoll实例中添加、修改或删除感兴趣的事件
- epoll_wait():等待 epoll 实例上的事件发生,这个函数会阻塞直到有事件发生或超时
- close():在不再需要 epoll 文件描述符时，使用 close 函数关闭它，释放资源


### epoll封装

epoller继承poller，主要成员为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231134835.png" alt="20241231134835" width="850">

1. epoll需要通过epollfd进行操作，所以在创建实践epoller实例时，需要先将epollfd成功创建，否则说明epoller实例化失败

当一个新的连接产生后，往往会将可读事件绑定到对应的fd，也就是封装成Channel,然后将这个Channel通过`epoll_ctl(epollfd,add,fd,event)`加入到epoll中；
而类似上一章的例子，当响应太长，需要将部分数据存储到内存缓存区，这时就需要通过`epoll_ctl(epollfd,mod,fd,event)`将fd的监听事件修改为可写；
而当关闭连接时，需要通过`epoll_ctl(epollfd,del,fd,event)`将fd的监听事件移除

2. epoll_event的结构为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231135744.png" alt="20241231135744" width="850">

epll_wait()在监听到事件后，会将发生的事件events_返回到用户态，遍历events_获取data.ptr即可得到该epoll中所有发生事件的channel(活跃channel)，
进而执行对应的回调函数

```c++
    int numEvents = ::epoll_wait(epollfd_, &*events_.begin(), static_cast<int>(events_.size()), timeoutMs);
    Timestamp now(Timestamp::now());
    if (numEvents > 0)
    {
        LOG_INFO("%d events happened \n", numEvents);
        // 遍历events_，将events_.ptr追加到活跃Channel列表
        fillActiveChannels(numEvents, activeChannels);
        if (numEvents == events_.size())
        {
            events_.resize(events_.size() * 2);
        }
    }
```
