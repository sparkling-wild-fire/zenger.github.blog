# svn

1. 在clion配置svn时，发现安装目录`C:\Program Files\TortoiseSVN\bin`没有svn.exe:

- [下载svn](https://tortoisesvn.net/downloads.zh.html)
- 选择modify => command line client tools

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230421151955.png" alt="20230421151955" width="450" >

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230421152105.png" alt="20230421152105" width="450" >

这样路径下就有svn.exe了

2. 递交代码前，一定要update，不然可能你的代码集成不进去

3. revert失败，提示`without reverting children` =>  原因是选择了文件夹和文件夹下的所有.cpp文件  => 不用选择文件夹

4. 服务器上没有文件夹A，然后我revert A后update，A还是在我本地
   
    总结了一下原因：在编码的过程中，修改了某个文件的代码，然后SVN会记录修改的版本，但是这个时候你又把该文件删除了，也就导致文件处于missing状态，每次你提交的时候都会出现这些missing的文件。所以我们把missing的resolve还原一下就消失了。问题也就迎刃而解了

    missing状态表示本地删除，svn服务器没有文件，然后本地svn做了记录，放心删就好了  =》 missing变成delete状态

5. svn更新覆盖我的代码 =》 https://blog.51cto.com/u_2820354/817085