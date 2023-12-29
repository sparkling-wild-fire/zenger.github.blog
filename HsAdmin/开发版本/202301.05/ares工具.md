# Ares升级

新版的ares工具将mysql和uft项目分开了，并且代码生成速度和文件查找速度得到了明显提升

## Ares UFT

[Ares UFT取包地址](https://dev.hundsun.com/frameV2/cicd/artifactOriginRDC)

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231225103639.png" alt="20231225103639" width="850">

其中，pack后缀是全量包,`external\studio\`目录下有ares工具，而插件需要从升级包中取，插件安装过程为：
[升级文档](https://iknow.hs.net/portal/docView/home/32699)

不过周华浩说不用从效能平台取全量包，用他发的就行

uft打开伪代码后，需要导入错误号文件（在全量包的`UFTDB_NEW\external\studio\uftdb_errors.xls`位置），选择合并式导入

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231225102613.png" alt="20231225102613" width="850">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231225102634.png" alt="20231225102634" width="450">

- 编译的时候如果出现未定义的`ERR_UFTDB_INVALD_ACTION`,那就是错误号文件导入错误，或者ares工具没刷新
- 如果不升级插件，ares uft项目生成的代码没有makeall文件
- 如果插件升级错误，那么生成的代码也会错误

## Ares Mysql

取包地址在ares的质保群里：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231225103002.png" alt="20231225103002" width="850">

tip: 用ares新工具的话，不兼容代码递交工具，会报一个啥java驱动问题

## 测试云平台常见问题

见下个文档