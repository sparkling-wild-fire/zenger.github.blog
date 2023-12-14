# OceanDBɾ���ؽ������ű�

[�ٷ��ĵ�����ز�������](https://www.oceanbase.com/docs/community-observer-cn-10000000000450633)

## ����sql����

```sql
--- ɾ�����еı�
SELECT CONCAT('DROP TABLE IF EXISTS ', table_name, ';') FROM information_schema.tables WHERE table_schema = '���ݿ���';
--- �鿴�汾��  5.7.25-OceanBase-v3.2.4.5
SELECT version();
--- ��ȡÿ������ֶ�
show columns from zenger.algojr_tanlzindex2;
--- �鿴������
select * from information_schema.statistics a
where table_schema=database() AND lower(a.`TABLE_NAME`) = lower('thisstp_makerduty') AND a.`INDEX_NAME` = 'PRIMARY';
```

# go��װOceanDB����

[go��װOceanDB����](https://www.alibabacloud.com/help/zh/apsaradb-for-oceanbase/latest/go-driver-connection-oceanbase-database)

�������������غ�ִ�У�`go install \path\to\github.com\go-sql-driver\mysql`,��`D:\GO\github.com\go-sql-driver\mysql` (�鷳��û��)

�����������Զ����а�����

```shell
# ͨ����������
set http_proxy=http://127.0.0.1:7890
# ͨ������ok
go env -w GOPROXY=https://goproxy.cn,direct
go get -u github.com/go-sql-driver/mysql
```


�鿴���İ�װ·����
�� Go �У���װ�İ��ᱻ���ص� $GOPATH/pkg/mod Ŀ¼�£������ݰ汾�Ŵ洢����Ӧ����Ŀ¼�С���ˣ�����ͨ�����²������鿴 github.com/go-sql-driver/mysql ���İ�װ·����
1. �������л��ն˴���,ִ������ go env GOPATH���鿴���� GOPATH ·����
2. �� $GOPATH/pkg/mod Ŀ¼���ҵ� github.com/go-sql-driver/mysql Ŀ¼�����е���Ŀ¼����Ӧ���밲װ�İ汾����ͬ


## �ű���������

1. �Ȼ�ȡÿ���汾�������޸�
2. ����ÿ���汾����ȡ�漰�����޸ĵı���`thisstp_makerduty`Ϊ�����Ĵ���sql���
   - `show create table zenger.algojr_tanlzindex;`
3. ����`thisstp_makerduty`����sql,�½�һ�����ݱ�`thisstp_makerduty_bak`,����������
4. ��ԭ������ݿ���һ�ݵ����ݱ�
   - `INSERT INTO table_b SELECT * FROM table_a;`
   - ����������Ľṹ��ȫһ�£��ұ��ݱ�Ϊ�գ������������������ƣ��ٶȷǳ��죬10w������������㶨
4. ɾ��ԭ�������ݱ�ĵ�����������Ϊԭ��
    - `DROP TABLE IF EXISTS table_name` 
    - `ALTER TABLE algojr_tanlzindex1 RENAME TO algojr_tanlzindex2;`



