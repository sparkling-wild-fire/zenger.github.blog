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
/etc/exports
```sql
--- 最好用
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'tstp_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;
-- 最后记得commit，SELECT 'commit'
```

删除表(drop会把这个库的表索引也删掉)：
```sql
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'tstp_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;
```

Mysql删除所有表:

```mysql
select concat('drop table ',table_name,';') from information_schema.TABLES where table_schema='test';
```

Oracle查看表索引：
```oracle
SELECT * FROM ALL_INDEXES WHERE TABLE_NAME = 'TSTP_INFO_QUOTEDAILY';
```

Mysql查看表索引：

```Mysql
SHOW INDEX FROM tstp_info_rstrfactor;
```

## 命令相关
### 数据库启动命令：
```txt
Su - oracle
lsnrctl  start
set NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
sqlplus /nolog   不登陆到数据库，只打开sqlplus软件
conn /as sysdba    不登陆，以系统身份连接数据库  conn STP/STP@ORCL 
startup (相当于这几个加起来：startup nomount、alter database mount、alter database open）  startup PFILE='/home/oracle/app/oracle/product/11.2.0/dbhome_2/dbs/pfile01.ora';

shutdown immediate | abort | normal | transactional | 
lsnrctl stop
```



alter database datafile 7 offline drop  

create spfile from pfile='/home/oracle/app/oracle/product/11.2.0/dbhome_2/dbs/pfile01.ora';

### 新建数据库示例：

1. su - oracle   密码：oracle   
2. sqlplus / as sysdba   
3. 以下语句需要使用sysdba用户执行，创建表空间HS_ALGOJR_DATA，datafile路径请根据实际情况修改：
```sql
create tablespace HS_ALGOZG_O3TEST_DATA datafile '/home/oracle/oradata/algozengzgdat_O3test.dbf' size 1G extent management local segment space management auto;
```
CREATE DIRECTORY ZZG_DATA_PUMP_DIR AS '/home/oracle/zzgdmp/';

impdb zenger_o3test/zenger_o3test@127.0.0.1:1521/orcl DIRECTORY=ZZG_DATA_PUMP_DIR DUMPFILE=ht.dmp log=export.log FULL=y;

4. 创建索引空间HS_ALGOJR_IDX，datafile路径请根据实际情况修改
```sql
create tablespace HS_ALGOZG_O32_TEST_IDX datafile '/home/oracle/oradata/algozgo32_testidx.dbf' size 500M extent management local segment space management auto;
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
6. 创建用户zenger_s3，此处密码可以自行修改
```sql
CREATE USER trade IDENTIFIED BY trade  default tablespace HS_ALGOZG_O3test_DATA;
```
7. 用户zenger_s2赋权限:
```sql
GRANT CONNECT TO trade;
GRANT RESOURCE TO trade;
GRANT create any table TO trade;
GRANT select any table TO trade;
GRANT create any index TO trade;
GRANT delete any table TO trade;
GRANT insert any table TO trade;
GRANT update any table TO trade;
GRANT drop any table TO trade;
GRANT UNLIMITED TABLESPACE TO trade;

GRANT SYSDBA TO trade;
```


## oralc常用操作

```sql
-- 查看字段：
describ table_name;
--查看索引：
SELECT * FROM ALL_INDEXES WHERE TABLE_NAME=upper('toutchannelconfig');     -- upper和lower函数进行大小写转化
```


### oracle表空间扩展

查看表空间：
```oracle
SELECT t.tablespace_name, ROUND(SUM(t.bytes) / 1024 / 1024, 2) total_space_mb, ROUND(SUM(t.bytes - NVL(f.free_space, 0)) / 1024 / 1024, 2) used_space_mb, ROUND(NVL(f.free_space, 0) / 1024 / 1024, 2) free_space_mb, ROUND((SUM(t.bytes - NVL(f.free_space, 0)) / SUM(t.bytes)) * 100, 2) used_percent FROM (SELECT tablespace_name, SUM(bytes) bytes FROM dba_data_files GROUP BY tablespace_name UNION ALL SELECT tablespace_name, SUM(bytes) FROM dba_temp_files GROUP BY tablespace_name) t, (SELECT tablespace_name, SUM(bytes) free_space FROM dba_free_space GROUP BY tablespace_name) f WHERE t.tablespace_name = f.tablespace_name(+) GROUP BY t.tablespace_name, f.free_space ORDER BY t.tablespace_name;
```

扩展：
```oracle
ALTER TABLESPACE HS_ALGOZG_O3TEST_DATA ADD DATAFILE '/home/oracle/oradata/zenger_extend3.dbf' SIZE 1G;
```


# 问
- startup后`ORA-01012: not logged on`
  - `shutdown abort`后再startup
-  主机连接备机的数据库为啥突然连接不上？
  - 防火墙为啥今天自己启动了？关了就行

