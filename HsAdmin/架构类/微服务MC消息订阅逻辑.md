# 微服务MC消息订阅逻辑

先启动插件，然后进行适配管理器和适配器的初始化和启动,load_level值越低的，越先启动

## 插件启动

hsserver启动mt进行，加载插件

### 适配管理器插件

先加载fsc_adaptermanager

```c++
<plugin lib="fsc_adaptermanager" getinfo="GetAdapterManagerInfo" load_level="1" note="适配管理器插件">
    <def_mqsub prefetch="1000" auto_ack="false" queue_size="50000"/>
    <args front_adapter="true" subsys_no="3" channel_id="1" thread_num="64" mc_subscribe_mode ="single" dispatch_thread_num="8"/>
</plugin>
```

微服务启动load_level为2，启动日志：

```txt
// 准备加载
Plugin[microsvr] loaded(Ver=20170913,Feb  7 2023 23:15:13).
Plugin[microsvr] path(/home/algotran/lib/libfsc_microsvr.so).
....[microsvr#1] 
// 依赖设置
TRACE:SetDepend Plugin[com.hundsun.fbase.f2core] For [microsvr]
TRACE:SetDepend Plugin[com.hundsun.fbase.esbmessagefactory] For [microsvr]
TRACE:SetDepend Plugin[com.hundsun.fbase.f2packsvr] For [microsvr]
TRACE:SetDepend Plugin[com.hundsun.fbase.log] For [microsvr]
TRACE:SetDepend Plugin[com.hundsun.fbase.config] For [microsvr]
....[microsvr#1] (但是日志打印的是microsvr)
...
// 插件初始化
{alg_tran_mt_zenger-alg_tran_mt_zenger-0--1}::CF2CoreImpl::mf_InitPlugin()
TRACE:[273010]Plugin[microsvr] init ...
TRACE:Plugin[microsvr] init end.
....[microsvr#1]
// 加入流水线（不然这个微服务插件不会启动）
CF2CoreImpl::mf_SetOnePipe()
消息流水线[microsvr;filter_log;router]
TRACE:SetPipe[microsvr <-> filter_log].
....[microsvr#1]
// 代理设置？
Description = 开始运行准备
CF2CoreImpl::ProcSysEvent()               => 适配管理也会走到这,应该是所有插件都启动成功了，主进程发送信号启动适配管理器
TRACE:Plugin[microsvr] begin
TRACE:Plugin[microsvr] end
....[microsvr#1]
```

## 初始化



