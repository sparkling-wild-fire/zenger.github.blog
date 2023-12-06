# int转varchar脚本书写样例

oracle、Oceandb在int类型转varchar时，需要将该字段的所在列置为NULL，为保留原有数据，oracle可通过如下脚本(兼容lightdb)实现转换：

```oracle
prompt 'T202311034169 tstp_optionproperty 表 time_stamp 变更为varchar2(21 CHAR) ';
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

由于mysql中的if语句只支持在存储过程中使用，因此mysql可通过如下脚本(兼容Obmysql)实现转换:

```mysql
SELECT 'T202311034157  tstp_optionproperty表 time_stamp 更改为varchar(21)';
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

这些脚本操作较为耗时，在oracle中，20w的数据进行数据转换需要8s，50w的数据进行转换需要15s，还需写入 `*历史表结构变更(由于操作历史表，可能比较耗时，请在升级前单独执行).sql`