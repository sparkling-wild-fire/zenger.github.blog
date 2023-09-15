# oracle查看表锁并解锁

当在一个应用程序能改动数据库，而其他应用程序都不能改动时，基本就说明表被锁了

[参考链接](https://www.php.cn/faq/488267.html)

## 查看锁
执行命令:`select * from v$locked_object;`  (有的表没有这个视图)

如果出现`表或视图不存在`的错误，是因为用户权限不够

以系统身份登陆oracle服务器授权：
`grant select  any dictionary to 用户名;`

再次执行上面的命令：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/c9470acebb96289e482e7feaedca2d1.png" alt="c9470acebb96289e482e7feaedca2d1" width="450">

其中locked_mode的取值为：

0：none
1：null 空
2：Row-S 行共享(RS)：共享表锁，sub share
3：Row-X 行独占(RX)：用于行的修改，sub exclusive
4：Share 共享锁(S)：阻止其他DML操作，share
5：S/Row-X 共享行独占(SRX)：阻止其他事务操作，share/sub exclusive
6：exclusive 独占(X)：独立访问使用，exclusive

直接根据process解锁(`Linux:kill -9 10856`;`Windows:taskkill /pid 10856 /F`)就行,如果想查看更详细点的信息，可使用下面两条命令查看：

- 根据object_id查看表名：`select * from user_objects where object_id = 269827;`

- 查看表名被锁的行：`select * from ALGOJR_TPARAMETERS for update skip locked;`

## 问题

我批量执行了`delete from tabename`，然后发现很多表都被锁了，但是前面的列都是0,

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/57de8255ec9ee9b330a37c2e1975c70d.png" alt="57de8255ec9ee9b330a37c2e1975c70d" width="450" >

然后执行ccommit后，所有的锁都被释放了。