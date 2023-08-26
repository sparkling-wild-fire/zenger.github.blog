# Linux C++通讯架构【四】：框架基础

## 框架搭建

### 文件目录

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202305302202710.png" alt="202305302202710" width="450px">

- include:存放各种头文件
- app目录：放主应用程序（main函数所在文件，以及一些核心的文件）
  - link.o目录：各种.c文件编译生成.o文件，然后链接这些.o文件成一个可执行文件，这个目录就存放这些临时的.o文件
  - dep目录：定义make时的依赖关系，即dep目录中的文件需要先编译
- misc目录：存放各种插件、不好归类的文件
- net目录：网络处理相关
- proc目录：和进程处理相关
- signal目录：和信号处理相关
- logs目录：日志文件

### Makefile

makefile：预处理(.i)，汇编(.s)，编译（.o）阶段会产生多个中间文件，多个.o文件链接成一个可执行文件，makefile定义编译和链接的规则。

实际上，makefile文件就是一个编译工程中，各种源文件、链接库so等等的一个依赖关系描述，其命令执行类似shell脚本。

在工作中，往往需进行分层编译，下层文件依赖上层文件；而makefile往往也分为外层和里层，外层makefiles是项目的入口编译脚本，起总体控制作用，到各个目录下再进行编译。[参考链接]()


- 总的流程：
1. config.mk设置编译目录和模式（debug和release等），也就是设置一些批量的g++编译命令,如：
```shell
 ifeq ($(DEBUG),true)
#-g是生成调试信息。GNU调试器可以利用该信息
CC = g++ -std=c++11 -g
VERSION = debug
else
CC = g++ -std=c++11
VERSION = release
endif
```

2. 根目录makefile 去循环make所有其他目录

3. 其他目录都引用common.mk，按照其编译规则去进行编译（都会生成.d依赖文件和.o可执行文件，但app目录还会生成最终的可执行文件nginx，生成在根目录）

```shell
# $(wildcard *.c)表示扫描当前目录下所有.c文件
SRCS = $(wildcard *.cxx)

#OBJS = nginx.o ngx_conf.o  这么一个一个增加.o太麻烦，下行换一种写法：把字符串中的.c替换为.o
OBJS = $(SRCS:.cxx=.o)

#把字符串中的.c替换为.d
DEPS = $(SRCS:.cxx=.d)

#可以指定BIN文件的位置,addprefix是增加前缀函数
BIN := $(addprefix $(BUILD_ROOT)/,$(BIN))

#如下这行会是开始执行的入口，三个变量的顺序就是编译文件的依赖关系
all:$(DEPS) $(OBJS) $(BIN)
```

4. make clean删除.d .o等中间文件和旧版本。


## 内存泄漏检查工具valgrind

todo

## 设置标题（进程名、服务名、可执行文件名）：

nginx中，子进程都一个名称，不好区分

启动nginx：`./nginx`,就会调用main(int argc,char **argv)

```
如./nginx -v -s 5
argc=4;
argv[0]=./nginx
argv[1]=-v
argv[2]=-s
```

对于argc、argv，其中argv[0] 就是标题名 ./nginx，只要把argv[0]改变了，标题（master进程名）就改变了 ==》strcpy(argv[0],"newTitile")

问题来了，newTitile比 ./nginx长，就会把后面参数内容覆盖了，而且argv参数后面还有环境变量参数信息。

解决方法：

1. 先把evriron(和可执行程序有关的环境变量参数信息)的数据搬走，让evrinor指向新的内存
2. 把argv[1]及其后面的参数用tmp保存起来
3. 把新的标题写入argv[0]这块内存，把tmp的内存追加到argv[0]后面，并把原有的evrinor所占内存的剩余内存清空

## 信号，子进程：

信号：信号值（常量），信号名（字面量）、信号处理函数（handler）

子进程：一般work线程和cpu核数相等（之前解释过了）

1. 创建worker子进程：

- fork产生子进程，分叉

  - 子进程分支 switch case pid=0（子进程返回0）；其他：父进程分支，直接break就行。

  - 子进程设置：是否屏幕信号（默认接收所有信号）、设置进程标题（不要与父进程重复）

  - 假设要杀死这一组进程，kill -9 父进程就可以了


2. signsuspend()：主进程阻塞，等待一个信号，此时进程休眠，不占用cpu时间。 这个操作只适合master（只要接收信号并管理），因为worker除了接收信号，还要处理任务

3. 原子操作：假设有10个信号，其中一个信号把其他信号屏蔽，防止终端处理

4. write函数思考：

- write写成功也只是从应用缓存区写到内核缓存区，因为从内核缓存区写到磁盘很慢（和socket的send()思想类似啊，send()也只是发送到发送缓冲区），等内核缓存区的数据满一页（如4K）,才写入磁盘

- 问题来了？如果缓存区写入磁盘的时候，断电了，就会导致数据丢失；所以一些重要的数据需采用缓存同步，将缓存和磁盘的数据保持一致（如直接写磁盘）

- 多进程同时写一个文件，如写日志文件，会混乱码  => Linux文件共享、文件IO


5. Nginx的master守护进程

- 创建时机：master 先 fork一个子进程，然后这个进程在fork新的子进程前创建守护进程。因为这个守护进程要做为子进程的父亲

- 创建后，释放原来的master进程，现在的master进程的ppid为1了