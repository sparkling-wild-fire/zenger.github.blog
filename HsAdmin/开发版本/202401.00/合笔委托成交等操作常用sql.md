# 合笔委托调O3服务

```sql
select * from tentrustscombi order by l_entrust_serial_no desc;
select l_entrust_serial_no,l_batch_serial_no,l_report_serial_no,c_entrust_status,vc_confirm_no,vc_report_code from tentrustscombi order by l_entrust_serial_no desc;

select * from tentrusts order by l_entrust_serial_no desc;
select l_entrust_serial_no,l_batch_serial_no,l_report_serial_no,c_entrust_status,c_entrust_direction,vc_confirm_no,vc_stockholder_id from tentrusts order by l_entrust_serial_no desc;

-- 修改合笔和分笔的委托状态为正报
declare
   -- 填入合笔委托序号
   l_entrust_no number(8) := 189606;
begin
  update tentrusts a set a.c_entrust_status = '3' where a.l_batch_serial_no = l_entrust_no;
  update tentrustscombi a set a.c_entrust_status = '3' where a.l_entrust_serial_no = l_entrust_no;
  commit;
end;
```