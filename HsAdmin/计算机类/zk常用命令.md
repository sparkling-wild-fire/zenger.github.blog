# zk环境搭建与维护

## 环境搭建

查看zk启动状态：`./zkServer.sh status`
启动zk客户端：`./zkCli.sh -server 192.168.71.28:11832`
添加认证：`addauth digest zk_zenger:zk_zenger`


## zk常见问题

1. zk启动成功，但是查看zk状态显示未在运行中
    - 这是因为zk监听端口被占用，查看进程可以看到具体是哪个程序占用了端口，改掉就行
2. java的微服务在zk上找不到
   - java的路径多了一层，如：`ls /registry/com.hundsun.hsfund.otrade.fixincome.api.ibdeposit.MsgboxService/providers`