# uftdb升级

需求：当前uftdb内存表每个表初始化的内存都比较大，需要优化。升级uftdb到`202201.02.010版本`

## 升级

1. 查看uft对应的so，在appcom目录下（如果在lib目录下，一般就是要升级中间件了）

[中间件升级](http://rdcdocs.hundsun.com/pages/viewpage.action?pageId=57553605)

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145010.png" alt="20230717145010" width="850" >

2. 下载制品

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145305.png" alt="20230717145305" width="850" >

3. 替换so

将so替换到服务器下的appcom下（升级时需要和研发中心确认下，不同版本的uft升级可能需要更新其他文件）

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145432.png" alt="20230717145432" width="850" >

4. 查看内存使用大小，这些函数可以在下载制品的pdf中查找

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717150431.png" alt="20230717150431" width="450" ><br>
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145647.png" alt="20230717145647" width="450" ><br>
<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230717145745.png" alt="20230717145745" width="450" >


