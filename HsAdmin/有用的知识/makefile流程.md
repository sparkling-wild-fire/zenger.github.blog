# Makefile����

[make�ο�����](https://blog.csdn.net/weixin_44966641/article/details/120572185)

��Arestudio�����ɴ���ʱ������б�������.o��.gcc�ļ���.gcc�ļ�����ģ������ɱ���ű�makeall��makeclean��
�ֱ�д����һϵ�е�`make -f *.gcc`��`make -f *.gcc clean`����

��Ӧ��makefile�ļ�Ϊ��`src/Makefile`��`src/algotran/makefile`

make -f ���ͣ�
- make������ڱ�Ŀ¼��Makefile��makefile�ļ���makefile�ļ��У���ͨ��-I������������Ŀ¼��makefile�ļ�
- -f����������make�����һ���ļ���Ϊmakefile�ļ�����*.gcc

gcc   =>    src/algotran/makefile    =>     src/Makefile



## ģ������

���㼶���룬ͬ�㼶��soͬʱ���룬ͬ��֮��������ã��ͺ����׳����������⣬��sessionflow����triggerflow

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/85e52f3e042a01edf62fddb00bd5aa53.png" alt="85e52f3e042a01edf62fddb00bd5aa53" width="450" >

��sessionflow����triggerflow���룬����triggerflow����������ͻ�����������⡣

### �㼶����

ʾ����

```shell
# ģ�黮����������ϵ��
# PUB_MOD-����ģ��
#   PLUGIN_MOD-���
#	 STP_PUB_MOD-����ƽ̨������
#		 STP_PROC_BASE_MOD-����ƽ̨������STP_PROC_PUB_MOD-����ƽ̨���񹫹���STP_PROC_MOD-����ƽ̨����
#		 STP_UFT_PUB_MOD-uft����������STP_UFT_AS_MOD-uftԭ�ӷ���STP_UFT_LS_MOD-uft�߼�����
#	 ALGOSERVER_PUB_MOD-���Է��񹫹�
#	 T2TOFIX_MOD-T2tofixģ��
#	 STRATEGY_MKT_MOD-mkt�ڵ�ģ��


```

ÿһ�㼶����һЩso�ļ��ϣ�����������������ϵ��

```shell
#����ƽ̨����������ϵ
STP_PROC_BASE_MOD=s_ls_default_adapterflow s_ls_adapterflow  s_ls_pubfuncflow s_ls_entryflow
#������ϵ
s_ls_adapterflow: s_ls_default_adapterflow
s_ls_pubfuncflow: s_ls_default_adapterflow s_ls_adapterflow
s_ls_entryflow: s_ls_default_adapterflow s_ls_adapterflow s_ls_pubfuncflow

# ...

# ����ƽ̨proc����ģ��
# ͬ����s_ls_sessionflow��������s_ls_triggerflow������������STP_PROC_BASE_MOD��s_ls_pubfuncflow
STP_PROC_MOD=s_ls_acc_msgflow  \
		s_ls_instructionflow s_ls_base_msgflow s_ls_stp_basedataflow  s_ls_stp_tradeflow s_ls_trade_msgflow \
		s_ls_triggerflow s_as_pbadapterflow s_as_stp_dbflow s_as_stp_publishflow  s_ls_O3adapterflow  s_ls_algo_adapterflow s_ls_sessionflow \
		s_as_ascoreflow s_as_aspushflow s_ls_lsentrustflow s_ls_lsfrontflow s_ls_lsheartbeatflow s_ls_lsfront_ldpflow \
		s_ls_lsmsgflow s_ls_algobusflow s_ls_lsserviceflow s_ls_lssvrmsgflow s_ls_lswithdrawflow s_ls_lshishqserviceflow s_ls_stp_managerflow s_ls_at_analysisflow s_ls_balance_qryflow \
		s_ls_lhtoolsflow s_as_lhtoolsflow s_ls_stp_hisqueryflow s_ls_quant_ldpflow s_ls_algo_schemehandleflow s_ls_quant_schemehandleflow s_ls_frequent_qryflow \
		s_ls_algofactorflow
		
# ����ƽ̨proc����ģ��������ϵ
s_ls_algobusflow: s_ls_triggerflow
s_ls_lsserviceflow: s_ls_algobusflow
s_ls_at_analysisflow: s_ls_lshishqserviceflow
```

ʹ��" make -f ģ����.gcc ģ���� " �ķ�ʽ���Ա���ִ�е�all�����clean

makeall���ǽ��뵽Ŀ¼��Ȼ��make -f *.gcc


make �� -f ������
- make��������޷��˽�Ӧ����ν���Ӧ�ó���ģ��������Ǳ���Ϊ���ṩһ���ļ���������Ӧ�ó���Ӧ����ι��죬����ļ�����Makefile�ļ�
- -f ����make�����һ���ļ���Ϊmakefile�ļ�����û��ʹ�������������make����ڵ�ǰĿ¼�²�����makefile���ļ������makefile�ļ������ڣ������Makefile�ļ�

## algotran�µ�Makefile
src�µ�makefile��algotran�µ�makefile��ɶ�������ϵ
- algotran�µ�Makefile��all���û��s_ls_sessionflow.so��s_ls_triggerflow.so =�� ��sh makeallʱ������ִ��make -f gcc? ��Makefile�޹���
- ���Makefile�Ƚϳ���

�����������
```shell
libs_ls_lsentryflow.so: s_ls_lsentryflow.o s_ls_lsentryfunc.o 
	$(CXX) $(LDFLAGS) $(LIBS) -ls_libpublic -ls_helper -ls_glbfunction_or -lfsc_adaptermanager $^ -o $@
	install -v $@ $(TAGGET_PATH)/$@
# ...
```