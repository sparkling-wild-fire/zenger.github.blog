# OceanDB�ؽ�����

[OceanDB�ٷ��ĵ�](https://www.oceanbase.com/docs/community-observer-cn-10000000000449437)

## ����sql����

```sql
--- ɾ�����еı�����ѯ���ִ��һ��
SELECT CONCAT('DROP TABLE IF EXISTS ', table_name, ';') FROM information_schema.tables WHERE table_schema = '���ݿ���';
--- �鿴�汾�ţ�Ŀǰ�汾�ţ�5.7.25-OceanBase-v3.2.4.5
SELECT version();
--- ��ȡÿ������ֶ�
show columns from zenger.algojr_tanlzindex2;
--- �鿴������
select * from information_schema.statistics a
where table_schema=database() AND lower(a.`TABLE_NAME`) = lower('thisstp_makerduty') AND a.`INDEX_NAME` = 'PRIMARY';
--- �����ݱ���
INSERT INTO table_name SELECT * FROM table_bak;
```

## OceanDb3.x�����޸�

����OceanDb3.x��֧�������޸ģ�ÿ�ζ���Ҫɾ���ؽ���Ϊ����ԭ�����ݣ���Ҫ����ԭ������ݺͽṹ�Ŀ�����

1. ��ȡҪ�޸ĵ��������жϸ������Ƿ��Ѵ���
2. ��ȡҪ���������޸ĵı���`thisstp_makerduty`Ϊ��������ȡ�������sql���
   - `show create table zenger.algojr_tanlzindex;`
3. ����`thisstp_makerduty`����sql,�½�һ�����ݱ�`thisstp_makerduty_bak`,����������ΪҪ�޸ĵ�����
4. ��ԭ������ݿ���һ�ݵ����ݱ�
   - `INSERT INTO table_b SELECT * FROM table_a;`
   - ������������������������������������ƣ��ٶȷǳ��죬10w����������s�㶨
     - ����������Ľṹ��ȫһ�£����ý������ͼ����ת��
     - �ұ��ݱ�Ϊ�գ�ֱ�ӽ����ݿ⿽������ҳ��Ҳ���ý���ҳ�ĺϲ������
4. ɾ��ԭ�������ݱ�ĵ�����������Ϊԭ��
    - `DROP TABLE IF EXISTS table_name` 
    - `ALTER TABLE algojr_tanlzindex1 RENAME TO algojr_tanlzindex2;`

## �ű�����

���½�����ʱ��ע���������ֶε�˳��

```sql
set @hs_sql1 = 'select 1 into @hs_sql1;';
set @hs_sql2 = 'select 1 into @hs_sql2;';
set @hs_sql3 = 'select 1 into @hs_sql3;';
set @hs_sql4 = 'select 1 into @hs_sql4;';
set @v_rowcount = 0;
SELECT count(1) INTO @v_rowcount from dual where (select count(1) from information_schema.statistics a where table_schema=DATABASE() and lower(a.`TABLE_NAME`) = 'thisalgojr_toperatelog' AND lower(a.`INDEX_NAME`) = 'primary' and lower(a.`COLUMN_NAME`)='business_date' and a.`SEQ_IN_INDEX` = 1)=1 
and (select count(1) from information_schema.statistics a where table_schema=DATABASE() and lower(a.`TABLE_NAME`) = 'thisalgojr_toperatelog' AND lower(a.`INDEX_NAME`) = 'primary' and lower(a.`COLUMN_NAME`)='position_str' and a.`SEQ_IN_INDEX` = 2)=1 
and (select count(1) from information_schema.statistics a where table_schema=DATABASE() and lower(a.`TABLE_NAME`) = 'thisalgojr_toperatelog' AND lower(a.`INDEX_NAME`) = 'primary' and lower(a.`COLUMN_NAME`)='input_date' and a.`SEQ_IN_INDEX` = 3)=1;
select 'CREATE TABLE `thisalgojr_toperatelog_bak` (
  `business_date` int(11) NOT NULL DEFAULT ''0'',
  `company_id` int(11) DEFAULT ''0'',
  `create_time` int(11) DEFAULT ''0'',
  `extsystem_id` int(11) DEFAULT ''0'',
  `input_date` int(11) NOT NULL DEFAULT ''0'',
  `message` varchar(4000) COLLATE utf8mb4_bin DEFAULT '''',
  `operate_type` char(1) COLLATE utf8mb4_bin DEFAULT '''',
  `operator_no` int(11) DEFAULT ''0'',
  `position_str` varchar(128) COLLATE utf8mb4_bin NOT NULL DEFAULT '''',
  `scheme_batch_no` int(11) DEFAULT ''0'',
  `scheme_code` varchar(64) COLLATE utf8mb4_bin DEFAULT '''',
  `scheme_ins_code` varchar(64) COLLATE utf8mb4_bin DEFAULT '''',
  `strategy_id` int(11) DEFAULT ''0'',
  `third_no` int(11) DEFAULT ''0'',
  `third_remark` varchar(256) COLLATE utf8mb4_bin DEFAULT '''',
  `algobus_front_id` int(11) NOT NULL DEFAULT ''0'',
  `log_type` int(11) NOT NULL DEFAULT ''0'',
  `log_level` int(10) DEFAULT NULL,
  PRIMARY KEY (`business_date`, `position_str`, `input_date`),
  KEY `idx_histoperatelog_date_scheme` (`business_date`, `scheme_code`) BLOCK_SIZE 16384 LOCAL
);' into @hs_sql1 from dual where @v_rowcount = 0;
select 'insert into thisalgojr_toperatelog_bak (business_date, company_id, create_time, extsystem_id, input_date, message, operate_type, operator_no, position_str, scheme_batch_no, scheme_code, scheme_ins_code, strategy_id, third_no, third_remark, algobus_front_id, log_type, log_level)
SELECT business_date, company_id, create_time, extsystem_id, input_date, message, operate_type, operator_no, position_str, scheme_batch_no, scheme_code, scheme_ins_code, strategy_id, third_no, third_remark, algobus_front_id, log_type, log_level
from thisalgojr_toperatelog;' into @hs_sql2 from dual where @v_rowcount = 0;
select 'DROP TABLE IF EXISTS thisalgojr_toperatelog;' into @hs_sql3 from dual where @v_rowcount = 0;
select 'ALTER TABLE thisalgojr_toperatelog_bak RENAME TO thisalgojr_toperatelog;' into @hs_sql4 from dual where @v_rowcount = 0;
PREPARE stmt FROM @hs_sql1;
EXECUTE stmt;
PREPARE stmt FROM @hs_sql2;
EXECUTE stmt;
PREPARE stmt FROM @hs_sql3;
EXECUTE stmt;
PREPARE stmt FROM @hs_sql4;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
```

## д���ű�����sql�ű�

Ϊ�����ı�ƥ�䡢�����ű����ɡ��������ݿ�ģ�����ݣ�����дһ���ű����в�����ͬʱͨ�����̼߳��ٳ������У���go������Э�̵�����£��ٶ���ԭ����3����

�����goд�ű���Ҫ�Ȱ�װOceanDB������

[go��װOceanDB����](https://www.alibabacloud.com/help/zh/apsaradb-for-oceanbase/latest/go-driver-connection-oceanbase-database)


�������������غ�ִ�У�`go install \path\to\github.com\go-sql-driver\mysql`,��`D:\GO\github.com\go-sql-driver\mysql`

�����������Զ����а�����

```shell
# ͨ����������
set http_proxy=http://127.0.0.1:7890
# ͨ������ok
go env -w GOPROXY=https://goproxy.cn,direct
go get -u github.com/go-sql-driver/mysql
```

�� Go �У���װ�İ��ᱻ���ص� $GOPATH/pkg/mod Ŀ¼�£������ݰ汾�Ŵ洢����Ӧ����Ŀ¼�С���ˣ�����ͨ�����²������鿴 github.com/go-sql-driver/mysql ���İ�װ·����
1. �������л��ն˴���,ִ������ go env GOPATH���鿴���� GOPATH ·����
2. �� $GOPATH/pkg/mod Ŀ¼���ҵ� github.com/go-sql-driver/mysql Ŀ¼�����е���Ŀ¼����Ӧ���밲װ�İ汾����ͬ
