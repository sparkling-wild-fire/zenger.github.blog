# Oceandb

���ݿ�:

```txt
OB-v3.x�汾��

�⻧ģʽ��mysql -h10.20.30.188 -P3306 -uroot@algotran_19646#zszq_prod -p'ERTzxc@#123'

ֱ��ģʽ��obclient  -h10.19.36.24 -P2881 -uroot@algotran_19646 -p'ERTzxc@#123' 

OB-v4.x�汾��(֧�������޸ģ��ű��п��Բ��������Ƿ���OB)

obclient -h10.20.195.52 -P2881 -uroot@sys -paaAA11__       ���root�û�sysϵͳ�⻧������������

obclient -h10.20.195.52 -P2881 -uroot@obmysql -paaAA11__ -c -A oceanbase   ����root�û�obmysql�⻧������ʹ�ã��Լ������û���Ҳʹ������⻧���ɡ�
```


## �������ݿ�

��root�û����룺

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240710163550.png" alt="20240710163550" width="850">

ִ�����,�������ݿ⣺

```mysql
create database zenger;

create user 'zenger'@'%' identified by 'zenger';

grant all privileges on zenger.* to zenger@'%';

show databases;
```

