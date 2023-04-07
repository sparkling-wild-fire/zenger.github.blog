# docker远程推送镜像

## 创建远程 dockerhub 仓库

登录网址：https://hub.docker.com/

没有账号就注册一个，验证身份后进入如下界面：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304071716938.png" alt="202304071716938" width="450px">

制作本地镜像：
```shell
# docker commit 容器名  镜像名:版本号
docker commit centos7s centos7_img:v2
```

链接本地镜像和远程仓库：
```shell
# docker tag 本地镜像名:版本号 dockerhub用户名/仓库名:版本号（应该再加一个/镜像名）
docker tag centos7_img:v2 zenger01/develop_linux:v2
```

本地端登录账户并push镜像:
```shell
docker login
# 然后依次输入docker用户名,密码.

# push本地镜像到仓库
docker push zjh96/mmdetection_zjh:v1
```

上传成功：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304071804890.png" alt="202304071804890" width="450px">


