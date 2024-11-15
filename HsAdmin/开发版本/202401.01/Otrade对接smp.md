# 对接SMP

适配启动，定义smp内部系统号1003

调404001: mp  =>  mt =>  so（加载so函数，绑定proc线程组）=> adapter(1003) => 调用smp接口  =>  mt系统号路由到microsvr  =>  zk读取smp_route.xml