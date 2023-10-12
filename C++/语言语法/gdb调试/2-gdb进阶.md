# gdb进阶

## 观察点

观察点的相关命令：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152240312.png" alt="202306152240312" width="450px">

- 写观察点：`watch gdata`,当执行`gdata=1`等命令时，就会触发该观察点，停下来。

- 观察点分为硬件观察点和软件观察点（执行很慢，很影响性能），现在一般的操作系统都是硬件观察点

- 加入有两个子线程，我们只想为其中一个线程设置观察点，可通过
`watch gdata thread 3`实现，

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152248765.png" alt="202306152248765" width="450px">

- 条件观察点：
`watch gdata1+gdata2>10`,只要线程的这两个值相加大于0，就会停下来

## 捕获点

在代码中，我们经常会使用try catch throw来捕捉异常，如文件确实，内存不足等，捕获点就是帮助我们捕捉类似的bug，它是一个特殊的断点，命令为：
`catch event`,即当捕获到event这个事件时，程序就会停止下来

为什么断点代替不了捕获点，因为在大型项目中，try catch这样的代码非常多，我们不可能打那么多断点，我们只要设置一个捕获点，捕获到异常就行，而不用管是哪里抛出的异常。

1. 捕获点调试案例:

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152302610.png" alt="202306152302610" width="850px">

从上可发现，是因为入参传了个0，导致抛出异常。至此，我们还可以继续切换到2号帧查看为什么会传个0过来...

注意：捕获点是捕获的事件，而不仅仅是异常。如 catch catch、catch throw，那么产生一个异常时，会中断两次

2. 捕获系统调用

通过
`catch syscall 系统函数/系统号`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152310723.png" alt="202306152310723" width="450px">

以close函数为例，在程序启动时，操作系统可能会进行一些close（不是我们代码中的close）的操作，导致我们捕获到了很多无用的事件，
这时候可以先在我们的close函数前打个断点，等程序执行到这个断点时，再去捕获系统事件。

3. 常用的捕捉事件

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152315407.png" alt="202306152315407" width="450px">
 
## 查看对象类型

用途：
1. 查看结果体的大小，内存布局等，在运行时，节省内存空间，序列化时，节省存储空间。
2. 根据`类型+地址`打印消息的具体内容。(在一层一层解F2包时，解到最后往往只能得到地址，不知道类型，不过这也能帮我们排查一些问题，后文有案例)

命令：
1. 查看结构体，类，派生类等
- whatis查看类型（不常用）

  <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306252227196.png" alt="202306252227196" width="450px">

- ptype /r /o(内存布局) /m /t
  - 对于`test_1 *test2=new test_2()`,只会显示`test_1`类型，不会显示派生类`test_2`
  - `set print object on`打开开关后，就会显示派生类型了
  
    <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306252232029.png" alt="202306252232029" width="450px">
  
  - /o参数，查看内存布局及优化
  
    <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306252237205.png" alt="202306252237205" width="450px">
    
- i variables
  - 查看变量信息

## 多线程调试

### Linux多线程程序
- 使用pthread（Linux系统下的多线程遵循POSIX线程接口），编译和链接需要加上`-pthread`
```C++
#include<pthread.h>
pthread_create
pthread_join
```
- 缺点：不能跨平台，不能在win下编译执行

### C++跨平台多线程

C++线程类，支持全局函数、类型的静态函数与普通函数，在这种方式下，sleep等函数也要用线程类的sleep_for()函数

```C++
#include<thread>
int data=10;
thread t1(&test_thread,(void*)&data);
thread t2(&test::do_work_1);

test test3;
thread t3(&test::do_work_2,test3);
```

实例：

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
    thread t1(&test_thread,(void*)&data);   // 全局函数

    thread t2(&test::do_work_1);    // 静态成员函数

    test test3;
    thread t3(&test::do_work_2,test3);    // 普通成员函数，需要传一个类对象

    test test4;
    thread t4(&test::do_work_3,test4,(void*)"test",10,20);   // 普通成员函数，带参
    
    t1.join();
    t2.join();
    t3.join();
    t4.join();
    cout << "threads exit" << endl;
    return 0;
}
```


## 多线程调试

还是以上面的实例为例，在 `t1.join();`这行打上断点,利用`info threads` 和 `i threads`查看，一个主线程和四个子线程

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306292145141.png" alt="202306292145141" width="850px">

其中,前面三项分别表示线程地址、线程号、线程名，LWP表示轻量级进程，也就是线程


- 通过bt命令只能查看当前栈帧，如果要查看其他线程的栈帧，需要将线程切换为当前线程（当前线程前面有`*`符号）后查看，如`thread 2`

* 主线程（1号线程）调用栈：

  <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306292207394.png" alt="202306292207394" width="450px">

* 2号线程调用栈：

  <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306292209129.png" alt="202306292209129" width="850px">

- 线程查找：thread find (线程地址、线程号、线程名)
- 为线程设置断点： `b ~ thread  线程序号`，如果不加线程序号，所有的线程都会命中这个断点（一般在多个线程使用一个入口函数这种场景使用）
- 为线程执行命令：`thread apply`,不用切换当前线程
  - 为单个线程执行命令：`thread apply 3 i args`
  - 为多个线程执行命令：`thread apply 1-5 bt`, 发生死锁时，或者多线程资源冲突时，查看多线程调用栈能更快解决问题
  - 查看所有线程：`thread apply all i locals`
  - 线程号后可以加参数：`thread apply 1-5 -s/-q i locals `
- 控制线程日志信息
  - `show print thread-events` => 如线程创建和结束都会打印信息
  - `set print thread-events off/on` => 设置是否打印线程日志

tip: thread 在开头时，一般都可以用`t`简替

多线程调试方法可用于proc线程池的调试，当一个请求分发给子线程后，需要进行到对应的子线程进行调试

- 如：我们在控唯一性时，往往多次连续请求一个功能号，而这些请求是分发给不同的proc线程（负载均衡）的，所以在attach一个进程命中一个断点后，要先利用命令知道这次请求是被哪个线程接收了，切换到对应的线程后，
再去执行`n`等命令，不然会产生奇怪的现象（如`n`命令看上去是往上执行了，这是因为另一个线程又命中了之前的断点）

- 同时注意，cres框架不支持可重复锁，遇到锁冲入的现象会直接core掉。

## 执行命令与结果输出

如在调试的时候需要执行shell命令，如查看栈帧时，需要查看下系统的内存，这时候我们不需要退出gdb或新开shell终端

- `shell  free -m`  , shell这个关键字也可以用！简替 ：`! ping baidu.com`
  - 管道命令： `pip i locals | grep t1`  ， pipe也可以用 | 简替
    - 这个命令可以筛选调试信息：`| thread apply all bt | wc`
- 将调试信息存到文件，如core dump的调试信息
  - `set logging file debug.txt; set logging on` : 不指定文件名，后续调试默认存到 gdb.txt
  - `set logging overwrite`, 不指定覆盖模式，默认以追加的方式输出到文件中