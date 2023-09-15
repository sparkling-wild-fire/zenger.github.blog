prompt '资讯同步管理表';
declare
icnt number := 0;
begin
select count(*) into icnt from user_tables where lower(table_name) = 'tstp_info_synmanager';
if icnt = 0 then
        execute immediate 'create table tstp_info_synmanager
        (
            table_name varchar2(128),
            table_caption varchar2(128),
            use_flag char(1) DEFAULT ''1'',
            last_syn_date_time date,
            create_date_time date,
            update_date_time date,
            constraint pk_tstp_info_synmanager primary key (table_name)
        )';
end if;
end;
/

prompt '资讯来源表';
declare
icnt number := 0;
begin
select count(*) into icnt from user_tables where lower(table_name) = 'tstp_info_source';
if icnt = 0 then
        execute immediate 'create table tstp_info_source
        (
            source_id number(8,0),
            source_name varchar2(128),
            create_date_time date,
            update_date_time date,
            constraint pk_tstp_info_source primary key (source_id)
        )';
end if;
end;
/

prompt '资讯源同步参考配置表';
declare
icnt number := 0;
begin
select count(*) into icnt from user_tables where lower(table_name) = 'tstp_info_sourceconfig';
if icnt = 0 then
        execute immediate 'create table tstp_info_sourceconfig
        (
            source_id number(8,0),
            table_name varchar2(128),
            task_name varchar2(128),
            db_type char(1),
            sql_stmt varchar2(4000),
            create_date_time date,
            update_date_time date,
            constraint pk_tstp_info_sourceconfig primary key (source_id, table_name, task_name, db_type)
        )';
end if;
end;
/

prompt '资讯源表';
declare
icnt number := 0;
begin
select count(*) into icnt from user_tables where lower(table_name) = 'tstp_info_datasource';
if icnt = 0 then
        execute immediate 'create table tstp_info_datasource
        (
            news_platform_id number(8,0),
            news_platform_name varchar2(128),
            source_id number(8,0),
            db_link varchar2(512),
            db_type char(1),
            db_user varchar2(32),
            db_pwd varchar2(128),
            delete_flag char(1) DEFAULT ''0'',
            create_date_time date,
            update_date_time date,
            constraint pk_tstp_info_datasource primary key (news_platform_id)
        )';
end if;
end;
/

prompt Create Sequence 'seq_news_platform_id';
declare
v_rowcount number(10);
begin
select count(*) into v_rowcount from user_sequences where upper(sequence_name) = upper('seq_news_platform_id');
if (v_rowcount = 0) then
        execute immediate 'create sequence seq_news_platform_id MINVALUE 1 MAXVALUE 100000000  INCREMENT BY 1 NOCYCLE CACHE 20 ';
end if;
end;
/

prompt '资讯同步配置表';
declare
icnt number := 0;
begin
select count(*) into icnt from user_tables where lower(table_name) = 'tstp_info_synconfig';
if icnt = 0 then
        execute immediate 'create table tstp_info_synconfig
        (
            config_id number(8,0),
            table_name varchar2(128),
            task_name varchar2(128),
            news_platform_id number(8,0),
            sql_stmt varchar2(4000),
            delete_flag char(1) DEFAULT ''0'',
            create_operator number(8,0),
            create_date_time date,
            update_date_time date,
            constraint pk_tstp_info_synconfig primary key (config_id)
        )';
end if;
end;
/

prompt Create Sequence 'seq_config_id';
declare
v_rowcount number(10);
begin
select count(*) into v_rowcount from user_sequences where upper(sequence_name) = upper('seq_config_id');
if (v_rowcount = 0) then
        execute immediate 'create sequence seq_config_id MINVALUE 1 MAXVALUE 100000000  INCREMENT BY 1 NOCYCLE CACHE 20 ';
end if;
end;
/

prompt '日行情表';
declare
icnt number := 0;
begin
select count(*) into icnt from user_tables where lower(table_name) = 'tstp_info_quotedaily';
if icnt = 0 then
        execute immediate 'create table tstp_info_quotedaily
        (
            id number(20,0),
            trade_date number(8,0),
            market_no varchar2(3),
            stock_code varchar2(32),
            close_price number(20,12),
            open_price number(20,12),
            closing_price number(20,12),
            max_price number(20,12),
            min_price number(20,12),
            deal_balance number(18,6),
            deal_amount number(20,4),
            deal_count number(10,0),
            top_price number(20,12),
            bottom_price number(20,12),
            stop_flag char(1),
            create_date_time date,
            update_date_time date,
            constraint pk_tstp_info_quotedaily primary key(id)
        )';
execute immediate 'create index idx_tstp_info_quotedaily on tstp_info_quotedaily(market_no, stock_code, trade_date)';
end if;
end;
/

prompt Create Sequence 'seq_quotedaily_id';
declare
    v_rowcount number(10);
begin
select count(*) into v_rowcount from user_sequences where upper(sequence_name) = upper('seq_quotedaily_id');
if (v_rowcount = 0) then
execute immediate 'create sequence seq_quotedaily_id MINVALUE 1 MAXVALUE 10000000000000000000  INCREMENT BY 1 NOCYCLE CACHE 20 ';
end if;
end;
/

comment on table tstp_info_quotedaily is '日行情表';
comment on column tstp_info_quotedaily.id is 'ID主键';
comment on column tstp_info_quotedaily.trade_date is '交易日';
comment on column tstp_info_quotedaily.market_no is '交易市场';
comment on column tstp_info_quotedaily.stock_code is '证券代码';
comment on column tstp_info_quotedaily.close_price is '昨收盘价';
comment on column tstp_info_quotedaily.open_price is '今开盘价';
comment on column tstp_info_quotedaily.closing_price is '当日收盘价';
comment on column tstp_info_quotedaily.max_price is '今最高价';
comment on column tstp_info_quotedaily.min_price is '今最低价';
comment on column tstp_info_quotedaily.deal_balance is '成交金额';
comment on column tstp_info_quotedaily.deal_amount is '成交数量';
comment on column tstp_info_quotedaily.deal_count is '成交笔数';
comment on column tstp_info_quotedaily.top_price is '涨停价';
comment on column tstp_info_quotedaily.bottom_price is '跌停价';
comment on column tstp_info_quotedaily.stop_flag is '停牌标志';
comment on column tstp_info_quotedaily.create_date_time is '创建日期时间';
comment on column tstp_info_quotedaily.update_date_time is '更新日期时间';

prompt '复权因子表';
declare
icnt number := 0;
begin
select count(*) into icnt from user_tables where lower(table_name) = 'tstp_info_rstrfactor';
if icnt = 0 then
        execute immediate 'create table tstp_info_rstrfactor
        (
            id number(20,0),
            trade_date number(8,0),
            market_no varchar2(3),
            stock_code varchar2(32),
            rstr_factor number(24,8),
            create_date_time date,
            update_date_time date,
            constraint pk_tstp_info_rstrfactor primary key(id)
        )';
execute immediate 'create index idx_tstp_info_rstrfactor on tstp_info_rstrfactor(market_no, stock_code, trade_date)';
end if;
end;
/

prompt Create Sequence 'seq_rstrfactor_id';
declare
    v_rowcount number(10);
begin
select count(*) into v_rowcount from user_sequences where upper(sequence_name) = upper('seq_rstrfactor_id');
if (v_rowcount = 0) then
execute immediate 'create sequence seq_rstrfactor_id MINVALUE 1 MAXVALUE 10000000000000000000  INCREMENT BY 1 NOCYCLE CACHE 20 ';
end if;
end;
/

comment on table tstp_info_rstrfactor is '复权因子表';
comment on column tstp_info_rstrfactor.id is 'ID主键';
comment on column tstp_info_rstrfactor.trade_date is '除权除息日';
comment on column tstp_info_rstrfactor.market_no is '交易市场';
comment on column tstp_info_rstrfactor.stock_code is '证券代码';
comment on column tstp_info_rstrfactor.rstr_factor is '比例复权因子';
comment on column tstp_info_rstrfactor.create_date_time is '创建日期时间';
comment on column tstp_info_rstrfactor.update_date_time is '更新日期时间';

prompt '债券信息表';
declare
icnt number := 0;
begin
select count(*) into icnt from user_tables where lower(table_name) = 'tstp_info_bondinfo';
if icnt = 0 then
execute immediate 'create table tstp_info_bondinfo
        (
          id number(20,0),
          market_no  varchar(3),
          stock_code varchar(32),
          stock_name varchar(128),
          stock_type  number(8),
          issue_scale number(24,8),
          list_date number(8,0),
          zx_zqqx  number(24,8),
          expire_date number(8,0),
          right_flag char(1),
          create_date_time date,
          update_date_time date,
          constraint pk_tstp_info_bondinfo primary key(id)
        )';
execute immediate 'create index idx_tstp_info_bondinfo on tstp_info_bondinfo(market_no, stock_code)';
end if;
end;
/

prompt Create Sequence 'seq_bondinfo_id';
declare
v_rowcount number(10);
begin
select count(*) into v_rowcount from user_sequences where upper(sequence_name) = upper('seq_bondinfo_id');
if (v_rowcount = 0) then
execute immediate 'create sequence seq_bondinfo_id MINVALUE 1 MAXVALUE 100000000  INCREMENT BY 1 NOCYCLE CACHE 20 ';
end if;
end;
/

comment on table tstp_info_bondinfo is '债券属性表';
comment on column tstp_info_bondinfo.id is 'ID主键';
comment on column tstp_info_bondinfo.market_no is '交易市场';
comment on column tstp_info_bondinfo.stock_code is '证券代码';
comment on column tstp_info_bondinfo.stock_name is '证券名称';
comment on column tstp_info_bondinfo.stock_type is '证券类别';
comment on column tstp_info_bondinfo.issue_scale is '发行规模';
comment on column tstp_info_bondinfo.list_date is '上市日期';
comment on column tstp_info_bondinfo.zx_zqqx is '债券期限';
comment on column tstp_info_bondinfo.expire_date is '到期日';
comment on column tstp_info_bondinfo.right_flag is '是否含权';
comment on column tstp_info_bondinfo.create_date_time is '创建日期时间';
comment on column tstp_info_bondinfo.update_date_time is '更新日期时间';
/

-- 资源来源
-- 聚源
declare
v_rowcount number(5);
begin
select count(*) into v_rowcount from tstp_info_source where source_id = 1;
if v_rowcount = 0 then
    insert into tstp_info_source(source_id, source_name, create_date_time, update_date_time)values(1,'聚源',sysdate,sysdate);
end if;
commit;
end;
/




