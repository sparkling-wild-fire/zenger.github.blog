# zookeeper服务注册

zookeeper有很多用途，这里用作服务注册中心

[zk链接]()

## zkClinent

通过zk的c++ Api，对zkClient进行封装

### zkClient初始化

zk读取rpc程序配置文件，连接zk并返回zkCli句柄

```c++
// 连接zkserver
void ZkClient::Start()
{
    std::string host = MprpcApplication::GetInstance().GetConfig().Load("zookeeperip");
    std::string port = MprpcApplication::GetInstance().GetConfig().Load("zookeeperport");
    std::string connstr = host + ":" + port;
	/*
	zookeeper_mt：多线程版本,API客户端程序提供了三个线程
	API调用线程 
	网络I/O线程  pthread_create  poll
	watcher回调线程 pthread_create
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
在zookeeper的多线程版本，m_zhandle是异步返回的，为了避免在zkCli还为创建完成就进行业务处理，
通过信号量和zk的watch机制控制在zkCli为创建完成时，阻塞rpcProvider线程

```c++
// 全局的watcher观察器，zkserver给zkclient的通知
void global_watcher(zhandle_t *zh, int type,
                   int state, const char *path, void *watcherCtx)
{
    if (type == ZOO_SESSION_EVENT)  // 回调的消息类型是和会话相关的消息类型
	{
		if (state == ZOO_CONNECTED_STATE)  // zkclient和zkserver连接成功
		{
			sem_t *sem = (sem_t*)zoo_get_context(zh);
            sem_post(sem);
		}
	}
}
```

### zk服务节点的创建和获取

服务节点的创建

```c++
void ZkClient::Create(const char *path, const char *data, int datalen, int state)
{
    char path_buffer[128];
    int bufferlen = sizeof(path_buffer);
    int flag;
	// 先判断path表示的znode节点是否存在，如果存在，就不再重复创建了
	flag = zoo_exists(m_zhandle, path, 0, nullptr);
	if (ZNONODE == flag)
	{
		// 创建指定path的znode节点了
		flag = zoo_create(m_zhandle, path, data, datalen,
			&ZOO_OPEN_ACL_UNSAFE, state, path_buffer, bufferlen);
		// ...
	}
}
```

服务节点的获取

`zoo_get(m_zhandle, path, 0, buffer, &bufferlen, nullptr);`