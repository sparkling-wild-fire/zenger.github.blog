# 资讯平台-sql

1. `where 1=1`:

用于做条件拼接，用户传了条件后只需要在后面追加 add 条件就ok，而不用每次都判断前面是否有where


2. oracle设置主键自增

为这个字段创建序列号 => 插入时获取该序列号的值 => 插入完成后序列号的值设置加1

```oracle
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
            info_id char(1),
            sql_stmt varchar2(4000),
            use_flag CHAR default ''0'' not null,       -- 注意这里时两个单引号
            create_date_time date,
            update_date_time date,    
            constraint pk_tstp_info_synconfig primary key (config_id),
            constraint unique_tstp_info_synconfig unique (table_name, task_name, use_flag)
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


-- 插入

insert into tstp_info_synconfig(config_id, table_name, task_name, info_id, sql_stmt, use_flag, create_date_time, update_date_time)
     select seq_config_id.nextval,'1', '2', '3', '1', '1', '2023-01-02','2023-09-02' from dual;
commit;

-- 或者
insert into tstp_info_datasource(info_id, infosource_name, db_link, db_type, db_user, db_pwd, source_id)
    values (seq_info_id.nextval, '1', '2', '3', '1', '1', '2023-01-02','2023-09-02');
commit;
```

3. oracle实现order+Limit

```oracle
select * from (
    select * from tabel_name
    order by update_date_time desc
) where rownum <= 10
```

4. mysql中存储小数用`decimal` , 用double的话存在精度损失，积少成多，容易给客户造成损失
    - `decimal`用的空间较大
    - cpu不支持`decimal`的运算，是mysql自己实现的

5. insert into

```oracle
insert into tstp_info_synconfig(
                    config_id, info_id, table_name, task_name, sql_stmt, create_date_time, update_date_time) 
                   values (seq_config_id.nextval, 2, '3', '4', '4', select to_char(sysdate,'yyyy-mm-dd HH24:MI:SS')from dual,
                            select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') from dual);
```

正确写法：

```oracle

```
