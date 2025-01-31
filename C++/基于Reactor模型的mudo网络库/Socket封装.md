# Socket��װ

socket�Ƕ�fd�ķ�װ����Ҫ�������·�����

1. `ip+port`��

����sockaddr_in��һ���ײ�������ַ�࣬����ip�Ͷ˿�

`bind(sockfd_, (sockaddr*)localaddr.getSockAddr(), sizeof(sockaddr_in))`

2. ���Ӽ���

`listen(sockfd_, 1024)`

3. ����connectionfd������

�Է��ص�connfd��Ҫ���÷������������ö�·����+������IO��ģʽ��poller + non-blocking IO��

Ϊʲô��·����Ҫ��Ϸ�����IO: ��Ȼ��·�����Ѿ�֪ͨ�߳�fd�Ƿ�ɶ���д�ˣ������ڴ��ں�̬�����ݿ������û�̬�Ĺ����У����ǿ��ܷ���������

accept4������
1. sockfd ��Ҫ������������ļ����׽��ֵ��ļ���������addr �� addrlen�ֱ���ָ��洢�ͻ��˵�ַ�Ľṹ��ͽṹ���С��ָ�룻flags ��һ���������ñ�־λ��������
2. accept4�����ĵ�һ������addr�������洢���ܵ��Ŀͻ��˵�ַ��Ϣ�ġ�����һ��ָ��sockaddr�ṹ���ָ�룬�ýṹ�����ڴ洢�����ַ��Ϣ������IP��ַ�Ͷ˿ںŵȡ�
3. �ڵ���accept4����֮ǰ��������Ҫ�ȴ���һ���׽��֣�������󶨵�һ�����ص�ַ�ϡ����ͻ������ӵ�������ʱ��accept4���������������ӣ������ͻ��˵ĵ�ַ��Ϣ�洢��addr������ָ����ڴ��С�

�ͻ��˵�ַ��ô������أ��������ʲôʱ�򱻵��õģ�

```c++
int Socket::accept(InetAddress *peeraddr)
{
    sockaddr_in addr;  
    socklen_t len = sizeof addr;
    bzero(&addr, sizeof addr);   // ����ַ��0

    int connfd = ::accept4(sockfd_, (sockaddr*)&addr, &len, SOCK_NONBLOCK | SOCK_CLOEXEC);
    if (connfd >= 0)
    {
        peeraddr->setSockAddr(addr);   // ͨ����ΰѿͻ��˵�ַ���ػ�ȥ
    }
    return connfd;   // ��fd���ػ�ȥ
}
```

4. �رն��˻�д��

����fd�Ƿ������ͻ��������

`shutdown(sockfd_, SHUT_WR)`

5. ������������

��fd��д��ʱʱ�䡢�˿����õ�

`setsockopt(sockfd_, SOL_SOCKET, SO_REUSEPORT, &optval, sizeof optval)`
