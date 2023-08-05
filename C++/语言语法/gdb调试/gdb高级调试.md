# gdb高级调试

## 跳转执行

有时我们想向前向后执行代码，比如我们想跳转到第12行：
- 查看第12行地址：`info line 12`
- 改变寄存器下一行执行地址：`p $pc=0x...`

但现在可以在12行设置一个断点，然后`jump 12`

jump命令：
- 在指定位置恢复执行，如果存在断点，执行到指定位置时将中断下来，如果没有断点，则不会停下来，因此，我们通常会在指定位置设置一个断点
- 跳转命令不会更改当前堆栈帧，堆栈指针，程序计数器以外的任何寄存器
- jump可以跳转到其他函数执行，但还是建议只在函数内跳转，类似goto

## 反向执行

undo：有时候我们调试太快了，有些状态我们忽略了，需要回去再看一下

要使用undo功能，要先执行record命令,undo命令撤回的是内存或寄存器中的数据，如果修改了文件数据，是不能撤回的

undo命令：
- `rn`: 撤销上一步操作，`rs，rc`等命令类似
- `reverse-finish`: 回到函数开始
- `record stop`: 退出反向执行

注意：多线程程序不支持这种回退命令。因为多线程共享虚拟地址空间，本线程回退后，会导致其他线程访问内存时出错。

## 直接调用函数

只调试的过程中，直接调用自己写的，或者语言封装的函数。
- p表达式：求表达式的值并显示结果值，表达式可以包括对正在调试的程序中的函数的调用，即使函数返回值是void，也会显示
- call表达式：同上，但返回值是void的话，不显示void的返回值

这种方式可以实现简单的单元测试：

如在gdb里调用自己写的函数（调试的程序可以不携带调试信息），然后在调用的函数内部打对应的断点，然后检查输出的返回值。  => 单元测试建议使用gtest

如果调试的程序含有gdb信息，那么调用栈如下所示：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012240754.png" alt="202307012240754" width="450px">

## 断点相关

如果我们在使用`s`命令想
跳过某个函数，如构造函数，可以进入函数后，立刻finish，但更高效的方式是`skip命令`

1. 跳过单个函数：
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012243264.png" alt="202307012243264" width="450px">
2. 有时某个文件下所有的函数我都想跳过，一个个写很麻烦，可以采用`skip file test.cpp`命令
3. 跳一个文件夹下的所有cpp文件：`skip -gfi common/*.cpp`

## 制作、调试发行版

我们发给客户的程序，一般是不带调试信息的，一方面是节约空间，一方面也是保护公司源码，

我们想制作一个这种发行版：发给客户的程序既不带调试信息，又方便我们调试


1. 方法一：去掉-g参数，make一个版本，同时保留一个带有-g参数的版本  => 两个makefile，一个用于发行，一个用于debug
2. 方法二：不去掉-g参数，利用strip工具，可以把调试信息去掉，生成一个新的版本   => 推荐这种

制作好后，调试发布版本（如dump文件）。如果我们直接调试发布版本，`bt, i args`等命令都是不能用的，提示：`No symbol table info available`

1. 我们可以这样导入调试符号进行调试：`gdb --symbol=debug版本 -exec=发行版本`
2. 可以将debug版本的程序中的调试信息提取出来，
    - `objcopy --only-keep-debug debug版本程序 debug.sym`
    - `gdb --symbol-debug.sym -exec=release版本`

当程序产生core时，`gdb debug程序名 core.123`就可以查看这个dump了


## 修改可执行文件


如我们有以下一段检测授权码的代码：
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

正常情况下，它应该输出check failed, 但是我们可以修改可执行程序，100改成正确的值，如101

- `gdb --write 可执行文件`，写可执行文件（默认gdb文件都是读模式）

- `disassembler /mr check_some`反汇编

- `set {字节数}地址 = 修改的值`

- `q`退出后保存

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012316218.png" alt="202307012316218" width="450px">

如果可执行程序没有调试信息，可以利用`info functions`来查看源码，然后修改对应的值

## 内存泄漏检测

valgrind存在误报的情况， 如果程序运行系统分配的内存，且其输出结果太多，如果我们只想看某些个函数是否有内存泄漏，用valgrind反而显得太过冗余。

- call malloc_stats()：函数调用前查看了内存分配，调用后再次查看，对比两次的分配情况：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021025395.png" alt="202307021025395" width="450px">

tip：如果我们分配了1040个字节，但是却有1040个字节的泄漏，这是正常的，因为C++需要16个字节的链表节点来存储这些内存信息

- call mallokc info(0,stdout)

## 内存检查

valgrind太冗余，且影响程序运行性能，而gdb调试功能页有限，因此可以
使用gcc本身的特性检查内存问题，如内存泄漏，堆栈溢出等

makefile文件中增加选项：`gcc 选项 -fsanitize=address`，只有代码执行到了，编译的时候就会报告出来
- 检查内存泄漏
- 检查堆/栈溢出（这种问题都是随机程序崩溃，野指针也是）
- 检查全局内存溢出
- 检查释放后再使用

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

## 远程调试

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021052003.png" alt="202307021052003" width="450px">



## 调试子进程

进程创建一个子进程时，虽然运行在不同的内存空间（进程地址空间独立），除了pid，锁等资源，父子进程基本都是一样的（如内存数据，寄存器）

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
        switch(pid)          // 1. 直接在18行这里加断点，两个进程都不会停下来
        {
        case 0:
                data++;
                cout << "Child data is " << data << endl;
                cout << "My pid is " << getpid() << ",parent pid is " << getppid() << "#####\n" << endl;  // 23行断点
                break;
        case -1:
                cout << "error" << endl;
        default:
                data++;
                cout << "Parent data is " << data << endl;
                cout << "My pid is " << getpid() << ",child pid is " << pid << "*****\n" << endl;  // 30行断点

                break;
        }
        return 0;
}
```

调试子进程需要知道写时复制：

如父子进程输出的data++都是101，一开始创建子进程时，子进程的页表和父进程的页表是一样的，但是当父进程或子进程更改共享内存中的data数据时，子进程会新开辟一块内存
，将data写入到这块新内存，并更改自己的页表项，如：211=> 0x3434  更改为  233 => 0x6424

### 启用子进程调试

需先开启这个开关：`set follow-fork-mode parent/child`

设置为子进程调试后，在23行加断点，子进程将命中这个断点，而父进程则执行完毕，子进程变成孤儿进程，所以23行的打印结果，父进程变为1

怎么让子进程不变成孤儿进程呢？开启`set detach-on-fork off`


`follow-fork-mode和detach-on-fork`两种模式都可以通过show打印出来

### 父子进程同时调试

在调试的时候，父子进程都在运行，直接输入bt命令，只会打印当前进程的堆栈信息

inferior:

`i inferiors` 命令：查看进程

inferiors这个词翻译为下等的，但更好的翻译是内部的，因为这些进程都是gdb内部的一些进程

通常情况下，一个inferior代表一个进程，但也可能没有进程与inferior与之绑定

通过 `inferiors 1`，我们可以查看父进程的堆栈信息

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307011151094.png" alt="202307011151094" width="450px">

如果在第23行和30行都打断点，则两个断点都会命中


## 调试多进程

一个gdb sessison调试多个进程 

inferior可以认为一个可以装调试程序的房子,一个调试对象

-  i inferiors: 查看调试对象
- add-inferior：添加一个调试对象
- remove-inferior：删除一个调试对象，不能删除当前调试对象

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012143335.png" alt="202307012143335" width="450px">

- attach pid: 向空的调试对象附加进程

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307012145251.png" alt="202307012145251" width="450px">


- 设置两个进程都可执行：`set schedule-multiple on`，设置为off，则其他inferior处于中断状态

- 如果2号调试对象我们不想调试了，也可以detach：`detach inferiors 2`


## 多线程死锁调试

一个已经运行的进程，查看是否已经死锁

- `attach pid`进入中断状态
- `i threads`查看所有线程； `thread apply all bt`,查看所有线程的堆栈（信息太多，不建议用all）
- 查看多个线程的调用栈

切换栈帧：`f 5`，可知do_work1()函数具体停在哪一行：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021210985.png" alt="202307021210985" width="450px">

可以看出，这个线程在申请锁的时候一直没返回

- `p _mutes2`: 查看这个死锁被谁占用了

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021213631.png" alt="202307021213631" width="450px">

可以看出被线程3占用了。以这种方法继续调试，调试的结果是线程3去申请_mutex1, 但_mutex被线程1占用了，，，形成循环等待


解决死锁的方式：

- 顺序使用锁
- 控制锁的作用范围
- 可以使用超时机制


## core dump

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202307021218105.png" alt="202307021218105" width="450px">

所以正常的程序运行也可以产生core文件


导致core文件产生的原因常见的有：
- 内存分配时失败：堆内存是很大的，一般是栈内存分配失败。在写递归时，进经常发生栈溢出，那就是进程的独立栈空间的不够用了
  - ulimit -a 可以查看一个进程分配的栈空间
  - 栈溢出很难排查，会破坏周边的内存信息
- 无调试信息core dump分析



