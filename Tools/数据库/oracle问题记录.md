# oracle问题记录

1. `ORA-01406: fetched column value was truncated,期权属性表:tstp_optionproperty,select * from tstp_optionproperty`

   <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230608134359.png" alt="20230608134359" width="450" >

这种是因为我切了O3的环境，`tstp_optionproperty`更新时存在索引冲突，我想先删除`tstp_optionproperty`的数据，但其实我没有删除`tstp_optionproperty`的数据，
然后又打了一遍升级脚本，然后重启就报这个错了。  => 但具体是哪列出错了，什么原因导致列值出错了，我也没法检查。