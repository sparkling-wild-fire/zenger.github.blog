# oracle

[清空数据库重新建库](https://blog.csdn.net/interestANd/article/details/126893081)

数据库启动命令：
```txt
Su - oracle
lsnrctl  start
set NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
sqlplus /nolog   不登陆到数据库，只打开sqlplus软件
conn /as sysdba    不登陆，以系统身份连接数据库  conn STP/STP@ORCL 
startup (相当于这几个加起来：startup nomount、alter database mount、alter database open）
shutdown immediate | abort | normal | transactional | 
lsnrctl stop
```
# 问题
- startup后`ORA-01012: not logged on`
  - `shutdown abort`后再startup
-  主机连接备机的数据库为啥突然连接不上？
  - 防火墙为啥今天自己启动了？关了就行