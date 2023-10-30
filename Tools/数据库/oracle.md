# oracle

[������ݿ����½���](https://blog.csdn.net/interestANd/article/details/126893081)
(��Ҫ��trucate,�ضϺ����ݻָ����ˣ���delete)

*** ɾ��������֮ǰһ��Ҫȷ�ϣ���������  ***

ֻ����Щ����ɾ�������Ĳ��ܶ�
��������ݣ�
```sql
--- �����delete
--- ע�������sql developer�л���4�����
SELECT 'truncate TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;

SELECT 'truncate TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'truncate TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;

SELECT 'truncate TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%'
or lower(table_name) like 'tstp_%' or lower(table_name) like 'thisalgojr_%' or lower(table_name) like 'thisstp_%'
ORDER BY TABLE_NAME;
-- ���ǵ�commit��SELECT 'commit'
```
/etc/exports
```sql
--- �����
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'tstp_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;
-- ���ǵ�commit��SELECT 'commit'
```

ɾ����(drop��������ı�����Ҳɾ��)��
```sql
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'tstp_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;
```

Mysqlɾ�����б�:

```mysql
select concat('drop table ',table_name,';') from information_schema.TABLES where table_schema='test';
```

Oracle�鿴��������
```oracle
SELECT * FROM ALL_INDEXES WHERE TABLE_NAME = 'TSTP_INFO_QUOTEDAILY';
```

Mysql�鿴��������

```Mysql
SHOW INDEX FROM tstp_info_rstrfactor;
```

## �������
### ���ݿ��������
```txt
Su - oracle
lsnrctl  start
set NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
sqlplus /nolog   ����½�����ݿ⣬ֻ��sqlplus���
conn /as sysdba    ����½����ϵͳ����������ݿ�  conn STP/STP@ORCL 
startup (�൱���⼸����������startup nomount��alter database mount��alter database open��  startup PFILE='/home/oracle/app/oracle/product/11.2.0/dbhome_2/dbs/pfile01.ora';

shutdown immediate | abort | normal | transactional | 
lsnrctl stop
```



alter database datafile 7 offline drop  

create spfile from pfile='/home/oracle/app/oracle/product/11.2.0/dbhome_2/dbs/pfile01.ora';

### �½����ݿ�ʾ����

1. su - oracle   ���룺oracle   
2. sqlplus / as sysdba   
3. ���������Ҫʹ��sysdba�û�ִ�У�������ռ�HS_ALGOJR_DATA��datafile·�������ʵ������޸ģ�
```sql
create tablespace HS_ALGOZG_O3TEST_DATA datafile '/home/oracle/oradata/algozengzgdat_O3test.dbf' size 1G extent management local segment space management auto;
```
CREATE DIRECTORY ZZG_DATA_PUMP_DIR AS '/home/oracle/zzgdmp/';

impdb zenger_o3test/zenger_o3test@127.0.0.1:1521/orcl DIRECTORY=ZZG_DATA_PUMP_DIR DUMPFILE=ht.dmp log=export.log FULL=y;

4. ���������ռ�HS_ALGOJR_IDX��datafile·�������ʵ������޸�
```sql
create tablespace HS_ALGOZG_O32_TEST_IDX datafile '/home/oracle/oradata/algozgo32_testidx.dbf' size 500M extent management local segment space management auto;
```
5. ����ѡ��ɾ���û�hs_algojr

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
6. �����û�zenger_s3���˴�������������޸�
```sql
CREATE USER trade IDENTIFIED BY trade  default tablespace HS_ALGOZG_O3test_DATA;
```
7. �û�zenger_s2��Ȩ��:
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


## oralc���ò���

```sql
-- �鿴�ֶΣ�
describ table_name;
--�鿴������
SELECT * FROM ALL_INDEXES WHERE TABLE_NAME=upper('toutchannelconfig');     -- upper��lower�������д�Сдת��
```


### oracle��ռ���չ

�鿴��ռ䣺
```oracle
SELECT t.tablespace_name, ROUND(SUM(t.bytes) / 1024 / 1024, 2) total_space_mb, ROUND(SUM(t.bytes - NVL(f.free_space, 0)) / 1024 / 1024, 2) used_space_mb, ROUND(NVL(f.free_space, 0) / 1024 / 1024, 2) free_space_mb, ROUND((SUM(t.bytes - NVL(f.free_space, 0)) / SUM(t.bytes)) * 100, 2) used_percent FROM (SELECT tablespace_name, SUM(bytes) bytes FROM dba_data_files GROUP BY tablespace_name UNION ALL SELECT tablespace_name, SUM(bytes) FROM dba_temp_files GROUP BY tablespace_name) t, (SELECT tablespace_name, SUM(bytes) free_space FROM dba_free_space GROUP BY tablespace_name) f WHERE t.tablespace_name = f.tablespace_name(+) GROUP BY t.tablespace_name, f.free_space ORDER BY t.tablespace_name;
```

��չ��
```oracle
ALTER TABLESPACE HS_ALGOZG_O3TEST_DATA ADD DATAFILE '/home/oracle/oradata/zenger_extend3.dbf' SIZE 1G;
```


# ��
- startup��`ORA-01012: not logged on`
  - `shutdown abort`����startup
-  �������ӱ��������ݿ�ΪɶͻȻ���Ӳ��ϣ�
  - ����ǽΪɶ�����Լ������ˣ����˾���

