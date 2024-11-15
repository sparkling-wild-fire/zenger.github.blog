# OTrade

## 标签页-按钮

tstp_toolbarbuttons表

DROP TABLE tstp_toolbarbuttons;

### 脚本

工具栏按钮表

```oracle
-- 创建表 tstp_toolbarbuttons
prompt 'T202403155177 新增表tstp_toolbarbuttons';
declare
    v_rowcount number(10);
begin
    select count(1) into v_rowcount from user_objects where upper(object_name) = upper('tstp_toolbarbuttons');
    if v_rowcount = 0 then
        execute immediate 'CREATE TABLE tstp_toolbarbuttons
    (
      operator_code varchar2(128) NOT NULL,
      module_id number(8,0) NOT NULL,
      label_id number(8,0) NOT NULL,
      button_id number(8,0) NOT NULL,
      button_name varchar2(128) NULL,
      table_name varchar2(128) NOT NULL,
      button_type_no number(8,0) NULL,
      visible_flag char(1) DEFAULT ''0'' NOT NULL,
      use_flag char(1) DEFAULT ''0'' NOT NULL,
      button_order number(8,0) NULL,
      user_custom_flag char(1) DEFAULT ''0'' NOT NULL,
      field_name varchar2(128) NULL,
      logic_operation number(8,0) NULL,
      codomain_content varchar2(128) NULL
    )';
        execute immediate 'ALTER TABLE tstp_toolbarbuttons add constraint pk_tstp_toolbarbuttons primary key (operator_code,module_id,label_id,button_id,table_name)';
    end if;
    commit;
end;
/

```

```mysql
SELECT 'T202403155177 新增表tstp_toolbarbuttons';
CREATE TABLE IF NOT EXISTS tstp_toolbarbuttons (
               operator_code varchar(128)  NOT NULL,
               module_id int(8)  NOT NULL,
               label_id int(8)  NOT NULL,
               button_id int(8)  NOT NULL,
               button_name varchar(128)  NULL DEFAULT NULL,
               table_name varchar(128)  NOT NULL,
               button_type_no int(8)  NULL DEFAULT NULL,
               visible_flag char(1)  NOT NULL DEFAULT '0',
               use_flag char(1)  NOT NULL DEFAULT '0',
               button_order int(8)  NULL DEFAULT NULL,
               user_custom_flag char(1)  NOT NULL DEFAULT '0',
               field_name varchar(128)  NULL DEFAULT NULL,
               logic_operation int(8)  NULL DEFAULT NULL,
               codomain_content varchar(128)  NULL DEFAULT NULL,
               PRIMARY KEY (`operator_code`,`module_id`,`label_id`,`button_id`,`table_name`)
);
```

### 接口

todo


## 表头

tstp_tableheader表

### 脚本

```oracle
declare
    v_rowcount number(10);
begin
    select count(1) into v_rowcount from user_objects where upper(object_name) = upper('tstp_tableheader');
    if v_rowcount = 0 then
        execute immediate 'CREATE TABLE tstp_tableheader
                           (
                               operator_code varchar2(128) NOT NULL,
                               module_id number(8,0) NOT NULL,
                               menu_id number(8,0) NOT NULL,
                               table_name varchar2(128) NOT NULL,
                               field_name varchar2(128) NOT NULL,
                               field_desc varchar(512) NOT NULL,
                               visible_flag char(1) DEFAULT ''0'',
                               field_id number(8) NOT NULL
                           )';
        execute immediate 'ALTER TABLE tstp_tableheader add  constraint pk_tstp_tableheader primary key (operator_code,module_id,menu_id,table_name,field_name)';
    end if;
end;
/
```

```mysql
select 'Create Table  tstp_tableheader...';
CREATE TABLE IF NOT EXISTS  tstp_tableheader (
     `operator_code` varchar(128) NOT NULL,    --
     `module_id` int(8) NOT NULL,           --
     `menu_id` int(8) NOT NULL,
     `table_name` varchar(128) NOT NULL,
     `field_name` varchar(128) NOT NULL,
     `field_desc` varchar(512) NOT NULL,
     `visible_flag` char(1) DEFAULT '0',
     `field_id` int(8) NOT NULL,
     PRIMARY KEY (`operator_code`,`module_id`,`menu_id`,`table_name`,`field_name`)
)
;
```



