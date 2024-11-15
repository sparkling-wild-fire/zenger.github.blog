# Oceandb

数据库:

```txt
OB-v3.x版本：

租户模式：mysql -h10.20.30.188 -P3306 -uroot@algotran_19646#zszq_prod -p'ERTzxc@#123'

直连模式：obclient  -h10.19.36.24 -P2881 -uroot@algotran_19646 -p'ERTzxc@#123' 

OB-v4.x版本：(支持主键修改，脚本中可以不用再判是否是OB)

obclient -h10.20.195.52 -P2881 -uroot@sys -paaAA11__       这个root用户sys系统租户，不做开发。

obclient -h10.20.195.52 -P2881 -uroot@obmysql -paaAA11__ -c -A oceanbase   这是root用户obmysql租户，开发使用，自己创建用户后也使用这个租户即可。
```


## 创建数据库

以root用户进入：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240710163550.png" alt="20240710163550" width="850">

执行语句,创建数据库：

```mysql
create database zenger;

create user 'zenger'@'%' identified by 'zenger';

grant all privileges on zenger.* to zenger@'%';

show databases;
```

