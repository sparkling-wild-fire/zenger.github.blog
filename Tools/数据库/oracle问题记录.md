# oracle问题记录

1. `ORA-01406: fetched column value was truncated,期权属性表:tstp_optionproperty,select * from tstp_optionproperty`

   <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230608134359.png" alt="20230608134359" width="450" >

这种是因为我切了O3的环境，`tstp_optionproperty`更新时存在索引冲突，我想先删除`tstp_optionproperty`的数据，但其实我没有删除`tstp_optionproperty`的数据，
然后又打了一遍升级脚本，然后重启就报这个错了。  => 但具体是哪列出错了，什么原因导致列值出错了，我也没法检查。

2. oralce客户端安装

如果用公司内部的工具，但是连接不上数据库，可能是客户端没启动

[安装链接](https://www.jianshu.com/p/ad87633af2a7)

如果出现这个问题，[参考链接](https://jingyan.baidu.com/article/ca41422f04c6891eae99ed36.html)

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230613183554.png" alt="20230613183554" width="450" >

安装路径：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230613183457.png" alt="20230613183457" width="450" >

