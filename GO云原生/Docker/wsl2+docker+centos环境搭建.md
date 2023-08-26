# windows��wsl2��װcentos����

���ĵİ�װ����Ϊ��windows����hyper-v����hyper-v�ϰ�װwsl2��������װUbuntu�ַ�����Ubuntu�ַ��ϰ�װdocker����docker�ϰ�װcentos7������

## ��װwsl

�ȿ���hyper-v

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303212152312.png" alt="202303212152312" width="450px">

wsl�İ�װ��

�����win11��ͥ�棬����û��hyper-v,������ͨ���ű���װhyper-v:[�ο�����](http://www.65ly.com/a/07/1670386778148335.html)

win11�ο���Windows 10�汾2004�����߰汾��[��װWSL](https://learn.microsoft.com/en-us/windows/wsl/install)

win10�ɰ汾�ο���[�ɰ� WSL ���ֶ���װ����](https://learn.microsoft.com/en-us/windows/wsl/install-manual)

win11�°�װwsl2: `wsl --install`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303121553083.png" alt="202303121553083" width="450px">

## ��װUbuntu
���`wsl --install -d Ubuntu-18.04` ����ð�װ18�汾�ģ����Ͻ̶̳ࣩ

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303121615791.png" alt="202303121615791" width="450px">

���ֶ��һ��Ubuntu��ϵͳ�ն�,�½��û�zenger��Ȼ���л���root��Ϊroot�������롣

### ����������
wsl�µ�ubuntu�����������ķ�����
[����������](https://blog.csdn.net/qq_19922839/article/details/120697210)

��װ��Ubuntu�󣬲鿴���̺��ڴ棬���Է��֣��Ǻ�win��������ģ�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303212235091.png" alt="202303212235091" width="450px">

���������ڴ���ʵ����32G��������ֻ��16G������Ϊֻ�ܶ�һ���ڴ�����

### wsl�������

- ����wsl:`wsl --update`
- �鿴ϵͳwsl:`wsl -l -v`
- �鿴�����еķַ�:`wsl --list --running`

### wslǨ��Ubuntu����������
1. ֹͣwsl��`wsl --shutdown`
2. ����ubuntu��`wsl --export Ubuntu-18.04 F://WSL2-Ubuntu18//ubuntu-18.04.tar`
3. ע��ԭ���ķַ���`wsl --unregister Ubuntu-18.04`
4. ���룺`wsl --import Ubuntu-18.04 F://WSL2-Ubuntu18 F://WSL2-Ubuntu18//ubuntu-18.04.tar`

Ǩ����ɺ���ļ��У�
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303142129906.png" alt="202303142129906" width="450px">

����wsl���鿴�Ƿ�Ǩ�Ƴɹ���

## ��Ubuntu�а�װdocker
wsl��װdocker�����ַ�ʽ�����԰�װdocker desktop��Ҳ������wsl��Ubuntu�а�װdocker������ѡ��ڶ��ַ�����

����֮ǰ��װ�õ� Ubuntu�����DockerԴ������������������

```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update
```

��װdocker: `sudo apt install -y docker-ce`

����docker: `sudo service docker start`
���docker��װ�Ƿ�����,����ȡcentos7��
```shell
# ���dockerd��������,ע��wsl��ubuntu��֧��systemctl
service docker status
ps aux|grep docker

# �鿴 Docker �汾
docker version

# �����ȡ�����Ƿ�����
docker pull centos:7
docker images
```
ע�⣺��ȡcentos����ʱ�����ܳ�����Ȩ�޵�������轫��ǰ�û�����docker�û��飺
```shell
sudo gpasswd -a username docker
newgrp docker
```

����ٶ�̫�������ð����ƾ�������������аٶ��£�[�ο�����](https://blog.csdn.net/m0_67391270/article/details/126565050)����

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303142202132.png" alt="202303142202132" width="450px">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303142202528.png" alt="202303142202528" width="450px">

�½�/etc/docker/daemon.json�ļ�������������ַճ����ȥ��
```shell
{
  "registry-mirrors": ["https://3k6qw3vs.mirror.aliyuncs.com"]
}
```
����docker: `sudo service docker restart`

Ȼ����ȡcentos7�͸¸¿���

## ����centos����

���ù̶�ip��[�ο�����](https://www.cnblogs.com/erlou96/p/16878387.html)

ע�����ù̶�ipһ��Ҫʹ���Զ��������ģʽ��Ĭ�ϵ�bridgeģʽ���С�
```shell
// ����һ���µ�docker��������
// �����ubunut���½�һ������
sudo docker network create --subnet=172.17.0.0/16 staticnet2 
// �鿴��������
docker network ls
// ʹ���µ��������ʹ������������� 
sudo docker run -it --name centos7 --net staticnet --ip 172.17.1.101 centos:7 /bin/bash
// �鿴����ip
docker inspect <containtor_id>
```

��������������ipδ�䶯�������óɹ�

### �޸�������̬ip
1. ��Ҫ�޸����Σ������������ģʽ��[�ο�����](https://blog.csdn.net/luojie99/article/details/120342911)
2. �޸�ip => [�ο�����](https://blog.csdn.net/qq_25288617/article/details/128415902)

���ֵ����⣺
1. user specified IP address is supported only when connecting to networks with user configured subnets

   �����ֻ���Զ������β������þ�̬ip��������Ĭ�ϵ�bridge����ģʽ

2. Error response from daemon: Invalid address 172.18.1.101: It does not belong to any of this network's subnets

   �����[ip����������](https://blog.csdn.net/qq_33093289/article/details/119918138)


## ����centos

����������`docker start ������ID/Name`

����centos��`docker exec -it ����id /bin/bash`

Ȼ��ᷢ�֣������������ʹ�ã���Ҫ�Լ���װ����ifconfig��
```shell
# ifconfig,whois��������������
yum install net-tools
```
wsl��������docker�Ĵ���

### win����centos����
#### windows pingͨdocker����

[windows pingͨdocker����](https://blog.csdn.net/weixin_43410596/article/details/121865088?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-121865088-blog-118891594.pc_relevant_recovery_v2&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-121865088-blog-118891594.pc_relevant_recovery_v2&utm_relevant_index=2)
������

��win11�����·�ɣ���

`route add 172.18.0.0 mask 255.255.0.0 172.20.151.225 -p`

����ʵ��windos ping��ͨ����Ҳ����ͨ���˿�ӳ�����

#### winͨ��shell����centos����

1. ����centos��Ҫ��װssh���񣬵�����ʱһ���������⣺

Failed to get D-Bus connection: Operation not permitted

[�������](https://blog.csdn.net/Dontla/article/details/125628230):

ֻ�ܱ��澵��Ȼ��ɾ��ԭ�������ٿ����������ˡ���������������������ip����ȫ�����ˣ���Ҫ���������¡�

���ڳ�ѧ�ߣ�������docekr runʱ�࿼���£�����ip���ã��˿�ӳ�䣬��Ȩģʽ�Ŀ��������ݾ�İ󶨵ȣ�����Ժ�һֱ������ɶ�ģ����������ڣ�
`docker run -itd --name=centos-cpp -v /root/remote_test:/root/remote_test -p <����������ip>:36022:22 --privileged centos /usr/sbin/init`

�ҵ��������

`sudo docker run -itd --name centos7s_slave01 --hostname slave01 --net staticbridge --ip 172.18.2.102 -p 172.20.151.225:13323:22 --privileged centos7_img:v2 /usr/sbin/init`

���У�`172.20.151.225`Ϊubuntu��eth0������ַ

���������
- -itd:
  - -i����ʾ�Խ���ģʽ�����������������ı�׼���뱣�ִ򿪣�
  - -d����ʾ��̨��������������������ID
  - -t��Ϊ�������·���һ��α�����ն�
- --privileged:
  - ��ȡ������rootȨ��
- /usr/sbin/init��/bin/bash
  - /bin/bash�������Ǳ�ʾ��������������bash ,docker�б���Ҫ����һ�����̵����У�Ҫ��Ȼ��������������ͻ�����kill itself
  - /usr/sbin/init ��������֮�����ʹ��systemctl������ͨ����/usr/sbin/init����ʹ��
- --hostname $host
  - ����centos������Ĭ��������

2. ��Ӷ˿�ӳ�����shell���ӣ�

��Ҫ��ubunut��ӳ��centos�Ķ˿ڣ�����win��ӳ��ubunut�Ķ˿ڣ�

[widos����docker��ssh](https://blog.csdn.net/Canger_/article/details/117947999)

���У�������Ӷ˿�ӳ��ķ���Ϊ��[������Ӷ˿�ӳ��](https://www.jb51.net/article/257510.htm)


## �������ܣ�
[docker���ÿ���������](https://blog.csdn.net/XhyEax/article/details/105560377)

[������������](https://blog.csdn.net/m0_62948770/article/details/127342544)


## ע��������⣺
1. �����ļ�д�����ܵ����������û��
2. hostconfig.json������127.0.0.1,д����ip���˿�ӳ�������web���񶼾���������ip������127.0.0.1��0.0.0.0��localhost
3. [clionԶ�̿���](https://zhuanlan.zhihu.com/p/429270402)
4. dism�����ڲ����

   ���������

   ��`C:\Windows\System32`����ϵͳ��������

   Ȼ�������ʾ��Ҫ����dismȨ�ޣ��Թ���Ա������м���
5. ÿ�ν���docker��centos�ļ��У���˵ûȨ�ޣ�sudo chmod -R 777 /home/xxx������ÿ������docker����Ҫ��������Ȩ��...

   �����...

6. �޸���centos������[�ο�����](https://www.zhangshengrong.com/p/RmNP8BVGNk/)
7. Linux����Ĭ�ϵ�¼�û�
    - wsl�ϵ�ubuntu������root�û���Ҳ����ͨ��windows�ն����ã���һ��-u������
      <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304101026195.png" alt="202304101026195" width="450px">
    - centos����Ĭ�ϵ�¼�û����������֪����ô�ģ���Ҳû��Ҫ��
8. ����ͨ�û���¼��������Ҫ��ִ��һЩ��ҪrootȨ�޵Ľű�����ִ�����
   - `su - root -c "/home/source/start-api.sh"`
   - `-c`��ʾִ��������ű������л���ԭ�û�