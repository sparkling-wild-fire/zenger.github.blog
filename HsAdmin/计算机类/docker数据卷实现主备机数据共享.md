# 主备节点挂载

注意：以下内容只在本人私人环境上实现过，是否能用于测试环境的部署并不确定

在生产环境中，赋予一个docker操作系统的权限是一件不安全的事，在不具有系统操作权限的情况下，主备机无法通过nfs进行挂载。此时，可借助数据卷进行挂载

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231012161912.png" alt="20231012161912" width="850">

1. 创建两个数据卷

```shell
docker volume create vol1
docker volume create vol2
```

2. 创建新容器：
- 主机：将数据卷vol1挂载到主机的`/home/algotran_master/workspace/uftdata`目录，将vol2挂载到主机的`/home/algotran_master/workspace/uftdb_master/uftdata`目录
- 备机：将数据卷vol2挂载到备机的`/home/algotran_backup/workspace/uftdata`目录，将vol1挂载到备机的`/home/algotran_backup/workspace/uftdb_master/uftdata`目录


```shell
# 主机
docker container run -d --name container_name -v vol1:/home/algotran_master/workspace/
uftdata -v vol2:/home/algotran_master/workspace/uftdb_master/uftdata image_name
# 备机
docker container run -d --name container_name -v vol2:/home/algotran_backup/workspace/
uftdata -v vol2:/home/algotran_master/workspace/uftdb_backup/uftdata image_name
```

tip: 如果是不想重新部署环境，可先将已存的容器打包成镜像，然后根据此镜像创建新容器