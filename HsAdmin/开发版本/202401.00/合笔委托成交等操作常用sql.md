# �ϱ�ί�е�O3����

```sql
select * from tentrustscombi order by l_entrust_serial_no desc;
select l_entrust_serial_no,l_batch_serial_no,l_report_serial_no,c_entrust_status,vc_confirm_no,vc_report_code from tentrustscombi order by l_entrust_serial_no desc;

select * from tentrusts order by l_entrust_serial_no desc;
select l_entrust_serial_no,l_batch_serial_no,l_report_serial_no,c_entrust_status,c_entrust_direction,vc_confirm_no,vc_stockholder_id from tentrusts order by l_entrust_serial_no desc;

-- �޸ĺϱʺͷֱʵ�ί��״̬Ϊ����
declare
   -- ����ϱ�ί�����
   l_entrust_no number(8) := 189606;
begin
  update tentrusts a set a.c_entrust_status = '3' where a.l_batch_serial_no = l_entrust_no;
  update tentrustscombi a set a.c_entrust_status = '3' where a.l_entrust_serial_no = l_entrust_no;
  commit;
end;
```