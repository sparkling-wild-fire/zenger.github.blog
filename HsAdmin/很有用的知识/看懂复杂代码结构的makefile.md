# �������Ӵ���ṹ��makefile


## ����������ʽ

```shell
# ��ֵ
STP_PUB_MOD=s_pub_ufttodb_filter s_apiadapter_ust s_apiadapter_ust_old s_apiadapter_ecldpust

# ���������������ϵ
s_ls_entryflow: s_ls_default_adapterflow s_ls_adapterflow s_ls_pubfuncflow
```

����ṹ��

src/..

ִ��make �����ȥ��Ŀ¼��makefile�ļ���ִ�����е�����

all Ŀ����һ�������Ŀ�꣬��ͨ����������Ĭ�ϵĹ������񡣵�����Makefile���ڵ�Ŀ¼������ make �����û��ָ���κ�Ŀ��ʱ��make ��Ѱ�Ҳ�ִ�� all Ŀ���¶���Ĺ���

```shell
# make all
all: pub_set public stp algoserver strategy_mkt_mod t2_fix insar algopart pack
# ������䶨���� all Ŀ���������߸��ļ���Ŀ��
# make �᳢���ҳ���ι�����Щ�����ÿ��������������Լ��Ĺ���������Щ���������������ÿ��Ŀ�ꡣ
# ���磬algoserver ������һ���ɶ��Դ�����ļ�������������ɵĿ�ִ���ļ�����ļ�
algoserver: public algoserver_pub algoserver_custom_pub algoserver_at_pub algoserver_at_mod
        $(call show_runtime)
# �����������£�    
# PUB_MOD����Ҫ��
public: pub_mod plugin_mod
pub_mod: pub_set $(PUB_MOD)
        $(call show_runtime)   
pub_set:
        $(shell mkdir -p $(FBASE_HOME)/appcom)
        $(shell cp ./lib$(ARCH)/appcom/* $(FBASE_HOME)/appcom)
        $(shell cp ./lib/bin/components/libldptransfer.so $(FBASE_HOME)/appcom/libldptransfer.so)
        $(call show_runtime)
```

Ϊʲôû������ģ��so�����