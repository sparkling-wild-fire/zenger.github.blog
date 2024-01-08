# gdb����ʾ��

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

�����`GetProviderID()`��src/algo�ж��壬�����ȡ���µ�src���룬����algo������⡣�����淢�����ںϲ�algoserver��algotran����ʱ���µ����⣩

## V2���쳣

���룺
```C++
IF2UnPacker *lpRstrFactorResultSet = rstrFactorPacker->UnPack();
while(!lpRstrFactorResultSet->IsEOF()){}     // => ���б���
```

���ԣ�

1. �򿪿��أ�`set print object on`
2. �鿴�������ͺ͵�ַ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230728155355.png" alt="20230728155355" width="450" >

3. �鿴Message��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230728160508.png" alt="20230728160508" width="450" >

4. �鿴��ǰ���ݼ���

���������0x0, ��˵��v2���Ǹ��հ�������IsEoF����core

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230728160540.png" alt="20230728160540" width="450" >


## С�����¼

1. ���Ž��̣�gdb��ϵ����ʾ `Make breakpoint pending on future shared library load`
   - ���̺Ÿ��Ŵ���
2. gdb����so���ڱ��ص����������������Ժ��޷����жϵ�
   - ��Ϊ�����ĿⲢû�з��ͣ����´�ϵ�ĺ�����ƫ�Ƶ�ַ��ͬ����nm�ɲ鿴����ƫ�Ƶ�ַ��

����Ҳ���Ե��ԣ�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230803161759.png" alt="20230803161759" width="1250" >

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230803161928.png" alt="20230803161928" width="1250" >