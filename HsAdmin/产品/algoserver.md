# algoserer

1. Ϊɶ��Ī������ֻ������1���߳��ˣ�
   - û�ҵ�so����ͬһ���˺��ע�⻷��������·��

2. ����ɽ������޷�����
   - ���в�����Algotran��appcom��������AT��appcom����Ȼ������core
   - �������core���ұ��˵Ļ���һ�����ų����ķ�������⣬������ֻ�Ķ�appcom��algoserver_as.xml��
   - �����ȡʧ�ܣ������޷����� =�� �ұ���Ҫ����������������õ�hqserver.xml
   - ������ʼʱ�䲻�ܴ��ڷ�������ʱ�� =�� �޸Ľ���ʱ�α�
     - `update algojr_texectimeinfo set day_exec_time_range='093000-113000;130000-210000' where market_no=1;`

3. algoserver�ֱ�
   - �����󣬲���վ���޷���վ����ŲŻ����
   - Ϊɶalgoserverͣ�ˣ�ѯ�۲��Ի��������У�Ȼ������ֹͣ���ͺ�Ҳ��ֹͣ��


Algoserver���������ļ�����`mainsvr.36.out`,��ʾδ����ı�ʶ����

` LOAD FUNCTION LIB [algo_account_strategy]
FAILURE!!![/home/zengzg/algoserver/appcom/libalgo_account_strategy.so:
undefined symbol: _ZN4core11COptionInfo13GetOptionTypeEv`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230620142646.png" alt="20230620142646" width="1650" >

����һ���Ƕ�̬���ӵ�ʱ���Ҳ�����Ӧ�ı�ʶ����������һ��QQTest�ĺ�����

�����`ldd -r libalgo_account_strategy.so` => �鿴so�����Ŀ��δ�����symbol

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230620143106.png" alt="20230620143106" width="850" >

Ȼ���޸�makefile�ļ��������õ�ͷ�ļ����Լ�������so�ӽ�ȥ:

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230620142956.png" alt="20230620142956" width="450" >


��̬���һ���ô����ǣ���������Ŀ�`libstrategy_public2.so`��Ҫ����(���һ��������һ������ת��)��`libalgo_account_strategy.so`�ǲ���Ҫ����,���̷ֱ����һЩso


����Ǳ��صĵ�һ��������ʾ�������⣬������ȷ�������������ӵ�ʱ��û���ӵ�ͷ�ļ�:[�ο�����](https://www.cnblogs.com/SchrodingerDoggy/p/15464919.html)
=> �����

