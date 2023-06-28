# valgrind

## 安装与使用

1. 安装：`yum install valgrin`
2. 运行：`valgrind --tool=toolname args-val program args-pro`
   - 工程中，可能需用到命令：`valgrind --log-file=valgrind.log --tool=memcheck --leak-check=full \ 
                          --show-leak-kinds=all ./your_app arg1 arg2`

其中:
`--log-file` 报告文件名。如果没有指定，输出到stderr。 
`--tool=memcheck` 指定Valgrind使用的工具。Valgrind是一个工具集，包括Memcheck、Cachegrind、Callgrind等多个工具。
memcheck是缺省项。 
`--leak-check` 指定如何报告内存泄漏（memcheck能检查多种内存使用错误，内存泄漏是其中常见的一种），可选值有:
  - no 不报告
  - summary 显示简要信息，有多少个内存泄漏。summary是缺省值。
  - yes 和 full 显示每个泄漏的内存在哪里分配。
  - show-leak-kinds 指定显示内存泄漏的类型的组合。类型包括definite, indirect, possible,reachable。也可以指定all或none。
  缺省值是definite,possible。 运行一段时间后想停止进程不要kill掉，需要ctrl + c来结束，输出的log会在上述命令中的
  valgrind.log中。


该工具可以检测下列与内存相关的问题:
  - 未释放内存的使用
    - 对释放后内存的读/写
        - 对已分配内存块尾部的读/写
  - 内存泄露
  - 不匹配的使用malloc/new/new[] 和 free/delete/delete[]
  - 重复释放内存


## 简单使用

[参考链接](https://zhuanlan.zhihu.com/p/92074597)

来段简单的代码：
```C++
#include <stdlib.h>

void f(void){
    int* x =(int*)malloc(10 * sizeof(int));
    x[10] = 0;         // problem 1: heap block overrun
}                    // problem 2: memory leak -- x not freed

int main(void){
    f();
    return 0;
}
```

编译：`gcc -g -o a.out a.cpp`
检测：`valgrind --leak-check=yes ./a.out`

valgrind输出为：
```txt
==253== Memcheck, a memory error detector
==253== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==253== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==253== Command: ./a.out
==253==
==253== Invalid write of size 4       
==253==    at 0x40054E: f() (a.cpp:6)
==253==    by 0x40055E: main (a.cpp:11)
==253==  Address 0x5205068 is 0 bytes after a block of size 40 alloc'd  # 2.内存越界，x[10]写数据失败
==253==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==253==    by 0x400541: f() (a.cpp:5)
==253==    by 0x40055E: main (a.cpp:11)
==253==
==253==
==253== HEAP SUMMARY:
==253==     in use at exit: 40 bytes in 1 blocks
==253==   total heap usage: 1 allocs, 0 frees, 40 bytes allocated
==253==
==253== 40 bytes in 1 blocks are definitely lost in loss record 1 of 1
==253==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==253==    by 0x400541: f() (a.cpp:5)       # 1.这里是函数调用栈，需要从下到上追踪
==253==    by 0x40055E: main (a.cpp:11)   
==253==
==253== LEAK SUMMARY:
==253==    definitely lost: 40 bytes in 1 blocks
==253==    indirectly lost: 0 bytes in 0 blocks
==253==      possibly lost: 0 bytes in 0 blocks
==253==    still reachable: 0 bytes in 0 blocks
==253==         suppressed: 0 bytes in 0 blocks
==253==
==253== For lists of detected and suppressed errors, rerun with: -s
==253== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)
```

其中，==253==中的数字为进程号，一般不用看。

## 原理

valgrind 这个工具不能用于调试正在运行的程序，因为待分析的程序必须在它的合成CPU上才能运行。

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306191950919.png" alt="202306191950919" width="450px">

[MemCheck基本原理](https://zhuanlan.zhihu.com/p/510362477)：重点知道使用valgrind内存使用率会多占用25%左右

## 案例






