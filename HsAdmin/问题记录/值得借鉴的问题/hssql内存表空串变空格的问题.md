# hssql�ڴ��մ���ո������.md

���ⳡ����������ί�г���ʱ��������û���⣬������������ȥ������ᱨ��ί�з���ش�

���ۣ�����һ��byte�����ݿ��ֶΣ�����fsc_todb������+���������������һ���մ����һ���ո�''=>' '

1. ��ҵ����뷢�֣��ڵ�O3�ӿ�ʱ����Ҫƴ��entrust_no��futures_direction�������ֶ�ȥӳ���ȡO3��ί�з��򣬲�ѯ����Ϊ��
```txt
���futures_direction�ǿ�
    ��ô��ѯ����Ϊ where entrust_no=@entrust_no
���futures_direction���ǿ�
    ��ô��ѯ����Ϊ where entrust_no=@entrust_no#futures_direction
```

��futures_direction��Ӧ���ǿյģ�ȴ����˿ո񣬵���ί�з����ѯʧ��

2. Ϊɶfutures_direction�����ǿո�

futures_directionȡ���ڴ��tstp_entrusts_s��futures_direction�ֶ�

��ί��ʱ����tstp_entrusts_s�����һ��ί�м�¼��futures_direction��ֵΪ''����ѯ����`where futures_direction =''`�ſ��Բ����������

�첽��⵽oracle���ݿ⣨fsc_todb�������futures_direction��ֵΪnull����ѯ����`where futures_direction is null`�ſ��Բ����������

����������futures_direction��ֵΪ�ո�' '����ѯ����`where futures_direction = ' '`�ſ��Բ����������

����futures_direction�ھ�����⡢����������ֵ�ı仯Ϊ'' =>  null  =>  ' '

3. Ϊɶ����ʱ��futures_direction���null  =>  ' '

��oracle���ݿ��У�futures_directionΪchar(1)���ͣ�Ĭ��ֵΪ' '

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241031185246.png" alt="20241031185246" width="850">

�з����ĵĺ���`LoadFromDb()`������Oracle��OCI�ӿ�OCIStmtExecute
,���ֶ�Ϊnullʱ������ӿڻ��ֽڲ���ո񣬱���char(10)���;ͻᲹ��10���ո񷵻�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241031185210.png" alt="20241031185210" width="850">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241031185556.png" alt="20241031185556" width="850">

�з����ĶԶ���ո���ֶ����˴�����ȥ����Щ�ո�
���ǵ����ո��û�У���Ϊ���ǵ������ո�����Ǵ�����һЩ����ĺ�����������һ��ռλ������ʾ������ֶ����ж���

������futures_direction�͸�ֵ�ɿո���ص��ڴ������

Tip:

���ԭ�����ڻ���û������Ų飬���������㻹����Ҫע���£�
1. todb_modec��������Ϊ1�����ֶ�ֵΪ�մ�ʱ��������䵽oracle����ΪɶҪ���null�����ǿմ���Ҳ����Ĭ��ֵ
2. �����һ���ձ����⣬����һ��byte���ֶξ���fsc_todb������+���������������һ���մ����һ���ո񣬿մ��Ϳո�Ĵ�����Ҫҵ���źͿ����һ��Լ�����з����ĵ�ͬ��˵�ģ�