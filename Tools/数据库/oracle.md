# oracle

[������ݿ����½���](https://blog.csdn.net/interestANd/article/details/126893081)

���ݿ��������
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
# ����
- startup��`ORA-01012: not logged on`
  - `shutdown abort`����startup
-  �������ӱ��������ݿ�ΪɶͻȻ���Ӳ��ϣ�
  - ����ǽΪɶ�����Լ������ˣ����˾���