# oracle

[清空数据库重新建库](https://blog.csdn.net/interestANd/article/details/126893081)
(不要用trucate,截断后数据恢复不了，用delete)

*** 删表、清数据之前一定要确认，检查表名：  ***

只有这些表能删，其他的不能动
清理表数据：
```sql
--- 最好用delete
--- 注意这个在sql developer中会有4个结果
SELECT 'truncate TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;

SELECT 'truncate TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'truncate TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;

SELECT 'truncate TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%'
or lower(table_name) like 'tstp_%' or lower(table_name) like 'thisalgojr_%' or lower(table_name) like 'thisstp_%'
ORDER BY TABLE_NAME;
-- 最后记得commit，SELECT 'commit'
```

```sql
--- 最好用
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'tstp_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;
-- 最后记得commit，SELECT 'commit'
```

删除表：
```sql
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'tstp_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;
```

## 命令相关
### 数据库启动命令：
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

### 新建数据库示例：

1. su - oracle   密码：oracle
2. sqlplus / as sysdba
3. 以下语句需要使用sysdba用户执行，创建表空间HS_ALGOJR_DATA，datafile路径请根据实际情况修改：
```sql
create tablespace HS_ALGOZG_DATA datafile '/home/oracle11/oradata/ly/algolyo32_2dat.dbf' 
    size 1G extent management local segment space management auto;
```
4. 创建索引空间HS_ALGOJR_IDX，datafile路径请根据实际情况修改
```sql
create tablespace HS_ALGOLY_O32_2_IDX datafile '/home/oracle11/oradata/ly/algolyo32_2idx.dbf' 
    size 500M extent management local segment space management auto;
```
5. （可选）删除用户hs_algojr
```sql
declare
v_rowcount integer;
begin
select count(*)
into v_rowcount
from dual
where exists
(
select * from all_users a where a.username = upper('hs_algojr')
);
if v_rowcount > 0 then
execute immediate 'DROP USER hs_algojr CASCADE';
end if;
end;
```
6. 创建用户hs_algojr，此处密码可以自行修改
```sql
CREATE USER zenger_s1 IDENTIFIED BY zenger_s1  default tablespace HS_ALGOZG_DATA;
```
7. 用户zenger_s1赋权限:
```sql
GRANT CONNECT TO zenger_s1;
GRANT RESOURCE TO zenger_s1;
GRANT create any table TO zenger_s1;
GRANT select any table TO zenger_s1;
GRANT create any index TO zenger_s1;
GRANT delete any table TO zenger_s1;
GRANT insert any table TO zenger_s1;
GRANT update any table TO zenger_s1;
GRANT drop any table TO zenger_s1;
GRANT UNLIMITED TABLESPACE TO zenger_s1;
```


## oralc常用操作

```sql
-- 查看字段：
describ table_name;
--查看索引：
SELECT * FROM ALL_INDEXES WHERE TABLE_NAME=upper('toutchannelconfig');     -- upper和lower函数进行大小写转化
```


# 问
- startup后`ORA-01012: not logged on`
  - `shutdown abort`后再startup
-  主机连接备机的数据库为啥突然连接不上？
  - 防火墙为啥今天自己启动了？关了就行

