select 'Create Table tstp_info_synmanager...';
CREATE TABLE IF NOT EXISTS tstp_info_synmanager (
    `table_name` varchar(128),
    `table_caption` varchar(128),
    `use_flag` char(1) DEFAULT '1',
    `last_syn_date_time` datetime,
    `create_date_time` datetime,
    `update_date_time` datetime,
    PRIMARY KEY (`table_name`)
    );

select 'Create Table tstp_info_source...';
CREATE TABLE IF NOT EXISTS tstp_info_source (
    `source_id` int(8),
    `source_name`  varchar(128),
    `create_date_time` datetime,
    `update_date_time` datetime,
    PRIMARY KEY (`source_id`)
    );


select 'Create Table tstp_info_sourceconfig...';
CREATE TABLE IF NOT EXISTS tstp_info_sourceconfig (
    `source_id` int(8),
    `table_name` varchar(128),
    `task_name`  varchar(128),
    `db_type` char(1),
    `sql_stmt`  varchar(4000),
    `create_date_time` datetime,
    `update_date_time` datetime,
    PRIMARY KEY (`source_id`, `table_name`, `task_name`, `db_type`)
    );


select 'Create Table tstp_info_datasource...';
CREATE TABLE IF NOT EXISTS tstp_info_datasource (
    `news_platform_id` int(8) NOT NULL AUTO_INCREMENT,
    `news_platform_name` varchar(128) ,
    `source_id`  int(8),
    `db_type` char(1),
    `db_link`  varchar(512),
    `db_user`  varchar(32),
    `db_pwd`  varchar(128),
    `delete_flag` char(1) DEFAULT '0',
    `create_date_time` datetime,
    `update_date_time` datetime,
    PRIMARY KEY (`news_platform_id`)
    );


select 'Create Table tstp_info_synconfig...';
CREATE TABLE IF NOT EXISTS tstp_info_synconfig (
    `config_id` int(8) NOT NULL AUTO_INCREMENT,
    `table_name` varchar(128),
    `news_platform_id`  int(8),
    `delete_flag` char(1) DEFAULT '0',
    `task_name`  varchar(128),
    `sql_stmt`  varchar(4000),
    `create_operator` int(8),
    `create_date_time` datetime,
    `update_date_time` datetime,
    PRIMARY KEY (`config_id`)
    );

select 'Create Table tstp_info_quotedaily...';
CREATE TABLE IF NOT EXISTS tstp_info_quotedaily (
    `id` bigint(20) comment 'ID主键',
    `trade_date` int(8) comment '交易日',
    `stock_code` varchar(32) comment '证券代码',
    `market_no`  varchar(3) comment '交易市场',
    `close_price` decimal(20,12) comment '昨收盘价',
    `open_price`  decimal(20,12) comment '今开盘价',
    `closing_price`  decimal(20,12) comment '当日收盘价',
    `max_price` decimal(20,12) comment '今最高价',
    `min_price` decimal(20,12) comment '今最低价',
    `deal_balance`  decimal(18,6) comment '成交金额',
    `deal_amount` decimal(20,4) comment '成交数量',
    `deal_count`  decimal(10,0) comment '成交笔数',
    `top_price`  decimal(20,12) comment '涨停价',
    `bottom_price` decimal(20,12) comment '跌停价',
    `stop_flag` char(1) comment '停牌标志',
    `create_date_time` datetime comment '创建日期时间',
    `update_date_time` datetime comment '更新日期时间',
    PRIMARY KEY (`id`)
    ) comment '日行情表';

set @hs_sql = 'select 1 into @hs_sql;' ;
set @db_version = '';
select version() INTO @db_version from dual;
select 'ALTER TABLE tstp_info_quotedaily add index idx_tstp_info_quotedaily(market_no,stock_code,trade_date)' into @hs_sql from dual
where (SELECT count(*) FROM information_schema.statistics b WHERE  b.table_schema=(DATABASE()) AND lower(b.table_name) = 'tstp_info_quotedaily'  AND lower(b.index_name) = lower('idx_tstp_info_quotedaily')) = 0 and instr(@db_version,'OceanBase') <= 0 ;
PREPARE stmt FROM @hs_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

select 'Create Table tstp_info_rstrfactor...';
CREATE TABLE IF NOT EXISTS tstp_info_rstrfactor (
    `id` bigint(20) comment 'ID主键',
    `trade_date` int(8) comment '除权除息日',
    `stock_code` varchar(32) comment '证券代码',
    `market_no`  varchar(3) comment '交易市场',
    `rstr_factor` decimal(24,8) comment '比例复权因子',
    `create_date_time` datetime comment '创建日期时间',
    `update_date_time` datetime comment '更新日期时间',
    PRIMARY KEY (`id`)
    );

set @hs_sql = 'select 1 into @hs_sql;' ;
set @db_version = '';
select version() INTO @db_version from dual;
select 'ALTER TABLE tstp_info_rstrfactor add index idx_tstp_info_rstrfactor(market_no,stock_code,trade_date)' into @hs_sql from dual
where (SELECT count(*) FROM information_schema.statistics b WHERE  b.table_schema=(DATABASE()) AND lower(b.table_name) = 'tstp_info_rstrfactor'  AND lower(b.index_name) = lower('idx_tstp_info_rstrfactor')) = 0 and instr(@db_version,'OceanBase') <= 0 ;
PREPARE stmt FROM @hs_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

select 'Create Table tstp_info_bondinfo...';
CREATE TABLE IF NOT EXISTS tstp_info_bondinfo (
    `id` bigint(20) comment 'ID主键',
    `market_no`  varchar(3) comment '交易市场',
    `stock_code` varchar(32) comment '证券代码',
    `stock_name` varchar(128) comment '证券名称',
    `stock_type`  int   comment '证券类别',
    `issue_scale` decimal(24,8) comment '发行规模',
    `list_date` int(8) comment '上市日期',
    `zx_zqqx`  decimal(24,8) comment '债券期限',
    `expire_date` int(8) comment '到期日',
    `right_flag` char comment '是否含权',
    `create_date_time` datetime comment '创建日期时间',
    `update_date_time` datetime comment '更新日期时间',
    PRIMARY KEY (`id`)
);

set @hs_sql = 'select 1 into @hs_sql;' ;
set @db_version = '';
select version() INTO @db_version from dual;
select 'ALTER TABLE tstp_info_bondinfo add index idx_tstp_info_bondinfo(market_no,stock_code)' into @hs_sql from dual
where (SELECT count(*) FROM information_schema.statistics b WHERE  b.table_schema=(DATABASE()) AND lower(b.table_name) = 'tstp_info_bondinfo'  AND lower(b.index_name) = lower('tstp_info_bondinfo')) = 0 and instr(@db_version,'OceanBase') <= 0 ;
PREPARE stmt FROM @hs_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 资源来源
-- 聚源
set @v_rowcount = 0;
select count(*) into @v_rowcount from tstp_info_source where source_id = 1;
set @sql = if(@v_rowcount=0, "insert into tstp_info_source(source_id, source_name, create_date_time, update_date_time)values(1,'聚源',now(),now());","select 1;");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
