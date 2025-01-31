# docker镜像改造

环境：win11（开启wsl2的基础上）安装ubuntu子系统，在ubuntu上拉取centos镜像并安装centos7，启动命令为：

`sudo docker run -itd --name mpRpc --hostname MPRpc --net staticbridge --ip 172.18.3.101 -p 172.20.151.225:10022:22 
-p 172.20.151.225:55111:5111 -p 172.20.151.225:54111:4111 --privileged centos7_img:v2 /usr/sbin/init`

- `centos7_img:v2`这个镜像在原来的centos基础上，安装了一些软件包，支持ssh,ifconfig等命令，新建了默认用户zenger、以及一个回收站
- ubuntu子系统的外网网卡enth0的ip为`172.20.151.225`，inet为: `255.255.240.0`

