# Makefile流程

[make参考链接](https://blog.csdn.net/weixin_44966641/article/details/120572185)

在Arestudio中生成代码时，会进行编译生成.o和.gcc文件（.gcc文件干嘛的），生成编译脚本makeall、makeclean，
分别写入了一系列的`make -f *.gcc`和`make -f *.gcc clean`命令

对应的makefile文件为：`src/Makefile`、`src/algotran/makefile`

make -f 解释：
- make命令：会在本目录找Makefile或makefile文件，makefile文件中，可通过-I参数引用其他目录的makefile文件
- -f参数：告诉make命令将哪一个文件作为makefile文件，如*.gcc

gcc   =>    src/algotran/makefile    =>     src/Makefile



## 模块依赖

按层级编译，同层级的so同时编译，同级之间进行引用，就很容易出现依赖问题，如sessionflow依赖triggerflow

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/85e52f3e042a01edf62fddb00bd5aa53.png" alt="85e52f3e042a01edf62fddb00bd5aa53" width="450" >

当sessionflow早于triggerflow编译，或者triggerflow编译较慢，就会出现依赖问题。

### 层级划分

示例：

```shell
# 模块划分与依赖关系：
# PUB_MOD-公共模块
#   PLUGIN_MOD-插件
#	 STP_PUB_MOD-策略平台公共，
#		 STP_PROC_BASE_MOD-策略平台基础，STP_PROC_PUB_MOD-策略平台服务公共，STP_PROC_MOD-策略平台服务，
#		 STP_UFT_PUB_MOD-uft基础公共，STP_UFT_AS_MOD-uft原子服务，STP_UFT_LS_MOD-uft逻辑服务
#	 ALGOSERVER_PUB_MOD-策略服务公共
#	 T2TOFIX_MOD-T2tofix模块
#	 STRATEGY_MKT_MOD-mkt节点模块


```

每一层级都是一些so的集合，并且设置了依赖关系：

```shell
#策略平台公共依赖关系
STP_PROC_BASE_MOD=s_ls_default_adapterflow s_ls_adapterflow  s_ls_pubfuncflow s_ls_entryflow
#依赖关系
s_ls_adapterflow: s_ls_default_adapterflow
s_ls_pubfuncflow: s_ls_default_adapterflow s_ls_adapterflow
s_ls_entryflow: s_ls_default_adapterflow s_ls_adapterflow s_ls_pubfuncflow

# ...

# 策略平台proc服务模块
# 同级：s_ls_sessionflow不能引用s_ls_triggerflow，但可以引用STP_PROC_BASE_MOD的s_ls_pubfuncflow
STP_PROC_MOD=s_ls_acc_msgflow  \
		s_ls_instructionflow s_ls_base_msgflow s_ls_stp_basedataflow  s_ls_stp_tradeflow s_ls_trade_msgflow \
		s_ls_triggerflow s_as_pbadapterflow s_as_stp_dbflow s_as_stp_publishflow  s_ls_O3adapterflow  s_ls_algo_adapterflow s_ls_sessionflow \
		s_as_ascoreflow s_as_aspushflow s_ls_lsentrustflow s_ls_lsfrontflow s_ls_lsheartbeatflow s_ls_lsfront_ldpflow \
		s_ls_lsmsgflow s_ls_algobusflow s_ls_lsserviceflow s_ls_lssvrmsgflow s_ls_lswithdrawflow s_ls_lshishqserviceflow s_ls_stp_managerflow s_ls_at_analysisflow s_ls_balance_qryflow \
		s_ls_lhtoolsflow s_as_lhtoolsflow s_ls_stp_hisqueryflow s_ls_quant_ldpflow s_ls_algo_schemehandleflow s_ls_quant_schemehandleflow s_ls_frequent_qryflow \
		s_ls_algofactorflow
		
# 策略平台proc服务模块依赖关系
s_ls_algobusflow: s_ls_triggerflow
s_ls_lsserviceflow: s_ls_algobusflow
s_ls_at_analysisflow: s_ls_lshishqserviceflow
```

使用" make -f 模块名.gcc 模块名 " 的方式可以避免执行到all里面的clean

makeall就是进入到目录，然后make -f *.gcc


make 的 -f 参数：
- make命令本身是无法了解应该如何建立应用程序的，所以我们必须为其提供一个文件，告诉它应用程序应该如何构造，这个文件就是Makefile文件
- -f 告诉make命令将哪一个文件作为makefile文件。若没有使用这个参树，则make命令将在当前目录下查找名makefile的文件，如果makefile文件不存在，则查找Makefile文件

## algotran下的Makefile
src下的makefile和algotran下的makefile有啥区别和联系
- algotran下的Makefile的all命令，没有s_ls_sessionflow.so和s_ls_triggerflow.so =》 当sh makeall时，就是执行make -f gcc? 与Makefile无关吗
- 这个Makefile比较常规

定义的依赖：
```shell
libs_ls_lsentryflow.so: s_ls_lsentryflow.o s_ls_lsentryfunc.o 
	$(CXX) $(LDFLAGS) $(LIBS) -ls_libpublic -ls_helper -ls_glbfunction_or -lfsc_adaptermanager $^ -o $@
	install -v $@ $(TAGGET_PATH)/$@
# ...
```