# Epolller��װ

����������ģ�ͷ�Ϊselect��poll��epoller��Ϊ������չ�����ȳ����һ��poller������select��poll����poller�Ͻ�����չ������ʵ�ֵ���epoller

## poller

poller��Ҫ���þ��ǽ����¼���������fd�Ѿ����¼���װ��channel,����poller����Ҫ�������ǹ�������Channel
��ṹ��Ա��Ҫ�У�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231134512.png" alt="20241231134512" width="850">

����Ҫ��Ա����ΪChannel����ɾ�Ĳ飬������һ�ڽ���ϸ��˵��

## Epoller

### epoll��Ҫ����

- epoll_create():����һ��epollʵ��������һ���ļ�������������ļ������������ں�����epoll����
- epoll_ctl():��epollʵ������ӡ��޸Ļ�ɾ������Ȥ���¼�
- epoll_wait():�ȴ� epoll ʵ���ϵ��¼�����,�������������ֱ�����¼�������ʱ
- close():�ڲ�����Ҫ epoll �ļ�������ʱ��ʹ�� close �����ر������ͷ���Դ


### epoll��װ

epoller�̳�poller����Ҫ��ԱΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231134835.png" alt="20241231134835" width="850">

1. epoll��Ҫͨ��epollfd���в����������ڴ���ʵ��epollerʵ��ʱ����Ҫ�Ƚ�epollfd�ɹ�����������˵��epollerʵ����ʧ��

��һ���µ����Ӳ����������Ὣ�ɶ��¼��󶨵���Ӧ��fd��Ҳ���Ƿ�װ��Channel,Ȼ�����Channelͨ��`epoll_ctl(epollfd,add,fd,event)`���뵽epoll�У�
��������һ�µ����ӣ�����Ӧ̫������Ҫ���������ݴ洢���ڴ滺��������ʱ����Ҫͨ��`epoll_ctl(epollfd,mod,fd,event)`��fd�ļ����¼��޸�Ϊ��д��
�����ر�����ʱ����Ҫͨ��`epoll_ctl(epollfd,del,fd,event)`��fd�ļ����¼��Ƴ�

2. epoll_event�ĽṹΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241231135744.png" alt="20241231135744" width="850">

epll_wait()�ڼ������¼��󣬻Ὣ�������¼�events_���ص��û�̬������events_��ȡdata.ptr���ɵõ���epoll�����з����¼���channel(��Ծchannel)��
����ִ�ж�Ӧ�Ļص�����

```c++
    int numEvents = ::epoll_wait(epollfd_, &*events_.begin(), static_cast<int>(events_.size()), timeoutMs);
    Timestamp now(Timestamp::now());
    if (numEvents > 0)
    {
        LOG_INFO("%d events happened \n", numEvents);
        // ����events_����events_.ptr׷�ӵ���ԾChannel�б�
        fillActiveChannels(numEvents, activeChannels);
        if (numEvents == events_.size())
        {
            events_.resize(events_.size() * 2);
        }
    }
```
