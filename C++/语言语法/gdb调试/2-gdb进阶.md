# gdb����

## �۲��

�۲���������

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152240312.png" alt="202306152240312" width="450px">

- д�۲�㣺`watch gdata`,��ִ��`gdata=1`������ʱ���ͻᴥ���ù۲�㣬ͣ������

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

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152302610.png" alt="202306152302610" width="850px">

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
 
## �鿴��������

��;��
1. �鿴�����Ĵ�С���ڴ沼�ֵȣ�������ʱ����ʡ�ڴ�ռ䣬���л�ʱ����ʡ�洢�ռ䡣
2. ����`����+��ַ`��ӡ��Ϣ�ľ������ݡ�(��һ��һ���F2��ʱ���⵽�������ֻ�ܵõ���ַ����֪�����ͣ�������Ҳ�ܰ������Ų�һЩ���⣬�����а���)

���
1. �鿴�ṹ�壬�࣬�������
- whatis�鿴���ͣ������ã�

  <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306252227196.png" alt="202306252227196" width="450px">

- ptype /r /o(�ڴ沼��) /m /t
  - ����`test_1 *test2=new test_2()`,ֻ����ʾ`test_1`���ͣ�������ʾ������`test_2`
  - `set print object on`�򿪿��غ󣬾ͻ���ʾ����������
  
    <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306252232029.png" alt="202306252232029" width="450px">
  
  - /o�������鿴�ڴ沼�ּ��Ż�
  
    <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306252237205.png" alt="202306252237205" width="450px">
    
- i variables
  - �鿴������Ϣ

## ���̵߳���

### Linux���̳߳���
- ʹ��pthread��Linuxϵͳ�µĶ��߳���ѭPOSIX�߳̽ӿڣ��������������Ҫ����`-pthread`
```C++
#include<pthread.h>
pthread_create
pthread_join
```
- ȱ�㣺���ܿ�ƽ̨��������win�±���ִ��

### C++��ƽ̨���߳�

C++�߳��֧࣬��ȫ�ֺ��������͵ľ�̬��������ͨ�����������ַ�ʽ�£�sleep�Ⱥ���ҲҪ���߳����sleep_for()����

```C++
#include<thread>
int data=10;
thread t1(&test_thread,(void*)&data);
thread t2(&test::do_work_1);

test test3;
thread t3(&test::do_work_2,test3);
```

ʵ����

```C++
include <iostream>
#include <cstring>
#include <thread>
using namespace std;
class test
{
public:
        test(){}
        virtual ~test(){}
public:
        static void do_work_1()
        {
                cout << "do work 1" << endl;
                std::this_thread::sleep_for(std::chrono::seconds(2));
                cout << "thread do work 1 exited" << endl;
        }
        void do_work_2()
        {
                cout << "do work 2" << endl;
                std::this_thread::sleep_for(std::chrono::seconds(2));
                cout << "thread do work 2 exited" << endl;
        }
        void do_work_3(void *arg,int x,int y)
        {
                char *data = (char*)arg;
                cout << "do work 3:" << data << ",x=" << x << ",y=" << y << endl;
                std::this_thread::sleep_for(std::chrono::seconds(2));
                cout << "thread do work 3 exited" << endl;
        }
};
void test_thread(void *data)
{
        int *val = (int*)data;
        cout << "thread data:" << *val << endl;
        std::this_thread::sleep_for(std::chrono::seconds(2));
        cout << "test thread exited" << endl;
}
int main(int argc,char** argv)
{
    int data=10;
    thread t1(&test_thread,(void*)&data);   // ȫ�ֺ���

    thread t2(&test::do_work_1);    // ��̬��Ա����

    test test3;
    thread t3(&test::do_work_2,test3);    // ��ͨ��Ա��������Ҫ��һ�������

    test test4;
    thread t4(&test::do_work_3,test4,(void*)"test",10,20);   // ��ͨ��Ա����������
    
    t1.join();
    t2.join();
    t3.join();
    t4.join();
    cout << "threads exit" << endl;
    return 0;
}
```


## ���̵߳���

�����������ʵ��Ϊ������ `t1.join();`���д��϶ϵ�,����`info threads` �� `i threads`�鿴��һ�����̺߳��ĸ����߳�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306292145141.png" alt="202306292145141" width="850px">

����,ǰ������ֱ��ʾ�̵߳�ַ���̺߳š��߳�����LWP��ʾ���������̣�Ҳ�����߳�


- ͨ��bt����ֻ�ܲ鿴��ǰջ֡�����Ҫ�鿴�����̵߳�ջ֡����Ҫ���߳��л�Ϊ��ǰ�̣߳���ǰ�߳�ǰ����`*`���ţ���鿴����`thread 2`

* ���̣߳�1���̣߳�����ջ��

  <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306292207394.png" alt="202306292207394" width="450px">

* 2���̵߳���ջ��

  <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306292209129.png" alt="202306292209129" width="850px">

- �̲߳��ң�thread find (�̵߳�ַ���̺߳š��߳���)
- Ϊ�߳����öϵ㣺 `b ~ thread  �߳����`����������߳���ţ����е��̶߳�����������ϵ㣨һ���ڶ���߳�ʹ��һ����ں������ֳ���ʹ�ã�
- Ϊ�߳�ִ�����`thread apply`,�����л���ǰ�߳�
  - Ϊ�����߳�ִ�����`thread apply 3 i args`
  - Ϊ����߳�ִ�����`thread apply 1-5 bt`, ��������ʱ�����߶��߳���Դ��ͻʱ���鿴���̵߳���ջ�ܸ���������
  - �鿴�����̣߳�`thread apply all i locals`
  - �̺߳ź���ԼӲ�����`thread apply 1-5 -s/-q i locals `
- �����߳���־��Ϣ
  - `show print thread-events` => ���̴߳����ͽ��������ӡ��Ϣ
  - `set print thread-events off/on` => �����Ƿ��ӡ�߳���־

tip: thread �ڿ�ͷʱ��һ�㶼������`t`����

���̵߳��Է���������proc�̳߳صĵ��ԣ���һ������ַ������̺߳���Ҫ���е���Ӧ�����߳̽��е���

- �磺�����ڿ�Ψһ��ʱ�����������������һ�����ܺţ�����Щ�����Ƿַ�����ͬ��proc�̣߳����ؾ��⣩�ģ�������attachһ����������һ���ϵ��Ҫ����������֪����������Ǳ��ĸ��߳̽����ˣ��л�����Ӧ���̺߳�
��ȥִ��`n`�������Ȼ�������ֵ�������`n`�����ȥ������ִ���ˣ�������Ϊ��һ���߳���������֮ǰ�Ķϵ㣩

- ͬʱע�⣬cres��ܲ�֧�ֿ��ظ���������������������ֱ��core����

## ִ�������������

���ڵ��Ե�ʱ����Ҫִ��shell�����鿴ջ֡ʱ����Ҫ�鿴��ϵͳ���ڴ棬��ʱ�����ǲ���Ҫ�˳�gdb���¿�shell�ն�

- `shell  free -m`  , shell����ؼ���Ҳ�����ã����� ��`! ping baidu.com`
  - �ܵ���� `pip i locals | grep t1`  �� pipeҲ������ | ����
    - ����������ɸѡ������Ϣ��`| thread apply all bt | wc`
- ��������Ϣ�浽�ļ�����core dump�ĵ�����Ϣ
  - `set logging file debug.txt; set logging on` : ��ָ���ļ�������������Ĭ�ϴ浽 gdb.txt
  - `set logging overwrite`, ��ָ������ģʽ��Ĭ����׷�ӵķ�ʽ������ļ���