# gdb调试

gdb -pid=`mt进程号`
b F功能号     => 打断点F440281002宽途直接心跳失败了
r

## 宽途下载实例

这个是因为Oracle占用过多内存，然后系统把这个进程给杀死了吗?

试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据时,系统就会发送给进程`11`这样信号

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230614103202.png" alt="20230614103202" width="450" >

[valgrind](https://zhuanlan.zhihu.com/p/298015939)

[解core](https://www.cnblogs.com/rainisraining/p/14715533.html)
