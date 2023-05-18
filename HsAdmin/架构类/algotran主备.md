# algotran主备

任务描述：MT节点进行热备，当主机宕机或离线后，继续用备机进行服务

## Nginx主备机制

VRRP：将多台路由器设备虚拟成一个设备，对外提供虚拟路由器IP。目的是解决静态路由的单点故障问题，保证单个节点宕机时，整个网络可以不间断运行。

主备配置： 
- 热备：一台主机提供服务，一台主机启动程序并进行数据同步，但不提供服务，在主机正常的情况下，永远处于浪费状态，仅用于灾备
- 冷备：备机是处于关闭状态

安装keeplived，配置主备机器上的keeplived.conf,当主机宕机后，自动将虚拟IP绑定到备机

双主配置：
- 两台主机同时工作，互为主备，一个服务器宕机，请求转移到另一台服务器

[Nginx主备切换](https://blog.csdn.net/qq_35733751/article/details/79834284)

## 公司主备机制

主备实现：

- 代理服务器（Nginx反向代理服务器）或者虚拟IP(K8s中会给pod集群一个虚拟IP，然后将客户端请求转发到不同的pod中的docker)
  - 客户端向服务器发送请求是完全ok，但是服务器怎么向客户端响应呢？（备机的socketfd和tcb什么时候建立）
- 客户端主备双写（宽途用的这种）

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230419165216.png" alt="20230419165216" width="450" >

- 备机继承主机IP和主机名（chatGpt的回答，感觉有点扯淡）

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230419161540.png" alt="20230419161540" width="450" >


主备切换时机(心跳检测)：
1. 初始化：插件根据节点启动的先后顺序确定哪个是主节点，然后形成链式监控，如启动顺序是A->B->C:
2. A成为主节点，B监控A,发送心跳包，并从A同步数据，C监控B，发送心跳包，并从B同步数据
   - 如果A离线了或宕机了，则B成为主节点；
   - 如果B离线或宕机了，则C监控A并从A同步数据

切换过程：
- 数据同步（通过内部插件）
- 在配置文件文件中将单节点路由转换为主备模式路由

主备机免密登陆：
- 各主机生成一对密钥，将公钥复制到其他主机

数据同步db版（19年后是通过 fsc_uftdb 插件实现）：
- 借助NFS服务：

  <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230419155550.png" alt="20230419155550" width="450" >
- 先将主机的文件同步备机的映射目录，备机再将数据加载到内存

zookeeper:
- 监控mp，mt等节点
- 其配置项在连接它的插件中配置，或者component.xml中配置
- zk检测到主机切换后，会自动open对应的路由


session:
- 客户每次发送请求都会携带一个会话id，这个会话id在服务器指定文件夹（内存、数据库）也存在，因此只要把他们对比，并且一致，就能够会话了
- 公司是放在内存(至于怎么从内存取，我就不知道了)，既然主备模式的session_id都放内存表了，那这种模式下从内存表读就可以了吧。


m_strExtSessionID: 不是session_id