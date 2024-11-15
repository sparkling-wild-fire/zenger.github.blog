# 看懂复杂代码结构的makefile


## 常见的语句格式

```shell
# 赋值
STP_PUB_MOD=s_pub_ufttodb_filter s_apiadapter_ust s_apiadapter_ust_old s_apiadapter_ecldpust

# 命令，这里是依赖关系
s_ls_entryflow: s_ls_default_adapterflow s_ls_adapterflow s_ls_pubfuncflow
```

代码结构：

src/..

执行make 命令会去本目录找makefile文件，执行其中的命令

all 目标是一个特殊的目标，它通常用来定义默认的构建任务。当你在Makefile所在的目录下运行 make 命令而没有指定任何目标时，make 会寻找并执行 all 目标下定义的规则。

```shell
# make all
all: pub_set public stp algoserver strategy_mkt_mod t2_fix insar algopart pack
# 这行语句定义了 all 目标依赖于七个文件或目标
# make 会尝试找出如何构建这些依赖项。每个依赖项都可能有自己的构建规则，这些规则定义了如何生成每个目标。
# 例如，algoserver 可能是一个由多个源代码文件编译和链接生成的可执行文件或库文件
algoserver: public algoserver_pub algoserver_custom_pub algoserver_at_pub algoserver_at_mod
        $(call show_runtime)
# 其依赖链如下：    
# PUB_MOD很重要，
public: pub_mod plugin_mod
pub_mod: pub_set $(PUB_MOD)
        $(call show_runtime)   
pub_set:
        $(shell mkdir -p $(FBASE_HOME)/appcom)
        $(shell cp ./lib$(ARCH)/appcom/* $(FBASE_HOME)/appcom)
        $(shell cp ./lib/bin/components/libldptransfer.so $(FBASE_HOME)/appcom/libldptransfer.so)
        $(call show_runtime)
```

为什么没有生成模块so的语句