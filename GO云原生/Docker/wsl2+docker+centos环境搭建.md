# windows下wsl2安装centos容器

本文的安装流程为：windows开启hyper-v，在hyper-v上安装wsl2，进而安装Ubuntu分发，在Ubuntu分发上安装docker，在docker上安装centos7等容器

## 安装wsl

先开启hyper-v

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303212152312.png" alt="202303212152312" width="450px">

wsl的安装：

如果是win11家庭版，可能没有hyper-v,但可以通过脚本安装hyper-v:[参考链接](http://www.65ly.com/a/07/1670386778148335.html)

win11参考和Windows 10版本2004及更高版本：[安装WSL](https://learn.microsoft.com/en-us/windows/wsl/install)

win10旧版本参考：[旧版 WSL 的手动安装步骤](https://learn.microsoft.com/en-us/windows/wsl/install-manual)

win11下安装wsl2: `wsl --install`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303121553083.png" alt="202303121553083" width="450px">

## 安装Ubuntu
命令：`wsl --install -d Ubuntu-18.04` （最好安装18版本的，网上教程多）

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303121615791.png" alt="202303121615791" width="450px">

发现多出一个Ubuntu的系统终端,新建用户zenger，然后切换到root，为root设置密码。

### 更改主机名
wsl下的ubuntu更改主机名的方法：
[更改主机名](https://blog.csdn.net/qq_19922839/article/details/120697210)

安装完Ubuntu后，查看磁盘和内存，可以发现，是和win主机共享的：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303212235091.png" alt="202303212235091" width="450px">

但我物理内存其实是有32G，但这里只有16G，是因为只能读一个内存条？

### wsl常用命令：

- 升级wsl:`wsl --update`
- 查看系统wsl:`wsl -l -v`
- 查看运行中的分发:`wsl --list --running`

### wsl迁移Ubuntu到其他磁盘
1. 停止wsl：`wsl --shutdown`
2. 导出ubuntu：`wsl --export Ubuntu-18.04 F://WSL2-Ubuntu18//ubuntu-18.04.tar`
3. 注销原来的分发：`wsl --unregister Ubuntu-18.04`
4. 导入：`wsl --import Ubuntu-18.04 F://WSL2-Ubuntu18 F://WSL2-Ubuntu18//ubuntu-18.04.tar`

迁移完成后的文件夹：
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303142129906.png" alt="202303142129906" width="450px">

输入wsl，查看是否迁移成功。

## 在Ubuntu中安装docker
wsl安装docker有两种方式，可以安装docker desktop，也可以在wsl的Ubuntu中安装docker，这里选择第二种方法。

进入之前安装好的 Ubuntu，添加Docker源，依次输入以下命令

```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update
```

安装docker: `sudo apt install -y docker-ce`

启动docker: `sudo service docker start`
检查docker安装是否正常,并拉取centos7：
```shell
# 检查dockerd进程启动,注意wsl上ubuntu不支持systemctl
service docker status
ps aux|grep docker

# 查看 Docker 版本
docker version

# 检查拉取镜像是否正常
docker pull centos:7
docker images
```
注意：拉取centos镜像时，可能出现无权限的情况，需将当前用户加入docker用户组：
```shell
sudo gpasswd -a username docker
newgrp docker
```

如果速度太满，配置阿里云镜像加速器（自行百度下，[参考链接](https://blog.csdn.net/m0_67391270/article/details/126565050)）：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303142202132.png" alt="202303142202132" width="450px">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303142202528.png" alt="202303142202528" width="450px">

新建/etc/docker/daemon.json文件，将加速器地址粘贴进去：
```shell
{
  "registry-mirrors": ["https://3k6qw3vs.mirror.aliyuncs.com"]
}
```
重启docker: `sudo service docker restart`

然后拉取centos7就嘎嘎快了

## 运行centos容器

设置固定ip：[参考链接](https://www.cnblogs.com/erlou96/p/16878387.html)

注意设置固定ip一定要使用自定义的网络模式，默认的bridge模式不行。
```shell
// 创建一个新的docker网络类型
// 这会在ubunut上新建一个网桥
sudo docker network create --subnet=172.17.0.0/16 staticnet2 
// 查看网络类型
docker network ls
// 使用新的网络类型创建并启动容器 
sudo docker run -it --name centos7 --net staticnet --ip 172.17.1.101 centos:7 /bin/bash
// 查看容器ip
docker inspect <containtor_id>
```

容器重启，容器ip未变动，则设置成功

### 修改容器静态ip
1. 若要修改网段，则需更改网络模式：[参考连接](https://blog.csdn.net/luojie99/article/details/120342911)
2. 修改ip => [参考连接](https://blog.csdn.net/qq_25288617/article/details/128415902)

出现的问题：
1. user specified IP address is supported only when connecting to networks with user configured subnets

   解决：只有自定义网段才能配置静态ip，不能用默认的bridge网络模式

2. Error response from daemon: Invalid address 172.18.1.101: It does not belong to any of this network's subnets

   解决：[ip不属于网段](https://blog.csdn.net/qq_33093289/article/details/119918138)


## 进入centos

运行容器：`docker start 容器的ID/Name`

进入centos：`docker exec -it 容器id /bin/bash`

然后会发现，所有命令都不能使用，需要自己安装，如ifconfig：
```shell
# ifconfig,whois等命令都在这个包里
yum install net-tools
```
wsl网卡就是docker的代理

### win连接centos容器
#### windows ping通docker容器

[windows ping通docker容器](https://blog.csdn.net/weixin_43410596/article/details/121865088?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-121865088-blog-118891594.pc_relevant_recovery_v2&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-121865088-blog-118891594.pc_relevant_recovery_v2&utm_relevant_index=2)
方法：

在win11中添加路由，如

`route add 172.18.0.0 mask 255.255.0.0 172.20.151.225 -p`

但其实，windos ping不通容器也可以通过端口映射访问

#### win通过shell连接centos容器

1. 首先centos需要安装ssh服务，但启动时一般会出现问题：

Failed to get D-Bus connection: Operation not permitted

[解决方法](https://blog.csdn.net/Dontla/article/details/125628230):

只能保存镜像，然后删除原容器，再开启新容器了。。。但是这样新容器的ip配置全都变了，需要重新设置下。

对于初学者，尽量在docekr run时多考虑下，比如ip设置，端口映射，特权模式的开启，数据卷的绑定等，免得以后一直改配置啥的，命令类似于：
`docker run -itd --name=centos-cpp -v /root/remote_test:/root/remote_test -p <服务器外网ip>:36022:22 --privileged centos /usr/sbin/init`

我的启动命令：

`sudo docker run -itd --name centos7s_slave01 --hostname slave01 --net staticbridge --ip 172.18.2.102 -p 172.20.151.225:13323:22 --privileged centos7_img:v2 /usr/sbin/init`

其中，`172.20.151.225`为ubuntu的eth0网卡地址

命令解析：
- -itd:
  - -i：表示以交互模式运行容器（让容器的标准输入保持打开）
  - -d：表示后台运行容器，并返回容器ID
  - -t：为容器重新分配一个伪输入终端
- --privileged:
  - 获取宿主机root权限
- /usr/sbin/init、/bin/bash
  - /bin/bash的作用是表示载入容器后运行bash ,docker中必须要保持一个进程的运行，要不然整个容器启动后就会马上kill itself
  - /usr/sbin/init 启动容器之后可以使用systemctl方法，通常和/usr/sbin/init搭配使用
- --hostname $host
  - 更改centos容器的默认主机名

2. 添加端口映射进行shell连接：

需要在ubunut上映射centos的端口，并在win上映射ubunut的端口：

[widos连接docker：ssh](https://blog.csdn.net/Canger_/article/details/117947999)

其中，容器添加端口映射的方法为：[容器添加端口映射](https://www.jb51.net/article/257510.htm)


## 其他功能：
[docker配置开机自启动](https://blog.csdn.net/XhyEax/article/details/105560377)

[容器基本命令](https://blog.csdn.net/m0_62948770/article/details/127342544)


## 注意事项及问题：
1. 配置文件写错，可能导致你的容器没了
2. hostconfig.json不能有127.0.0.1,写容器ip，端口映射和启动web服务都尽量用容器ip，而非127.0.0.1或0.0.0.0或localhost
3. [clion远程开发](https://zhuanlan.zhihu.com/p/429270402)
4. dism不是内部命令：

   解决方法：

   将`C:\Windows\System32`加入系统环境变量

   然后，如果提示需要提升dism权限，以管理员身份运行即可
5. 每次进入docker的centos文件夹，都说没权限，sudo chmod -R 777 /home/xxx；但是每次重启docker，都要重新设置权限...

   待解决...

6. 修改下centos主机名[参考链接](https://www.zhangshengrong.com/p/RmNP8BVGNk/)
7. Linux设置默认登录用户
    - wsl上的ubuntu尽量用root用户，也可以通过windows终端设置（加一个-u参数）
      <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304101026195.png" alt="202304101026195" width="450px">
    - centos更改默认登录用户名：这个不知道怎么改，但也没必要改
8. 以普通用户登录，可能需要先执行一些需要root权限的脚本，可执行命令：
   - `su - root -c "/home/source/start-api.sh"`
   - `-c`表示执行完这个脚本后，再切换回原用户