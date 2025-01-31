# Channel封装

Channel是对fd的封装，附加了事件监听和回调函数

## Channel成员

### fd事件监听

其中，eventloop表示监听fd的epoll，events表示epoll监听的是可读还是可写事件

```c++
void enableReading() { events_ |= kReadEvent; update(); }
void disableReading() { events_ &= ~kReadEvent; update(); }
void enableWriting() { events_ |= kWriteEvent; update(); }
void disableWriting() { events_ &= ~kWriteEvent; update(); }
void disableAll() { events_ = kNoneEvent; update(); }
```

如一个新的连接产生时，这个fd调用enableReading设置可读事件，当这个fd上的数据接收处理完成后，
需要将响应send()回去，当响应一次无法发送完成时，会将响应置入用户缓存区，发送完第一段时到内核缓存区后，其余数据缓存到用户缓存区
该fd需要调用enableWriting()设置可写事件，以等待后续响应的发送

```c++
outputBuffer_.append((char*)data + nwrote, remaining);
if (!channel_->isWriting())    // 如果fd没有注册写事件
{
    channel_->enableWriting(); // 这里一定要注册channel的写事件，否则poller不会给channel通知epollout
}
```

### 事件回调

事件回调对应fd监听的事件，当可读事件、可写事件发生时，将调用对应的读写函数

```c++
// 设置回调函数对象
void setReadCallback(ReadEventCallback cb) { readCallback_ = std::move(cb); }   // 移动语义 todo
void setWriteCallback(EventCallback cb) { writeCallback_ = std::move(cb); }
void setCloseCallback(EventCallback cb) { closeCallback_ = std::move(cb); }
void setErrorCallback(EventCallback cb) { errorCallback_ = std::move(cb); }
```

当epoll_wait()返回发生事件的channel后，根据事件类型回调对应的函数
