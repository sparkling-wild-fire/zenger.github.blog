# oracle�鿴����������

����һ��Ӧ�ó����ܸĶ����ݿ⣬������Ӧ�ó��򶼲��ܸĶ�ʱ��������˵��������

[�ο�����](https://www.php.cn/faq/488267.html)

## �鿴��
ִ������:`select * from v$locked_object;`  (�еı�û�������ͼ)

�������`�����ͼ������`�Ĵ�������Ϊ�û�Ȩ�޲���

��ϵͳ��ݵ�½oracle��������Ȩ��
`grant select  any dictionary to �û���;`

�ٴ�ִ����������

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/c9470acebb96289e482e7feaedca2d1.png" alt="c9470acebb96289e482e7feaedca2d1" width="450">

����locked_mode��ȡֵΪ��

0��none
1��null ��
2��Row-S �й���(RS)�����������sub share
3��Row-X �ж�ռ(RX)�������е��޸ģ�sub exclusive
4��Share ������(S)����ֹ����DML������share
5��S/Row-X �����ж�ռ(SRX)����ֹ�������������share/sub exclusive
6��exclusive ��ռ(X)����������ʹ�ã�exclusive

ֱ�Ӹ���process����(`Linux:kill -9 10856`;`Windows:taskkill /pid 10856 /F`)����,�����鿴����ϸ�����Ϣ����ʹ��������������鿴��

- ����object_id�鿴������`select * from user_objects where object_id = 269827;`

- �鿴�����������У�`select * from ALGOJR_TPARAMETERS for update skip locked;`

## ����

������ִ����`delete from tabename`��Ȼ���ֺܶ�������ˣ�����ǰ����ж���0,

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/57de8255ec9ee9b330a37c2e1975c70d.png" alt="57de8255ec9ee9b330a37c2e1975c70d" width="450" >

Ȼ��ִ��ccommit�����е��������ͷ��ˡ�