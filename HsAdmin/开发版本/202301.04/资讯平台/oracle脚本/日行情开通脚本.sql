-- 日行情表
declare
v_rowcount number(5);
begin
select count(*) into v_rowcount from tstp_info_synmanager where table_name = 'tstp_info_quotedaily';
if v_rowcount = 0 then
    insert into tstp_info_synmanager(table_name, table_caption, use_flag, last_syn_date_time,create_date_time,update_date_time)
        values('tstp_info_quotedaily','日行情表','1',sysdate,sysdate,sysdate);
end if;
commit;
end;
/

-- 复权因子表
declare
v_rowcount number(5);
begin
select count(*) into v_rowcount from tstp_info_synmanager where table_name = 'tstp_info_rstrfactor';
if v_rowcount = 0 then
    insert into tstp_info_synmanager(table_name, table_caption, use_flag, last_syn_date_time,create_date_time,update_date_time)
        values('tstp_info_rstrfactor','复权因子表','1',sysdate,sysdate,sysdate);
end if;
commit;
end;
/


-- 聚源同步配置
declare
v_rowcount number(5);
begin
select count(*) into v_rowcount from tstp_info_sourceconfig where source_id = 1 and table_name = 'tstp_info_quotedaily' and task_name = '主板股票' and db_type = ' ';
if v_rowcount = 0 then
    insert into tstp_info_sourceconfig(source_id, table_name, task_name, db_type, sql_stmt, create_date_time, update_date_time)
        values(1,'tstp_info_quotedaily','主板股票','0','select qs.JSID as id , DATE_FORMAT(qs.TradingDay, ''%Y%m%d'') as trade_date,
                                                           case sm.SecuMarket
                                                               when 83 then 1
                                                               when 90 then 2
                                                               when 51 then 7
                                                               when 18 then 105
                                                               when 81 then 10
                                                               else 0
                                                               end as market_no,
                                                           sm.SecuCode as stock_code, qs.PrevClosePrice as close_price, qs.OpenPrice as open_price, qs.ClosePrice as closing_price,
                                                           qs.HighPrice max_price,qs.LowPrice as min_price, qs.TurnoverValue as deal_balance, qs.TurnoverVolume as deal_amount,
                                                           qs.TurnoverVolume /qp.BuyNumUnit as deal_count, qp.PriceCeiling as top_price, qp.PriceFloor as bottom_price,
                                                           qs.Ifsuspend as stop_flag, qs.InsertTime as create_date_time, qs.UpdateTime as update_date_time
                                                    from qt_stockperformance qs
                                                             join qt_pricelimit qp on qs.InnerCode = qp.InnerCode and qs.TradingDay = qp.TradingDay
                                                             join secumain sm on qs.InnerCode = sm.InnerCode',sysdate,sysdate);
end if;
commit;
end;
/

declare
v_rowcount number(5);
begin
select count(*) into v_rowcount from tstp_info_sourceconfig where source_id = 1 and table_name = 'tstp_info_rstrfactor' and task_name = '股票复权因子' and db_type = ' ';
if v_rowcount = 0 then
    insert into tstp_info_sourceconfig(source_id, table_name, task_name, db_type, sql_stmt, create_date_time, update_date_time)
        values(1,'tstp_info_rstrfactor','股票复权因子','0','select qsa.JSID as id, DATE_FORMAT(qsa.ExDiviDate,''%Y%m%d'') as trade_date,
                                                                               case sm.SecuMarket
                                                                                  when 83 then 1
                                                                                  when 90 then 2
                                                                                  when 51 then 7
                                                                                  when 18 then 105
                                                                                  when 81 then 10
                                                                                  else 0
                                                                                  end as market_no,
                                                                               sm.SecuCode as stock_code,
                                                                               qsa.AdjustingFactor as rstr_factor,
                                                                               qsa.InsertTime as create_date_time,
                                                                               qsa.UpdateTime as update_date_time
                                                                        from QT_StockAdjustFactor qsa
                                                                                 left join SecuMain sm on qsa.InnerCode = sm.InnerCode',sysdate,sysdate);
end if;
commit;
end;
/