# OT�ճ�ʼ���鵵ʧ��

## ��������

1. �鵵����������ض�
2. �ǽ��ױ�鵵ʧ�ܣ��Ѵ�����������С��`hstodb#1`������ύ�����漰��thisstp_combiposition_buf��`Error on observer while running replication hook 'before_commit'`��

## �����Ų�

### sql�ض����� 

�鿴�鵵sql������ôһ�Σ�

```oracle
SELECT
GROUP_CONCAT(a.column_name) AS column_name
FROM
    information_schema.COLUMNS a
WHERE
    lower(a.table_name) = 'tstp_instructionstock'
    AND a.TABLE_SCHEMA = Database()
    AND a.column_name in (
SELECT
    GROUP_CONCAT(b.column_name) AS column_name
FROM
    information_schema.COLUMNS b
WHERE
    lower(b.table_name) = 'thisstp_instructionstock'
    AND b.TABLE_SCHEMA = Database()
    AND a.column_name = b.column_name
)
```

���ԣ�������GROUP_CONCAT�������£���ȻOTû�Խӹ�mysql8������Ҳ�������뵽�����ݿ����õ����⣬���ֳ�ȷ���˶Խӵ����ݣ�ȷʵ��mysql8������
����group_concat_max_len,��ƴ�Ӵ����ȱ䳤���У��ڲ��𻷾�ʱ����˾Ҳ�ᷢ���ͻ���������͹��ߵĲ������ã�

### �鵵����

����`Error on observer while running replication hook 'before_commit'`���⣬�����ڹ鵵���ݳ�����������

�ͻ��Ǳ���mysql8-mgr��Ⱥ��������`group_replication_transaction_size_limit`����Ϊ150M,dba����ֵ�Ĵ�󣬹鵵�����ˡ�

����ʵ����Ĳ����ڴˣ�����ץ�����ص㣺`thisstp_combiposition_buf`���ű�:
���ȣ�����鵵�������ˣ���Ӧ��ֱ��ȥ�޸����ò������ر����ڼ�Ⱥ�����������������ܻ���������ͬ�����������⣬
����Ӧ�ý��������ֳ�С����

��Σ�Ϊɶ���ű����ô��ģ�������Ϊ`thisstp_combiposition_buf`��ᶨʱ��¼ÿ�γֲ�ͬ���ļ�¼��ÿ��ִ��3�Σ�
���ڿͻ��ڹ����ڼ�û�йرպ�̨����������������������ֶ�ʱ���񣬵��±����ݴﵽ��40W��,�Դ������ݿ�Ϊ�����鵵���ݲ�����10W�У�
��ˣ����յĽ���취�Ƕž����ű�����������ݣ���ǽ����ղ���ͬ������ʱ��������ݣ�