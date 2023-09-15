# sql执行脚本导出


## 问题

- 下面多了一行编码声明

algo_lhtools_opinstance_qry.xml 

- 这个文件是utf-8,还有少数几个也是，要改的话直接搜索一下就行

batch_bond_pricing.xml 

- 连续两个 </statement>

inqydealstat_archive.xml    mktduty_archive.xml    option_detail_mktduty_archive.xml     option_mktduty_archive.xml

- condition标签不匹配

web_instancedetail_qry.xml 

- datasrouce没加s

strategy_param_qry.xml   

- 文件编码和声明的编码不一致

tentrust_direction_qry.xml

- 归档的sql可能会有些问题


## 兼容

oracle的数据库字段 和 postgre不兼容，如varchar2在postgre提示自定义类型
