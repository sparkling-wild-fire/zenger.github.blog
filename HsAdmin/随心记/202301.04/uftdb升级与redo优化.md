# uftdb升级

需求：当前uftdb内存表每个表初始化的内存都比较大，需要优化。升级uftdb到`202201.02.010版本`

## 升级

1. 查看uft对应的so，在appcom目录下（如果在lib目录下，一般就是要升级中间件了）

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145010.png" alt="20230717145010" width="850" >

2. 下载制品

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145305.png" alt="20230717145305" width="850" >

3. 替换so

将so替换到服务器下的appcom下

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145432.png" alt="20230717145432" width="850" >

4. 查看内存使用大小等函数

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145647.png" alt="20230717145647" width="450" >

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145745.png" alt="20230717145745" width="450" >



