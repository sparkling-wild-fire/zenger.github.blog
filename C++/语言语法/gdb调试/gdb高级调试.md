# gdb�߼�����

## ��תִ��

��ʱ��������ǰ���ִ�д��룬������������ת����12�У�
- �鿴��12�е�ַ��`info line 12`
- �ı�Ĵ�����һ��ִ�е�ַ��`p $pc=0x...`

�����ڿ�����12������һ���ϵ㣬Ȼ��`jump 12`

jump���
- ��ָ��λ�ûָ�ִ�У�������ڶϵ㣬ִ�е�ָ��λ��ʱ���ж����������û�жϵ㣬�򲻻�ͣ��������ˣ�����ͨ������ָ��λ������һ���ϵ�
- ��ת�������ĵ�ǰ��ջ֡����ջָ�룬���������������κμĴ���
- jump������ת����������ִ�У������ǽ���ֻ�ں�������ת������goto

## ����ִ��

undo����ʱ�����ǵ���̫���ˣ���Щ״̬���Ǻ����ˣ���Ҫ��ȥ�ٿ�һ��

Ҫʹ��undo���ܣ�Ҫ��ִ��record����,undo����ص����ڴ��Ĵ����е����ݣ�����޸����ļ����ݣ��ǲ��ܳ��ص�

undo���
- `rn`: ������һ��������`rs��rc`����������
- `reverse-finish`: �ص�������ʼ
- `record stop`: �˳�����ִ��

ע�⣺���̳߳���֧�����ֻ��������Ϊ���̹߳��������ַ�ռ䣬���̻߳��˺󣬻ᵼ�������̷߳����ڴ�ʱ����

## ֱ�ӵ��ú���

ֻ���ԵĹ����У�ֱ�ӵ����Լ�д�ģ��������Է�װ�ĺ�����
- p���ʽ������ʽ��ֵ����ʾ���ֵ�����ʽ���԰��������ڵ��Եĳ����еĺ����ĵ��ã���ʹ��������ֵ��void��Ҳ����ʾ
- call���ʽ��ͬ�ϣ�������ֵ��void�Ļ�������ʾvoid�ķ���ֵ

���ַ�ʽ����ʵ�ּ򵥵ĵ�Ԫ���ԣ�

����gdb������Լ�д�ĺ��������Եĳ�����Բ�Я��������Ϣ����Ȼ���ڵ��õĺ����ڲ����Ӧ�Ķϵ㣬Ȼ��������ķ���ֵ��  => ��Ԫ���Խ���ʹ��gtest

������Եĳ�����gdb��Ϣ����ô����ջ������ʾ��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012240754.png" alt="202307012240754" width="450px">

## �ϵ����

���������ʹ��`s`������
����ĳ���������繹�캯�������Խ��뺯��������finish��������Ч�ķ�ʽ��`skip����`

1. ��������������
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012243264.png" alt="202307012243264" width="450px">
2. ��ʱĳ���ļ������еĺ����Ҷ���������һ����д���鷳�����Բ���`skip file test.cpp`����
3. ��һ���ļ����µ�����cpp�ļ���`skip -gfi common/*.cpp`

## ���������Է��а�

���Ƿ����ͻ��ĳ���һ���ǲ���������Ϣ�ģ�һ�����ǽ�Լ�ռ䣬һ����Ҳ�Ǳ�����˾Դ�룬

����������һ�����ַ��а棺�����ͻ��ĳ���Ȳ���������Ϣ���ַ������ǵ���


1. ����һ��ȥ��-g������makeһ���汾��ͬʱ����һ������-g�����İ汾  => ����makefile��һ�����ڷ��У�һ������debug
2. ����������ȥ��-g����������strip���ߣ����԰ѵ�����Ϣȥ��������һ���µİ汾   => �Ƽ�����

�����ú󣬵��Է����汾����dump�ļ������������ֱ�ӵ��Է����汾��`bt, i args`������ǲ����õģ���ʾ��`No symbol table info available`

1. ���ǿ�������������Է��Ž��е��ԣ�`gdb --symbol=debug�汾 -exec=���а汾`
2. ���Խ�debug�汾�ĳ����еĵ�����Ϣ��ȡ������
    - `objcopy --only-keep-debug debug�汾���� debug.sym`
    - `gdb --symbol-debug.sym -exec=release�汾`

���������coreʱ��`gdb debug������ core.123`�Ϳ��Բ鿴���dump��


## �޸Ŀ�ִ���ļ�


������������һ�μ����Ȩ��Ĵ��룺
```C++
#include <iostream>
#include <cstring>
using namespace std;
int check_some()
{
        int x=100;
        return x;
}

int main(int argc,char** argv)
{
        if(check_some() == 100)
        {
                cout << "check failed!" << endl;
                return 1;
        }
        else
        {
                cout << "check successfully!" << endl;
        }
        //do somethings

        return 0;
}
```

��������£���Ӧ�����check failed, �������ǿ����޸Ŀ�ִ�г���100�ĳ���ȷ��ֵ����101

- `gdb --write ��ִ���ļ�`��д��ִ���ļ���Ĭ��gdb�ļ����Ƕ�ģʽ��

- `disassembler /mr check_some`�����

- `set {�ֽ���}��ַ = �޸ĵ�ֵ`

- `q`�˳��󱣴�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012316218.png" alt="202307012316218" width="450px">

�����ִ�г���û�е�����Ϣ����������`info functions`���鿴Դ�룬Ȼ���޸Ķ�Ӧ��ֵ

## �ڴ�й©���

valgrind�����󱨵������ �����������ϵͳ������ڴ棬����������̫�࣬�������ֻ�뿴ĳЩ�������Ƿ����ڴ�й©����valgrind�����Ե�̫�����ࡣ

- call malloc_stats()����������ǰ�鿴���ڴ���䣬���ú��ٴβ鿴���Ա����εķ��������

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021025395.png" alt="202307021025395" width="450px">

tip��������Ƿ�����1040���ֽڣ�����ȴ��1040���ֽڵ�й©�����������ģ���ΪC++��Ҫ16���ֽڵ�����ڵ����洢��Щ�ڴ���Ϣ

- call mallokc info(0,stdout)

## �ڴ���

valgrind̫���࣬��Ӱ������������ܣ���gdb���Թ���ҳ���ޣ���˿���
ʹ��gcc��������Լ���ڴ����⣬���ڴ�й©����ջ�����

makefile�ļ�������ѡ�`gcc ѡ�� -fsanitize=address`��ֻ�д���ִ�е��ˣ������ʱ��ͻᱨ�����
- ����ڴ�й©
- ����/ջ������������ⶼ��������������Ұָ��Ҳ�ǣ�
- ���ȫ���ڴ����
- ����ͷź���ʹ��

```C++
#include <stdlib.h>
#include <iostream>
#include <string.h>
using namespace std;
void new_test()
{
        int *test = new int[80];
        test[0]=0;
}

void malloc_test()
{
        int *test =(int*) malloc(100);
        test[0]=0;
}
void heap_buffer_overflow_test()
{
        char *test = new char[10];
        const char* str = "this is a test string";
        strcpy(test,str);
        delete []test;

}
void stack_buffer_overflow_test()
{
        int test[10];
        test[1]=0;
        int a = test[13];
        cout << a << endl;

}
int global_data[100] = {0};
void global_buffer_overflow_test()
{
        int data = global_data[102];
        cout << data << endl;

}
void use_after_free_test()
{
        char *test = new char[10];
        strcpy(test,"this test");
        delete []test;
        char c = test[0];
        cout << c << endl;
}
int main()
{
        //new_test();
        //malloc_test();

        //heap_buffer_overflow_test();

        //stack_buffer_overflow_test();
        //global_buffer_overflow_test();
        use_after_free_test();

        return 0;
}
```

## Զ�̵���

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021052003.png" alt="202307021052003" width="450px">



## �����ӽ���

���̴���һ���ӽ���ʱ����Ȼ�����ڲ�ͬ���ڴ�ռ䣨���̵�ַ�ռ������������pid��������Դ�����ӽ��̻�������һ���ģ����ڴ����ݣ��Ĵ�����

```C++
#include <iostream>
#include <fstream>
#include <string>
#include <sys/types.h>
#include <unistd.h>

using namespace std;

int main(int argc,char** argv)
{
        int data=100;
        cout << "begin fork" << endl;
        pid_t pid = fork();
        cout << "after fork,pid is " << pid << endl;
        switch(pid)          // 1. ֱ����18������Ӷϵ㣬�������̶�����ͣ����
        {
        case 0:
                data++;
                cout << "Child data is " << data << endl;
                cout << "My pid is " << getpid() << ",parent pid is " << getppid() << "#####\n" << endl;  // 23�жϵ�
                break;
        case -1:
                cout << "error" << endl;
        default:
                data++;
                cout << "Parent data is " << data << endl;
                cout << "My pid is " << getpid() << ",child pid is " << pid << "*****\n" << endl;  // 30�жϵ�

                break;
        }
        return 0;
}
```

�����ӽ�����Ҫ֪��дʱ���ƣ�

�縸�ӽ��������data++����101��һ��ʼ�����ӽ���ʱ���ӽ��̵�ҳ��͸����̵�ҳ����һ���ģ����ǵ������̻��ӽ��̸��Ĺ����ڴ��е�data����ʱ���ӽ��̻��¿���һ���ڴ�
����dataд�뵽������ڴ棬�������Լ���ҳ����磺211=> 0x3434  ����Ϊ  233 => 0x6424

### �����ӽ��̵���

���ȿ���������أ�`set follow-fork-mode parent/child`

����Ϊ�ӽ��̵��Ժ���23�мӶϵ㣬�ӽ��̽���������ϵ㣬����������ִ����ϣ��ӽ��̱�ɹ¶����̣�����23�еĴ�ӡ����������̱�Ϊ1

��ô���ӽ��̲���ɹ¶������أ�����`set detach-on-fork off`


`follow-fork-mode��detach-on-fork`����ģʽ������ͨ��show��ӡ����

### ���ӽ���ͬʱ����

�ڵ��Ե�ʱ�򣬸��ӽ��̶������У�ֱ������bt���ֻ���ӡ��ǰ���̵Ķ�ջ��Ϣ

inferior:

`i inferiors` ����鿴����

inferiors����ʷ���Ϊ�µȵģ������õķ������ڲ��ģ���Ϊ��Щ���̶���gdb�ڲ���һЩ����

ͨ������£�һ��inferior����һ�����̣���Ҳ����û�н�����inferior��֮��

ͨ�� `inferiors 1`�����ǿ��Բ鿴�����̵Ķ�ջ��Ϣ

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307011151094.png" alt="202307011151094" width="450px">

����ڵ�23�к�30�ж���ϵ㣬�������ϵ㶼������


## ���Զ����

һ��gdb sessison���Զ������ 

inferior������Ϊһ������װ���Գ���ķ���,һ�����Զ���

-  i inferiors: �鿴���Զ���
- add-inferior�����һ�����Զ���
- remove-inferior��ɾ��һ�����Զ��󣬲���ɾ����ǰ���Զ���

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012143335.png" alt="202307012143335" width="450px">

- attach pid: ��յĵ��Զ��󸽼ӽ���

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012145251.png" alt="202307012145251" width="450px">


- �����������̶���ִ�У�`set schedule-multiple on`������Ϊoff��������inferior�����ж�״̬

- ���2�ŵ��Զ������ǲ�������ˣ�Ҳ����detach��`detach inferiors 2`


## ���߳���������

һ���Ѿ����еĽ��̣��鿴�Ƿ��Ѿ�����

- `attach pid`�����ж�״̬
- `i threads`�鿴�����̣߳� `thread apply all bt`,�鿴�����̵߳Ķ�ջ����Ϣ̫�࣬��������all��
- �鿴����̵߳ĵ���ջ

�л�ջ֡��`f 5`����֪do_work1()��������ͣ����һ�У�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021210985.png" alt="202307021210985" width="450px">

���Կ���������߳�����������ʱ��һֱû����

- `p _mutes2`: �鿴���������˭ռ����

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021213631.png" alt="202307021213631" width="450px">

���Կ������߳�3ռ���ˡ������ַ����������ԣ����ԵĽ�����߳�3ȥ����_mutex1, ��_mutex���߳�1ռ���ˣ������γ�ѭ���ȴ�


��������ķ�ʽ��

- ˳��ʹ����
- �����������÷�Χ
- ����ʹ�ó�ʱ����


## core dump

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021218105.png" alt="202307021218105" width="450px">

���������ĳ�������Ҳ���Բ���core�ļ�


����core�ļ�������ԭ�򳣼����У�
- �ڴ����ʱʧ�ܣ����ڴ��Ǻܴ�ģ�һ����ջ�ڴ����ʧ�ܡ���д�ݹ�ʱ������������ջ������Ǿ��ǽ��̵Ķ���ջ�ռ�Ĳ�������
  - ulimit -a ���Բ鿴һ�����̷����ջ�ռ�
  - ջ��������Ų飬���ƻ��ܱߵ��ڴ���Ϣ
- �޵�����Ϣcore dump����



