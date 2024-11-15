# OT日初始化归档失败

## 问题现象

1. 归档表的列名被截断
2. 非交易表归档失败，已处理事务明显小于`hstodb#1`插件的提交事务，涉及表：thisstp_combiposition_buf（`Error on observer while running replication hook 'before_commit'`）

## 问题排查

### sql截断问题 

查看归档sql，有这么一段：

```oracle
SELECT
GROUP_CONCAT(a.column_name) AS column_name
FROM
    information_schema.COLUMNS a
WHERE
    lower(a.table_name) = 'tstp_instructionstock'
    AND a.TABLE_SCHEMA = Database()
    AND a.column_name in (
SELECT
    GROUP_CONCAT(b.column_name) AS column_name
FROM
    information_schema.COLUMNS b
WHERE
    lower(b.table_name) = 'thisstp_instructionstock'
    AND b.TABLE_SCHEMA = Database()
    AND a.column_name = b.column_name
)
```

所以，怀疑是GROUP_CONCAT函数导致，虽然OT没对接过mysql8，但是也很容易想到是数据库配置的问题，和现场确认了对接的数据，确实是mysql8，所以
配置group_concat_max_len,将拼接串长度变长就行（在部署环境时，公司也会发给客户各个组件和工具的参数配置）

### 归档问题

对于`Error on observer while running replication hook 'before_commit'`问题，是由于归档数据超事务限制了

客户那边是mysql8-mgr集群，设置了`group_replication_transaction_size_limit`参数为150M,dba将其值改大后，归档正常了。

但其实问题的不在于此，胡总抓到了重点：`thisstp_combiposition_buf`这张表:
首先，如果归档事务超限了，不应该直接去修改配置参数，特别是在集群里更改这个参数，可能会引用主从同步等事务问题，
而是应该将大事务拆分成小事务；

其次，为啥这张表会这么大的，这是因为`thisstp_combiposition_buf`表会定时记录每次持仓同步的记录，每天执行3次，
由于客户在国庆期间没有关闭后台环境，导致连续做多次这种定时任务，导致表数据达到了40W行,以达梦数据库为例，归档数据不超过10W行，
因此，最终的解决办法是杜绝这张表插入无用数据（如非交易日不做同步、定时清理表数据）