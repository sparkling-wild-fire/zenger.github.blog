# sql

sql的写法：

```sql
select 
    t.l_fund_id
    , t.c_agent_type   -- 都好放前面，不要返回这个字段，直接删除就好
    , t.vc_default_saleorg
    , t.vc_check_saleorg
from  
    toutchannelconfig t, tfundinfo tf, toutchannelinfo toc
where t.l_fund_id=tf.l_fund_id  
    and t.vc_default_saleorg = toc.vc_channel_code(+)
    and t.c_agent_type in('1','2','3')
    and  (select count(*)  from TOPFUNDRIGHT where TOPFUNDRIGHT.l_fund_id=t.l_fund_id
        and TOPFUNDRIGHT.c_layer='1' and TOPFUNDRIGHT.l_operator_no=99991000
        and instr(TOPFUNDRIGHT.vc_rights, '1')>0 ) > 0
order by l_fund_id asc   -- 能不写就不要写
```
改造：
```sql
select
    t.l_fund_id
    , t.c_agent_type
    , t.vc_default_saleorg
    , t.vc_check_saleorg
from
    toutchannelconfig t     -- 它现在是主表
        left join tfundinfo tf on t.l_fund_id=tf.l_fund_id   -- 这个连接的筛选能力大，放前面，小表连接大表
        left join toutchannelinfo toc on t.vc_default_saleorg = toc.vc_channel_code
where  
    t.c_agent_type in('1','2','3')          -- 数据表结构的变动不影响查询条件
    and  (select count(*)     -- https://blog.csdn.net/weixin_46200547/article/details/120020025
            from
                TOPFUNDRIGHT
            where
                TOPFUNDRIGHT.l_fund_id=t.l_fund_id
                and TOPFUNDRIGHT.c_layer='1' and TOPFUNDRIGHT.l_operator_no=99991000
                and instr(TOPFUNDRIGHT.vc_rights, '1') > 0
    ) > 0
```

oracle 中的（+）：

是一种特殊的用法，（+）表示外连接，并且总是放在非主表的一方。

例如

左外连接：select A.a,B.a from A LEFT JOIN B ON A.b=B.b;

等价于 select A.a,B.a from A,B where A.b = B.b(+);

再举个例子，这次是右外连接：select A.a,B.a from A RIGHT JOIN B ON A.b=B.b;

等价于 select A.a,B.a from A,B where A.b (+) = B.b;

