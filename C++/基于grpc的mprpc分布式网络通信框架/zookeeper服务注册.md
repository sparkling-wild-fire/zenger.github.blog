# zookeeper����ע��

zookeeper�кܶ���;��������������ע������

[zk����]()

## zkClinent

ͨ��zk��c++ Api����zkClient���з�װ

### zkClient��ʼ��

zk��ȡrpc���������ļ�������zk������zkCli���

```c++
// ����zkserver
void ZkClient::Start()
{
    std::string host = MprpcApplication::GetInstance().GetConfig().Load("zookeeperip");
    std::string port = MprpcApplication::GetInstance().GetConfig().Load("zookeeperport");
    std::string connstr = host + ":" + port;
	/*
	zookeeper_mt�����̰߳汾,API�ͻ��˳����ṩ�������߳�
	API�����߳� 
	����I/O�߳�  pthread_create  poll
	watcher�ص��߳� pthread_create
	*/
    m_zhandle = zookeeper_init(connstr.c_str(), global_watcher, 30000, nullptr, nullptr, 0);
    if (nullptr == m_zhandle) 
    {
        std::cout << "zookeeper_init error!" << std::endl;
        exit(EXIT_FAILURE);
    }

    sem_t sem;
    sem_init(&sem, 0, 0);
    zoo_set_context(m_zhandle, &sem);

    sem_wait(&sem);
    std::cout << "zookeeper_init success!" << std::endl;
}
```
��zookeeper�Ķ��̰߳汾��m_zhandle���첽���صģ�Ϊ�˱�����zkCli��Ϊ������ɾͽ���ҵ����
ͨ���ź�����zk��watch���ƿ�����zkCliΪ�������ʱ������rpcProvider�߳�

```c++
// ȫ�ֵ�watcher�۲�����zkserver��zkclient��֪ͨ
void global_watcher(zhandle_t *zh, int type,
                   int state, const char *path, void *watcherCtx)
{
    if (type == ZOO_SESSION_EVENT)  // �ص�����Ϣ�����ǺͻỰ��ص���Ϣ����
	{
		if (state == ZOO_CONNECTED_STATE)  // zkclient��zkserver���ӳɹ�
		{
			sem_t *sem = (sem_t*)zoo_get_context(zh);
            sem_post(sem);
		}
	}
}
```

### zk����ڵ�Ĵ����ͻ�ȡ

����ڵ�Ĵ���

```c++
void ZkClient::Create(const char *path, const char *data, int datalen, int state)
{
    char path_buffer[128];
    int bufferlen = sizeof(path_buffer);
    int flag;
	// ���ж�path��ʾ��znode�ڵ��Ƿ���ڣ�������ڣ��Ͳ����ظ�������
	flag = zoo_exists(m_zhandle, path, 0, nullptr);
	if (ZNONODE == flag)
	{
		// ����ָ��path��znode�ڵ���
		flag = zoo_create(m_zhandle, path, data, datalen,
			&ZOO_OPEN_ACL_UNSAFE, state, path_buffer, bufferlen);
		// ...
	}
}
```

����ڵ�Ļ�ȡ

`zoo_get(m_zhandle, path, 0, buffer, &bufferlen, nullptr);`