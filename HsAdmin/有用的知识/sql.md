# sql

sql��д����

```sql
select 
    t.l_fund_id
    , t.c_agent_type   -- ���÷�ǰ�棬��Ҫ��������ֶΣ�ֱ��ɾ���ͺ�
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
order by l_fund_id asc   -- �ܲ�д�Ͳ�Ҫд
```
���죺
```sql
select
    t.l_fund_id
    , t.c_agent_type
    , t.vc_default_saleorg
    , t.vc_check_saleorg
from
    toutchannelconfig t     -- ������������
        left join tfundinfo tf on t.l_fund_id=tf.l_fund_id   -- ������ӵ�ɸѡ�����󣬷�ǰ�棬С�����Ӵ��
        left join toutchannelinfo toc on t.vc_default_saleorg = toc.vc_channel_code
where  
    t.c_agent_type in('1','2','3')          -- ���ݱ�ṹ�ı䶯��Ӱ���ѯ����
    and  (select count(*)     -- https://blog.csdn.net/weixin_46200547/article/details/120020025
            from
                TOPFUNDRIGHT
            where
                TOPFUNDRIGHT.l_fund_id=t.l_fund_id
                and TOPFUNDRIGHT.c_layer='1' and TOPFUNDRIGHT.l_operator_no=99991000
                and instr(TOPFUNDRIGHT.vc_rights, '1') > 0
    ) > 0
```

oracle �еģ�+����

��һ��������÷�����+����ʾ�����ӣ��������Ƿ��ڷ������һ����

����

�������ӣ�select A.a,B.a from A LEFT JOIN B ON A.b=B.b;

�ȼ��� select A.a,B.a from A,B where A.b = B.b(+);

�پٸ����ӣ�������������ӣ�select A.a,B.a from A RIGHT JOIN B ON A.b=B.b;

�ȼ��� select A.a,B.a from A,B where A.b (+) = B.b;

