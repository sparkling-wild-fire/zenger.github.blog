# gdb����

## �۲��

�۲���������

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152240312.png" alt="202306152240312" width="450px">

- ��д�۲�㣺`watch gdata`,��ִ��`gdata=1`������ʱ���ͻᴥ���ù۲�㣬ͣ������

- �۲���ΪӲ���۲�������۲�㣨ִ�к�������Ӱ�����ܣ�������һ��Ĳ���ϵͳ����Ӳ���۲��

- �������������̣߳�����ֻ��Ϊ����һ���߳����ù۲�㣬��ͨ��
`watch gdata thread 3`ʵ�֣�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152248765.png" alt="202306152248765" width="450px">

- �����۲�㣺
`watch gdata1+gdata2>10`,ֻҪ�̵߳�������ֵ��Ӵ���0���ͻ�ͣ����

## �����

�ڴ����У����Ǿ�����ʹ��try catch throw����׽�쳣�����ļ�ȷʵ���ڴ治��ȣ��������ǰ������ǲ�׽���Ƶ�bug������һ������Ķϵ㣬����Ϊ��
`catch event`,��������event����¼�ʱ������ͻ�ֹͣ����

Ϊʲô�ϵ���治�˲���㣬��Ϊ�ڴ�����Ŀ�У�try catch�����Ĵ���ǳ��࣬���ǲ����ܴ���ô��ϵ㣬����ֻҪ����һ������㣬�����쳣���У������ù��������׳����쳣��

1. �������԰���:

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152302610.png" alt="202306152302610" width="450px">

���Ͽɷ��֣�����Ϊ��δ��˸�0�������׳��쳣�����ˣ����ǻ����Լ����л���2��֡�鿴Ϊʲô�ᴫ��0����...

ע�⣺������ǲ�����¼��������������쳣���� catch catch��catch throw����ô����һ���쳣ʱ�����ж�����

2. ����ϵͳ����

ͨ��
`catch syscall ϵͳ����/ϵͳ��`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152310723.png" alt="202306152310723" width="450px">

��close����Ϊ�����ڳ�������ʱ������ϵͳ���ܻ����һЩclose���������Ǵ����е�close���Ĳ������������ǲ����˺ܶ����õ��¼���
��ʱ������������ǵ�close����ǰ����ϵ㣬�ȳ���ִ�е�����ϵ�ʱ����ȥ����ϵͳ�¼���

3. ���õĲ�׽�¼�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152315407.png" alt="202306152315407" width="450px">
 