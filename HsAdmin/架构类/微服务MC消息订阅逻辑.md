# ΢����MC��Ϣ�����߼�

�����������Ȼ�����������������������ĳ�ʼ��������,load_levelֵԽ�͵ģ�Խ������

## �������

hsserver����mt���У����ز��

### ������������

�ȼ���fsc_adaptermanager

```c++
<plugin lib="fsc_adaptermanager" getinfo="GetAdapterManagerInfo" load_level="1" note="������������">
    <def_mqsub prefetch="1000" auto_ack="false" queue_size="50000"/>
    <args front_adapter="true" subsys_no="3" channel_id="1" thread_num="64" mc_subscribe_mode ="single" dispatch_thread_num="8"/>
</plugin>
```

΢��������load_levelΪ2��������־��

```txt
// ׼������
Plugin[microsvr] loaded(Ver=20170913,Feb  7 2023 23:15:13).
Plugin[microsvr] path(/home/algotran/lib/libfsc_microsvr.so).
....[microsvr#1] 
// ��������
TRACE:SetDepend Plugin[com.hundsun.fbase.f2core] For [microsvr]
TRACE:SetDepend Plugin[com.hundsun.fbase.esbmessagefactory] For [microsvr]
TRACE:SetDepend Plugin[com.hundsun.fbase.f2packsvr] For [microsvr]
TRACE:SetDepend Plugin[com.hundsun.fbase.log] For [microsvr]
TRACE:SetDepend Plugin[com.hundsun.fbase.config] For [microsvr]
....[microsvr#1] (������־��ӡ����microsvr)
...
// �����ʼ��
{alg_tran_mt_zenger-alg_tran_mt_zenger-0--1}::CF2CoreImpl::mf_InitPlugin()
TRACE:[273010]Plugin[microsvr] init ...
TRACE:Plugin[microsvr] init end.
....[microsvr#1]
// ������ˮ�ߣ���Ȼ���΢����������������
CF2CoreImpl::mf_SetOnePipe()
��Ϣ��ˮ��[microsvr;filter_log;router]
TRACE:SetPipe[microsvr <-> filter_log].
....[microsvr#1]
// �������ã�
Description = ��ʼ����׼��
CF2CoreImpl::ProcSysEvent()               => �������Ҳ���ߵ���,Ӧ�������в���������ɹ��ˣ������̷����ź��������������
TRACE:Plugin[microsvr] begin
TRACE:Plugin[microsvr] end
....[microsvr#1]
```

## ��ʼ��



