# Linux C++通讯架构【二】：进程和信号

## 终端（pts）与进程的关系
1. pts就是一个bash（命令解释器），一个shell，一个可执行程序，在/bin/bash目录下，终端如果关闭，终端上的进程也就关闭了；

- 比如执行一个可执行程序，不断往A终端printf数据，然后新开一个终端B，通过`ps -la`命令可以看到这个printf的进程，但是当A终端关闭后，ps查看进程发现这个printf的进程不在了

因为这个printf进程属于一个进程组，同一个进程组的进程组id相同，都是`bash进程的子进程` （ps命令查看父进程可知），所以xshell其实并不是远程控制，而是一个实际的远程终端

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202305232131940.png" alt="202305232131940" width="450px">

2. 会话(session)：一个或多个进程组的集合。一个bash上有多个进程组，一般bash的所有进程都属于一个session，但也可能一个bash上有多个session

记录个命令：`ps -eo pid,ppid,sid,tty,pgrp,comm | grep -E 'bash|PID|nginx'`
其中，-o参数表示自定义展示哪些列，sid表示sessionid，tty表示终端（0，1，2是啥意思），pgrp表示进程组，-E表示正则匹配

3. bash: shell的一种，linux默认采用bash这种shell，也就是说bash是一个可执行程序，主要作用是把用户输入的命令翻译给操作系统（命令解释器）。在/bin/bash目录，输入exit就可以logout这个终端

## 终端与信号

当终端要退出时，系统会发送SIGHUP信号（终端断开信号）,给session_leader（一般就是bash进程，也可以调系统函数自己设置），bash进程收到SIGHUP信号后，
会把这个信号发送给所有sessionid相同的进程（如nginx子进程），然后再给自己发送SIGHUP信号。

strace信号跟踪工具：可以跟踪程序执行时进程的系统调用，以及所收到的信号，如在其他终端执行命令：
`sudo strace -e trace=signal -p 1359`附着1359这个bash进程，然后关掉这个bash终端，查看输出

- 怎么让bash退出，Nginx不退出
- Nginx拦截操作系统的sighup信号：nginx启动时，加一行代码`signal(SIGHUP,SIG_IGN);`,SIG_IGN表示忽略某一种信号
  - 这种情况由于bash父进程死了，将变成孤儿进程由Init进程接管，也就是ppid变成1了
- 设置Nginx的sessionid，新建一个session，和bash不在同一个会话里：nginx启动时，加一行代码`setsid();`
  - 进程组组长不能setid()，这在创建守护进程会提到。解决方法，fork一个子进程
  - setsid命令，可改变一个已启动进程的sessionid

```C++
#include<signal.h>

int main(int argc, char* const *argv){
    pid_t pid;
    printf("内容输出");
    pid=fork();   // 系统函数，子进程会从fork()调用之后开始执行
    if(pid<0){
        printf("子进程设置出错")
    }else if(pid==0){   // 子进程
        setsid();  // 子进程新建一个不同的session4
    }else{   // 父进程
        // signal(SIGHUP,SIG_IGN);
    }
    // ....逻辑代码
}
```
后台运行：
- nginx执行自己的程序，终端可以继续处理其他的；
- fg切换到前台，终端输入的指令Nginx都不会例会了
- 后台运行可以往终端打印东西

## 信号
信号都是突发事件，异步发生，也称为软件中断，进程收到信号，操作系统都会知道

记录一条命令：`find / -name "signal.h" | xargs grep -in "SIGHUP"`，其中，xargs表示找到文件后，将文件内容传输给grep进行查找
信号产生：
- 某个进程发送给另一个进程或自己（Nginx热升级）
- 内核发送给某个进程 ：
  - ctrl+c（中断信号），kill命令
  - 内存访问异常，硬件通知内核，内核通知进程
信号都以SIG开头，如SIGHUP，信号都是一些正整数常量（signal.h中的宏定义，从1开始）
  

### kill

我们在关闭bash时，bash会用kill命令发送一个SIGTERM信号，关闭nginx进程

用来发送信号，信号9定义为SIGKILL，kill -9 pid表示给进程发送一个SIGKILL的信号

然后，kill -1 pid表示挂起这个进程（信号1定义为SIGHUP），然而，神奇的是，这个进程直接被杀掉了 =》
这是由于操作系统给进程发送信号后，如果进程没有对这个信号做出处理，操作系统默认会杀死这个进程（之所以将信号发送命令命名为kill，就是因为绝大部分操作系统发送的信号的缺省操作就是杀死）

同理，kill pid也可以杀死进程

kill的常用参数：
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202305232256846.png" alt="202305232256846" width="450px">

## 内核态和用户态

malloc()和printf()，会先切换到内核态，再切换回用户态。其实printf内部就会调用malloc()

什么时候会从用户态切到内核态：
- 系统调用：malloc()
- 异常事件：比如来了个信号
- 外围设备中断

### 信号集：
Linux支持60多种信号，信号集是一种数据结构，0011000...，可简单理解为64多个bit（其实是一个sigset_t结构）
```C++
typedef struct{
    unsigned long sig[2];   // 一个long4bit，两个正好8bit
    // 相关api自行百度
}sigset_t;
```
来一个信号对应位置置为1，如果本来就为1，说明同类型信号正在被处理，不能被打断，得排队。
如果一个信号处理函数正在处理其他信号，后续相同的信号统统归结为1次，并被阻塞到上个信号处理完。
信号屏蔽：一个进程有一个信号集，我们可以把要屏蔽的信号位设为1，就能实现信号阻塞了（sigprocmask()函数）。
