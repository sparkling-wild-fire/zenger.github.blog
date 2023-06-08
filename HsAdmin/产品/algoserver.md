# algoserer

1. 为啥又莫名其妙只能启动1号线程了？ 
   - 没找到so，在同一个账号里，注意环境变量的路径

2. 点击成交行情无法开启
   - 自研策略用Algotran的appcom，否则用AT的appcom，不然很容易core
   - 如果还是core，找别人的环境一个个排除是哪方面的问题，（首先只改动appcom和algoserver_as.xml）
   - 行情获取失败，策略无法启动 =》 找别人要个行情服务器，配置到hqserver.xml
   - 方案开始时间不能大于方案闭市时间  =》 修改交易时段表
     - `update algojr_texectimeinfo set day_exec_time_range='093000-113000;130000-190000' where market_no=1;`

3. algoserver灾备
   - 重启后，策略站点无方案站点序号才会递增
   - 为啥algoserver停了，询价策略还在运行中？然后请求停止发送后，也不停止。