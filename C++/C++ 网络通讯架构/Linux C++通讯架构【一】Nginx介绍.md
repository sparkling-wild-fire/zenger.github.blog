# Linux C++通讯架构【一】:Nginx介绍

## Nginx介绍
1. 介绍
   - web服务器：反向代理，负载均衡，邮件代理
   - 需要的资源比较少，轻量级服务器，高并发服务器，号称并发处理百万级别的tcp连接，热部署（边运行边升级），各模块耦合度很低。
   - 在不同操作系统，代码不同，在linux上使用epoll技术，windows上使用IOCP
2. 安装
   - tar -xzvf nginx-1.14.2.tar.gz
   - pcer库，函数库，支持解析正确表达式
   - zlib库：压缩解压缩功能：利用cpu较少网络带宽
   - openssl库：ssl功能相关库，用于网站加密通讯
   - 目录结构：
     - auto：一些编译xinshell脚本
     - configure来进行编译前的配置工作：
       - 安装目录、可执行文件目录、配置文件目录
       - ngx_modules.c内容，决定我们编译nginx时，哪些模块会编译到nginx中
       - make后，就得到可执行文件了（sudo make install）
3. 使用
  - sudo ./nginx
  - ps -ef | gref nginx
  - url 输入Ubuntu的ip地址，就可以访问到nginx了，nginx监听80端口

## master-worker进程模型

master是worker的父进程，其通信方式通常为信号、共享内存、管道等

1. 启动nginx：
    - master fork() 得到 work 子进程
    - 一个master 管理多个 worker，保证nginx的稳定、灵活
        - 一个worker挂了，立马fork一个新的，即使kill一个进程，master会感知并重新fork一个新的进程，保证worker数量不变
        - master和work通信：信号、信号量、共享内存（互斥量用于线程同步）等
    - master的所属用户为root，work进程的权限是nobody（权限开的很低），即使黑客拿到这个进程也不进行致命攻击
    - worker的数量：`CPU亲和性`
        - 多核计算机，让每个worker运行在一个单独的processor：处理器上，最大限度减少CPU进程切换成本。
            - 如电脑2个cpu，每个cpu里4个核，每个核里2个逻辑处理器，一共就是16个processor。
            - 为啥要将一个进程与一个核绑定: 提高cpu缓冲命中率
                - 进程如果切换到其他核，那么一级二级缓存就对于他失效了；
                - 如果切换到其他cpu，三级缓存也会失效。
                - 什么时候要进行绑核：计算密集型任务
            - nginx可更改配置，修改woker的个数

    
2. nginx运行时：
   - nginx重载配置文件
       - 不需要重启服务器，老的worker会退出，fork新的worker读取配置继续服务
       - 比如kill（这个命令是用来发送信号的）一个进程912 ，master监控发现少了一个进程，就new一个920进程。=》保证足够的进程
   - nginx热升级、热回滚
     - 如nginx升级，新增模块等，如果先关机，再开启，淘宝就会一直转圈圈
     - 向msater进程发送USER2信号，旧的master进程保存自己的pid等信息（通过信号回滚）
     - 旧的master用新的Nginx文件创建新的master进程，然后旧的master关闭（master会通知下的旧的子进程完成服务后也关闭）
     - 但这个过程不中断运行，而且如果发现新版本nginx不合适，回退也不需要重启
     - 对于使用者来说，只要修改配置文件，不需要重启服务器；修改配置文件后，reload配置文件，会发现worker进程的数量没变，但是其pid都变了

3. nginx的关闭：
   - kill master进程，其子进程也会跟着退出,用户会感觉突然就断开连接了，不建议。
   - nginx -s quit：进行完服务才退出


多线程模型的弊端：是共享内存的，一个线程报错，势必影响到其他线程；而nginx多进程之间不会相互影响，而且worker进程挂了，master也会将其拉起

