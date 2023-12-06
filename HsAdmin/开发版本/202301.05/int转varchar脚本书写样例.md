# intתvarchar�ű���д����

oracle��Oceandb��int����תvarcharʱ����Ҫ�����ֶε���������ΪNULL��Ϊ����ԭ�����ݣ�oracle��ͨ�����½ű�(����lightdb)ʵ��ת����

```oracle
prompt 'T202311034169 tstp_optionproperty �� time_stamp ���Ϊvarchar2(21 CHAR) ';
declare
    iCountNum number;
begin
    iCountNum := 0;
    select count(*) into iCountNum from user_tab_columns where table_name = upper('tstp_optionproperty') and column_name = upper('time_stamp') and data_type=upper('number');
    if (iCountNum <> 0) then
            EXECUTE IMMEDIATE 'alter table tstp_optionproperty rename column time_stamp to time_stamp_bak';
            EXECUTE IMMEDIATE 'alter table tstp_optionproperty add time_stamp varchar2(21 CHAR) DEFAULT null NULL';
            EXECUTE IMMEDIATE 'update tstp_optionproperty set time_stamp=time_stamp_bak';
            EXECUTE IMMEDIATE 'alter table tstp_optionproperty drop column time_stamp_bak';
    end if;
end;
/
```

����mysql�е�if���ֻ֧���ڴ洢������ʹ�ã����mysql��ͨ�����½ű�(����Obmysql)ʵ��ת��:

```mysql
SELECT 'T202311034157  tstp_optionproperty�� time_stamp ����Ϊvarchar(21)';
set @hs_sql = 'select 1 into @hs_sql;'; 
select "ALTER TABLE tstp_optionproperty ADD COLUMN time_stamp_bak varchar(21);" into @hs_sql from dual 
WHERE (SELECT COUNT(1) FROM information_schema.columns WHERE table_schema=(database()) AND table_name=upper('tstp_optionproperty') AND column_name=upper('time_stamp') AND DATA_TYPE='int') = 1;
PREPARE stmt FROM @hs_sql; 
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
 
set @hs_sql = 'select 1 into @hs_sql;'; 
select "UPDATE tstp_optionproperty SET time_stamp_bak = time_stamp;" into @hs_sql from dual 
WHERE (SELECT COUNT(1) FROM information_schema.columns WHERE table_schema=(database()) AND table_name=upper('tstp_optionproperty') AND column_name=upper('time_stamp_bak')) = 1
and (SELECT COUNT(1) FROM information_schema.columns WHERE table_schema=(database()) AND table_name=upper('tstp_optionproperty') AND column_name=upper('time_stamp') AND DATA_TYPE='int') = 1;
PREPARE stmt FROM @hs_sql; 
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

set @hs_sql = 'select 1 into @hs_sql;'; 
select "ALTER TABLE tstp_optionproperty DROP COLUMN time_stamp;"
 into @hs_sql from dual 
WHERE (SELECT COUNT(1) FROM information_schema.columns WHERE table_schema=(database()) AND table_name=upper('tstp_optionproperty') AND column_name=upper('time_stamp_bak')) = 1 
and (SELECT COUNT(1) FROM information_schema.columns WHERE table_schema=(database()) AND table_name=upper('tstp_optionproperty') AND column_name=upper('time_stamp') AND DATA_TYPE='int') = 1;
PREPARE stmt FROM @hs_sql; 
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

set @hs_sql = 'select 1 into @hs_sql;'; 
select "ALTER TABLE tstp_optionproperty CHANGE COLUMN time_stamp_bak time_stamp varchar(21);"
 into @hs_sql from dual 
WHERE (SELECT COUNT(1) FROM information_schema.columns WHERE table_schema=(database()) AND table_name=upper('tstp_optionproperty') AND column_name=upper('time_stamp_bak')) = 1
and (SELECT COUNT(1) FROM information_schema.columns WHERE table_schema=(database()) AND table_name=upper('tstp_optionproperty') AND column_name=upper('time_stamp') AND DATA_TYPE='int') = 0;
PREPARE stmt FROM @hs_sql; 
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
```

��Щ�ű�������Ϊ��ʱ����oracle�У�20w�����ݽ�������ת����Ҫ8s��50w�����ݽ���ת����Ҫ15s������д�� `*��ʷ��ṹ���(���ڲ�����ʷ�����ܱȽϺ�ʱ����������ǰ����ִ��).sql`