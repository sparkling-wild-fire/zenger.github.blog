# gdb����

gdb -pid=`mt���̺�`
b F���ܺ�     => ��ϵ�F440281002��;ֱ������ʧ����
r

## ��;����ʵ��

�������ΪOracleռ�ù����ڴ棬Ȼ��ϵͳ��������̸�ɱ������?

��ͼ����δ������Լ����ڴ�, ����ͼ��û��дȨ�޵��ڴ��ַд����ʱ,ϵͳ�ͻᷢ�͸�����`11`�����ź�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230614103202.png" alt="20230614103202" width="450" >

[valgrind](https://zhuanlan.zhihu.com/p/298015939)

[��core](https://www.cnblogs.com/rainisraining/p/14715533.html)

## algoserver���� (gdb attach)

������

����python���Ե�so������ɹ�������һ���оͲ���core������ջΪ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230627171450.png" alt="20230627171450" width="850" >

�����룬������ջ֡��δ���õ�����ջ֡�����ǵ��õ�`GetProviderID()` ,�Դ��ҷǳ��Ի�

1. ���Ȳ鿴������ԵĽ��̺ţ�

    `ps -ef | grep -E 'algoserver_as_zengzg.*37.out'`������37��ʶpython����Ϊ��37�����ԣ�����uft�Ĳ���վ����Ϣ��鿴

2. gdb�����������

   - `gdb --pid/attach ���̺�`
   - �ڵ�����ջ֡�Ӷϵ�`b StrategySchemeImpl.cpp:430`
   - ����ִ��`c`(�������û����������ϵ㣬�����ڵ��ĸ�ջ֡����һ���ϵ㣬Ȼ��`c`��ת��`StrategySchemeImpl.cpp:430`)
   - ���е�����ջ֡��`n`ִ�У�����python�����յ��ж��ź�
   
   �����������£�
    
    <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230627172015.png" alt="20230627172015" width="850" >

���ԣ��ڵ�����ջ֡��ʱ���Ӧ�ò���core�ˣ��ڶ���ջ֡Ӧ����python����������ʱ������ģ����Եڶ���ջ֡Ϊʲô��д�����core�أ�������ˣ�����;۽���`GetProviderID()`��������ˡ�

�����`GetProviderID()`��src/algo�ж��壬�����ȡ���µ�src���룬����algo������⡣����algo��so�����������µģ�ΪʲôҪ�����µ�src�ر�ſ����أ�=> �ѵ����so���������µ�src�������ɵģ�=> �����ܰ���


## gdbע��

��ϵ�����У��ǻ�ûִ�еģ�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230628101214.png" alt="20230628101214" width="450" >

No source file named StrategyApiDataInfoImpl.cpp��������ļ���������

info source =�� No current source file.    =�� �����ʱ��û�м�-g  =�� ����Ϊû��makeclean��ԭ����

## ע��

��Ҫ֪��һ������ִ�е������ж��ˣ�ע�⣺
- ֱ������س���Ĭ��ִ����һ������
- ע����for����`n`��������������
- ������mt������ʱ��pid����Ȼ����1��pid����mt��ҵ�
- ���öϵ����c����r��mt�ҵ�