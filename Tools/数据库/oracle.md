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

```sql
--- �����
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'tstp_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'delete from '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;
-- ���ǵ�commit��SELECT 'commit'
```

ɾ����
```sql
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'algojr_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'tstp_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisalgojr_%' ORDER BY TABLE_NAME;
SELECT 'DROP TABLE '|| table_name || ';' FROM USER_TABLES where lower(table_name) like 'thisstp_%' ORDER BY TABLE_NAME;
```

## �������
### ���ݿ��������
```txt
Su - oracle
lsnrctl  start
set NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
sqlplus /nolog   ����½�����ݿ⣬ֻ��sqlplus���
conn /as sysdba    ����½����ϵͳ����������ݿ�  conn STP/STP@ORCL 
startup (�൱���⼸����������startup nomount��alter database mount��alter database open��
shutdown immediate | abort | normal | transactional | 
lsnrctl stop
```

### �½����ݿ�ʾ����

1. su - oracle   ���룺oracle
2. sqlplus / as sysdba
3. ���������Ҫʹ��sysdba�û�ִ�У�������ռ�HS_ALGOJR_DATA��datafile·�������ʵ������޸ģ�
```sql
create tablespace HS_ALGOZG_DATA datafile '/home/oracle11/oradata/ly/algolyo32_2dat.dbf' 
    size 1G extent management local segment space management auto;
```
4. ���������ռ�HS_ALGOJR_IDX��datafile·�������ʵ������޸�
```sql
create tablespace HS_ALGOLY_O32_2_IDX datafile '/home/oracle11/oradata/ly/algolyo32_2idx.dbf' 
    size 500M extent management local segment space management auto;
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
6. �����û�hs_algojr���˴�������������޸�
```sql
CREATE USER zenger_s1 IDENTIFIED BY zenger_s1  default tablespace HS_ALGOZG_DATA;
```
7. �û�zenger_s1��Ȩ��:
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


## oralc���ò���

```sql
-- �鿴�ֶΣ�
describ table_name;
--�鿴������
SELECT * FROM ALL_INDEXES WHERE TABLE_NAME=upper('toutchannelconfig');     -- upper��lower�������д�Сдת��
```


# ��
- startup��`ORA-01012: not logged on`
  - `shutdown abort`����startup
-  �������ӱ��������ݿ�ΪɶͻȻ���Ӳ��ϣ�
  - ����ǽΪɶ�����Լ������ˣ����˾���

