# algoserer

1. 为啥又莫名其妙只能启动1号线程了？
   - 没找到so，在同一个账号里，注意环境变量的路径

2. 点击成交行情无法开启
   - 自研策略用Algotran的appcom，否则用AT的appcom，不然很容易core
   - 如果还是core，找别人的环境一个个排除是哪方面的问题，（首先只改动appcom和algoserver_as.xml）
   - 行情获取失败，策略无法启动 =》 找别人要个行情服务器，配置到hqserver.xml
   - 方案开始时间不能大于方案闭市时间 =》 修改交易时段表
     - `update algojr_texectimeinfo set day_exec_time_range='093000-113000;130000-210000' where market_no=1;`

3. algoserver灾备
   - 重启后，策略站点无方案站点序号才会递增
   - 为啥algoserver停了，询价策略还在运行中？然后请求停止发送后，也不停止。


Algoserver启动进程文件，如`mainsvr.36.out`,提示未定义的标识符：

` LOAD FUNCTION LIB [algo_account_strategy]
FAILURE!!![/home/zengzg/algoserver/appcom/libalgo_account_strategy.so:
undefined symbol: _ZN4core11COptionInfo13GetOptionTypeEv`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230620142646.png" alt="20230620142646" width="1650" >

这种一般是动态链接的时候，找不到对应的标识符（这里是一个QQTest的函数）

最好先`ldd -r libalgo_account_strategy.so` => 查看so依赖的库和未定义的symbol

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230620143106.png" alt="20230620143106" width="850" >

然后修改makefile文件，将引用的头文件，以及依赖的so加进去:

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230620142956.png" alt="20230620142956" width="450" >


动态库的一个好处就是，如果依赖的库`libstrategy_public2.so`需要更改(如对一个参数做一下类型转换)，`libalgo_account_strategy.so`是不需要更改,进程分别加载一些so


如果是本地的的一个函数提示以上问题，编译正确，可能是在链接的时候没链接到头文件:[参考链接](https://www.cnblogs.com/SchrodingerDoggy/p/15464919.html)
=> 待解决

