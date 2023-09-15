set @v_rowcount = 0;
select count(*) into @v_rowcount from tstp_info_synmanager where table_name = 'tstp_info_bondinfo';
set @sql = if(@v_rowcount=0, "insert into tstp_info_synmanager(table_name, table_caption, use_flag, last_syn_date_time,create_date_time,update_date_time)
        values('tstp_info_bondinfo','债券属性表','1',now(),now(),now());","select 1;");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

-- 聚源同步配置
set @v_rowcount = 0;
select count(*) into @v_rowcount from tstp_info_sourceconfig where source_id = 1 and table_name = 'tstp_info_bondinfo' and task_name = '债券属性同步' and db_type = ' ';
set @sql = if(@v_rowcount=0, "insert into tstp_info_sourceconfig(source_id, table_name, task_name, db_type, sql_stmt, create_date_time, update_date_time)
        values(1,'tstp_info_bondinfo','债券属性同步','0','select bb.JSID as id,
                                                               case sm.SecuMarket
                                                                   when 83 then 1
                                                                   when 90 then 2
                                                                   when 51 then 7
                                                                   when 18 then 105
                                                                   when 81 then 10
                                                                   else 0
                                                                   end as market_no,
                                                               sm.SecuCode as stock_code,
                                                               bb.BondFullName as stock_name,
                                                               case bb.BondNature
                                                                   when 4 then 3
                                                                   when 1 then 4
                                                                   when 10 then 5
                                                                   when 2 then 6
                                                                   when 34 then 12
                                                                   when 3 then 16
                                                                   when 21 then 17
                                                                   when 13 then 24
                                                                   when 16 then 25
                                                                   when 36 then 62
                                                                   when 15 then 94
                                                                   when 29 then 95
                                                                   when 18 then 103
                                                                   when 9 then 105
                                                                   when 23 then 124
                                                                   when 20 then 151
                                                                   when 7 then 168
                                                                   when 5 then 36
                                                                   when 14 then 65
                                                                   when 17 then 104
                                                                   when 25 then 102
                                                                   when 12 then 150
                                                                   when 6 then 101
                                                                   when 19 then 106
                                                                   when 30 then 115
                                                                   when 37 then 161
                                                                   else 0
                                                                   end as stock_type,
                                                               bb.LatestIssueSize as issue_scale,
                                                               bb.ListedDate as list_date,
                                                               bb.Maturity as zx_zqqx,
                                                               if(bb.EndDate is null , 0 ,DATE_FORMAT(bb.EndDate,''%Y%m%d'')) as expire_date,
                                                               if(bb.OptionType is null, 0, 1) as right_flag,
                                                               bb.InsertTime as create_date_time,
                                                               bb.UpdateTime as update_date_time
                                                        from Bond_BasicInfoN bb
                                                                 left join SecuMain sm on bb.InnerCode = sm.InnerCode',now(),now());", "select 1;");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;


