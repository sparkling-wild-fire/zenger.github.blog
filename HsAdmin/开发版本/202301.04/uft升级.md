# uftdb内存优化

需求：当前uftdb内存表每个表初始化的内存都比较大，需要升级uftdb

## 升级

1. 查看uft对应的so，在appcom目录下（如果在lib目录下，一般就是要升级中间件了）

[中间件升级](http://rdcdocs.hundsun.com/pages/viewpage.action?pageId=57553605)

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145010.png" alt="20230717145010" width="1250" >

2. 下载制品

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145305.png" alt="20230717145305" width="850" >

3. 覆盖`instance\linux.x64\lib`(非信创)、`instance\ArmV10\lib`(信创)下的so到`Sources\src\lib\appcom`和`Sources\src\lib_v10arm\appcom`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230920141504.png" alt="20230920141504" width="850">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230921150723.png" alt="20230921150723" width="850">

<font color="red">一定要注意：修改source/src下的makefile文件，将新增的so加入到STP_INSTALL中</font>

4. 覆盖`instance\linux.x64\lib`(非信创)、`instance\ArmV10\lib`(信创)下的so到`Run\ASAR\bin`和`Run\ASAR_V10ARM\bin`下

5. 替换`dev\`下的头文件

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230921133031.png" alt="20230921142001" width="850">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230921133214.png" alt="20230921133214" width="850">

6. 替换`instance\workspace`下的配置文件

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230921142300.png" alt="20230921142300" width="850">

一般来说，如果algotran/workspace下没有的配置文件不需要更新，对已有的xml文件进行覆盖更新就行

7. 查看内存使用大小，这些函数可以在下载制品的pdf中查找

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717150431.png" alt="20230717150431" width="850" ><br>
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145647.png" alt="20230717145647" width="850" ><br>
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145745.png" alt="20230717145745" width="850" ><br>
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230921095131.png" alt="20230921095131" width="850"><br>
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230921095236.png" alt="20230921095236" width="850">

8. 最后，在algo的Run\ASAR\bin\CRES2.0历史发布需求清单.xlsx文件中新增记录

## uft内存优化方式

每次清流重启mt，都会将内存表的数据备份到./workspace/uftdata/data/目录下，然后重新将表数据加载到内存表。

tip:也会将.dat文件压缩备份到workspace下（*.tar.gz）[参考链接](http://rdcdocs.hundsun.com/pages/viewpage.action?pageId=57549276)

低版本的uft每加载一张非空的内存表，都会分配300M的内存，而其中有很多小表，根本用不了300M，因此造成表空间内存浪费非常大，如`./workspace/uftdata/data/`下的表数据只有85M,但却分配了1.5G的内存

优化后的uft每次加载内存表的数据时，若发现已有内存不足，只会分配一个2M的小块，总的分配的内存为200M左右

### 查看内存

使用top命令查看mt启动后的占用内存信息：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230921093457.png" alt="20230921093457" width="850">

可以看到：虚拟内存降低了1.1G

注意：因为内存表的表数据一直是85M，虚拟内存映射到物理内存的页数量并未变化，因此mt占用的物理内存不会有明显变化

### 待优化点

- mt启动后，占用的虚拟内存过大，达到了26G，这会导致mt一旦崩溃，产生的core也会特别大;

- 其次，虚拟内存分配太大，如果超过物理内存，会将物理内存中暂未使用的内存交换到磁盘（在虚拟机中会产生很大一块交换区，在公共服务器上内存很大，交换区内存为0），降低mt性能。

