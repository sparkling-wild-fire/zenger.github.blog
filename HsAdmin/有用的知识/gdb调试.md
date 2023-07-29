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

## algoserver调试 (gdb attach)

背景：

编译python策略的so，编译成功，但是一运行就产生core，调用栈为：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230627171450.png" alt="20230627171450" width="850" >

看代码，第三个栈帧并未调用第三个栈帧，而是调用的`GetProviderID()` ,对此我非常迷惑。

1. 首先查看这个策略的进程号：

    `ps -ef | grep -E 'algoserver_as_zengzg.*37.out'`，其中37标识python策略为第37个策略；或者uft的策略站点信息表查看

2. gdb附着这个进程

   - `gdb --pid/attach 进程号`
   - 在第三个栈帧加断点`b StrategySchemeImpl.cpp:430`
   - 继续执行`c`(如果发现没有命中这个断点，可以在第四个栈帧继续一个断点，然后`c`跳转到`StrategySchemeImpl.cpp:430`)
   - 命中第三个栈帧后，`n`执行，发现python进程收到中断信号
   
   具体现象如下：
    
    <img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230627172015.png" alt="20230627172015" width="850" >

所以，在第三个栈帧的时候就应该产生core了，第二个栈帧应该是python进程重启的时候产生的（所以第二个栈帧为什么会写入这个core呢？）。因此，问题就聚焦到`GetProviderID()`这个函数了。

解决：`GetProviderID()`在src/algo中定义，因此拉取最新的src代码，编译algo解决问题。（但algo的so本来就是最新的，为什么要用最新的src重编才可以呢？=> 难道这个so不不是最新的src编译生成的？=> 不可能啊）

## V2包异常

代码：
```C++
IF2UnPacker *lpRstrFactorResultSet = rstrFactorPacker->UnPack();
while(!lpRstrFactorResultSet->IsEOF()){}     // => 这行报错
```

调试：

1. 打开开关：`set print object on`
2. 查看变量类型和地址：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230728155355.png" alt="20230728155355" width="450" >

3. 查看Message：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230728160508.png" alt="20230728160508" width="450" >

4. 查看当前数据集：

这里如果是0x0, 则说明v2包是个空包，调用IsEoF产生core

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230728160540.png" alt="20230728160540" width="450" >

