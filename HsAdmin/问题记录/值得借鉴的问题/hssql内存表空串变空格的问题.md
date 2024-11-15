# hssql内存表空串变空格的问题.md

问题场景：测试在委托撤补时，不重启没问题，但清流启动再去撤补后会报错：委托方向必传

结论：对于一个byte的数据库字段，经历fsc_todb插件落库+清流重启，都会从一个空串变成一个空格''=>' '

1. 看业务代码发现，在调O3接口时，需要拼接entrust_no和futures_direction这两个字段去映射表取O3的委托方向，查询条件为：
```txt
如果futures_direction是空
    那么查询条件为 where entrust_no=@entrust_no
如果futures_direction不是空
    那么查询条件为 where entrust_no=@entrust_no#futures_direction
```

而futures_direction本应该是空的，却变成了空格，导致委托方向查询失败

2. 为啥futures_direction传的是空格

futures_direction取自内存表tstp_entrusts_s的futures_direction字段

下委托时，向tstp_entrusts_s表插入一条委托记录，futures_direction的值为''，查询条件`where futures_direction =''`才可以查出这条数据

异步落库到oracle数据库（fsc_todb插件），futures_direction的值为null，查询条件`where futures_direction is null`才可以查出这条数据

清流重启后，futures_direction的值为空格' '，查询条件`where futures_direction = ' '`才可以查出这条数据

所以futures_direction在经历落库、重启，它的值的变化为'' =>  null  =>  ' '

3. 为啥重启时，futures_direction会从null  =>  ' '

在oracle数据库中，futures_direction为char(1)类型，默认值为' '

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241031185246.png" alt="20241031185246" width="850">

研发中心的函数`LoadFromDb()`调用了Oracle的OCI接口OCIStmtExecute
,当字段为null时，这个接口会字节补充空格，比如char(10)类型就会补充10个空格返回

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241031185210.png" alt="20241031185210" width="850">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20241031185556.png" alt="20241031185556" width="850">

研发中心对多个空格的字段做了处理，会去掉这些空格，
但是单个空格的没有，因为考虑到单个空格可能是代表了一些特殊的函数，就类似一个占位符，表示我这个字段是有东西

这样，futures_direction就赋值成空格加载到内存表中了

Tip:

深层原因由于环境没有深层排查，但是有两点还是需要注意下：
1. todb_modec参数配置为1，当字段值为空串时，落库插件落到oracle数据为啥要变成null，不是空串，也不是默认值
2. 这个是一个普遍问题，对于一个byte的字段经历fsc_todb插件落库+清流重启，都会从一个空串变成一个空格，空串和空格的处理需要业务部门和框架做一个约定（研发中心的同事说的）