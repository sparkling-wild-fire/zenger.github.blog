# ����

RedisҲ��һ�鹲���ڴ棬UFT����������ݲ�һ�µ������𣿣�����˵û�������ɣ�


## �������²���

uft�����ò��ǻ��棬ֻ�Ǽӿ����ݲ�������Ϊ����Ĳ�ѯ�߼��ǣ������ѯʧ�ܵ�ʱ�򣬻�����ݿ⣻
��uft��Ҫô��uft�����õı�����һЩ�����ͨ���첽�߳��Զ���⣬��һЩ����Ҫ˫д����Ҫô�����ݿ�

�Զ���⣺
- �Զ����ĺô�����������ı����Խ����ݿ�Ķ��д�����������Ϊһ��д�����
- ȱ�㣺�����Ѷȸߣ�һ���Բ��ܱ�֤�������Ĺ�����崻���

���ԣ�˫д+�Զ������Խ��ʹ��

#### ������������ݿ�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151056808.png" alt="202402151056808" width="850px">

�̰߳�ȫ���⣺�Ȳ��������ٲ������ݿ⣬�Լ��Ȳ������ݿ⣬�ٲ������棬�������̲߳���ȫ��

��һ������д���ݿ�ʱ������һ���ԣ�һ������д����ʱ������һ���ԣ�����һ�ֵĿ����Խϵ�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151104101.png" alt="202402151104101" width="850px">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151105342.png" alt="202402151105342" width="850px">


## ��������

1. ���洩͸���������������ݿ�ͻ����в�����

���������
- ����ն��󣬶��ڲ����ڵ�����Ҳ��redis�������棬ֵΪnull��������һ��ʱ��϶̵�TTL
- ��¡���������ڲ�ѯredis֮ǰ�������ж����ݴ治����redis��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151635585.png" alt="202402151635585" width="850px">

2. ����ѩ����������ȫ��keyͬʱʧЧ

���������
- TTL�������ֵ����ֹ����key��ͬһʱ�����
- ����Ӽ�Ⱥ
- ������ҵ����ӽ����������ԣ���redis崻�ʱ��������������
- �༶���棺�������nigix���ö������

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151643573.png" alt="202402151643573" width="850px">

3. ��������������ȵ�keyʧЧ

���������
- ���������ȼ�������ѯ���ݿ�󣬸��»��棬���ͷ����� �߲����£��кܶ��̻߳Ῠס����ȡ������
- �߼����ڣ���redis���ȵ�key�д���һ���߼��Ĺ���ʱ�䣨����redis�Դ���TTL�����߳�1��ѯ������ں��Ȼ�ȡ�����¿�һ���߳�2ȥ����ѯredis���������ݿ���»������ݣ�Ȼ��ֱ�ӷ��ؾ����ݣ�
  �����̲߳�ѯ���淢�ֹ��ں�ȥ��ȡ�������������ȡ������ʧ�ܣ���ֱ�ӷ��ؾ�����

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151649373.png" alt="202402151649373" width="850px">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151659995.png" alt="202402151659995" width="850px">