# �����ڵ����

ע�⣺��������ֻ�ڱ���˽�˻�����ʵ�ֹ����Ƿ������ڲ��Ի����Ĳ��𲢲�ȷ��

�����������У�����һ��docker����ϵͳ��Ȩ����һ������ȫ���£��ڲ�����ϵͳ����Ȩ�޵�����£��������޷�ͨ��nfs���й��ء���ʱ���ɽ������ݾ���й���

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231012161912.png" alt="20231012161912" width="850">

1. �����������ݾ�

```shell
docker volume create vol1
docker volume create vol2
```

2. ������������
- �����������ݾ�vol1���ص�������`/home/algotran_master/workspace/uftdata`Ŀ¼����vol2���ص�������`/home/algotran_master/workspace/uftdb_master/uftdata`Ŀ¼
- �����������ݾ�vol2���ص�������`/home/algotran_backup/workspace/uftdata`Ŀ¼����vol1���ص�������`/home/algotran_backup/workspace/uftdb_master/uftdata`Ŀ¼


```shell
# ����
docker container run -d --name container_name -v vol1:/home/algotran_master/workspace/
uftdata -v vol2:/home/algotran_master/workspace/uftdb_master/uftdata image_name
# ����
docker container run -d --name container_name -v vol2:/home/algotran_backup/workspace/
uftdata -v vol2:/home/algotran_master/workspace/uftdb_backup/uftdata image_name
```

tip: ����ǲ������²��𻷾������Ƚ��Ѵ����������ɾ���Ȼ����ݴ˾��񴴽�������