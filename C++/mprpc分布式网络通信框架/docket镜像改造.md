# docker�������

������win11������wsl2�Ļ����ϣ���װubuntu��ϵͳ����ubuntu����ȡcentos���񲢰�װcentos7����������Ϊ��

`sudo docker run -itd --name mpRpc --hostname MPRpc --net staticbridge --ip 172.18.3.101 -p 172.20.151.225:10022:22 
-p 172.20.151.225:55111:5111 -p 172.20.151.225:54111:4111 --privileged centos7_img:v2 /usr/sbin/init`

- `centos7_img:v2`���������ԭ����centos�����ϣ���װ��һЩ�������֧��ssh,ifconfig������½���Ĭ���û�zenger���Լ�һ������վ
- ubuntu��ϵͳ����������enth0��ipΪ`172.20.151.225`��inetΪ: `255.255.240.0`

