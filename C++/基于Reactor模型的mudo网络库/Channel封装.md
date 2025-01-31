# Channel��װ

Channel�Ƕ�fd�ķ�װ���������¼������ͻص�����

## Channel��Ա

### fd�¼�����

���У�eventloop��ʾ����fd��epoll��events��ʾepoll�������ǿɶ����ǿ�д�¼�

```c++
void enableReading() { events_ |= kReadEvent; update(); }
void disableReading() { events_ &= ~kReadEvent; update(); }
void enableWriting() { events_ |= kWriteEvent; update(); }
void disableWriting() { events_ &= ~kWriteEvent; update(); }
void disableAll() { events_ = kNoneEvent; update(); }
```

��һ���µ����Ӳ���ʱ�����fd����enableReading���ÿɶ��¼��������fd�ϵ����ݽ��մ�����ɺ�
��Ҫ����Ӧsend()��ȥ������Ӧһ���޷��������ʱ���Ὣ��Ӧ�����û����������������һ��ʱ���ں˻��������������ݻ��浽�û�������
��fd��Ҫ����enableWriting()���ÿ�д�¼����Եȴ�������Ӧ�ķ���

```c++
outputBuffer_.append((char*)data + nwrote, remaining);
if (!channel_->isWriting())    // ���fdû��ע��д�¼�
{
    channel_->enableWriting(); // ����һ��Ҫע��channel��д�¼�������poller�����channel֪ͨepollout
}
```

### �¼��ص�

�¼��ص���Ӧfd�������¼������ɶ��¼�����д�¼�����ʱ�������ö�Ӧ�Ķ�д����

```c++
// ���ûص���������
void setReadCallback(ReadEventCallback cb) { readCallback_ = std::move(cb); }   // �ƶ����� todo
void setWriteCallback(EventCallback cb) { writeCallback_ = std::move(cb); }
void setCloseCallback(EventCallback cb) { closeCallback_ = std::move(cb); }
void setErrorCallback(EventCallback cb) { errorCallback_ = std::move(cb); }
```

��epoll_wait()���ط����¼���channel�󣬸����¼����ͻص���Ӧ�ĺ���
