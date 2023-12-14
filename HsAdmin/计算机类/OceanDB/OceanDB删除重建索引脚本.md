# OceanDB删除重建索引脚本

[官方文档，相关操作链接](https://www.oceanbase.com/docs/community-observer-cn-10000000000450633)

## 常用sql命令

```sql
--- 删除所有的表：
SELECT CONCAT('DROP TABLE IF EXISTS ', table_name, ';') FROM information_schema.tables WHERE table_schema = '数据库名';
--- 查看版本号  5.7.25-OceanBase-v3.2.4.5
SELECT version();
--- 获取每个表的字段
show columns from zenger.algojr_tanlzindex2;
--- 查看表索引
select * from information_schema.statistics a
where table_schema=database() AND lower(a.`TABLE_NAME`) = lower('thisstp_makerduty') AND a.`INDEX_NAME` = 'PRIMARY';
```

# go安装OceanDB驱动

[go安装OceanDB驱动](https://www.alibabacloud.com/help/zh/apsaradb-for-oceanbase/latest/go-driver-connection-oceanbase-database)

下载驱动到本地后，执行：`go install \path\to\github.com\go-sql-driver\mysql`,如`D:\GO\github.com\go-sql-driver\mysql` (麻烦，没用)

建议用网络自动进行包管理：

```shell
# 通过代理，不行
set http_proxy=http://127.0.0.1:7890
# 通过镜像，ok
go env -w GOPROXY=https://goproxy.cn,direct
go get -u github.com/go-sql-driver/mysql
```


查看包的安装路径：
在 Go 中，安装的包会被下载到 $GOPATH/pkg/mod 目录下，并根据版本号存储在相应的子目录中。因此，可以通过以下步骤来查看 github.com/go-sql-driver/mysql 包的安装路径：
1. 打开命令行或终端窗口,执行命令 go env GOPATH，查看您的 GOPATH 路径。
2. 在 $GOPATH/pkg/mod 目录下找到 github.com/go-sql-driver/mysql 目录，其中的子目录名称应该与安装的版本号相同


## 脚本生成流程

1. 先获取每个版本的主键修改
2. 遍历每个版本，获取涉及主键修改的表（以`thisstp_makerduty`为例）的创建sql语句
   - `show create table zenger.algojr_tanlzindex;`
3. 根据`thisstp_makerduty`创建sql,新建一个备份表`thisstp_makerduty_bak`,更改其主键
4. 将原表的数据拷贝一份到备份表
   - `INSERT INTO table_b SELECT * FROM table_a;`
   - 由于两个表的结构完全一致，且备份表为空，这个语句会进行批量复制，速度非常快，10w的数据量几秒搞定
4. 删除原表，将备份表的的名字重命名为原表
    - `DROP TABLE IF EXISTS table_name` 
    - `ALTER TABLE algojr_tanlzindex1 RENAME TO algojr_tanlzindex2;`



