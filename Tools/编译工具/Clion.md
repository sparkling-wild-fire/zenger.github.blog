# Clion

## 基础设置

1. 打开项目时，选择是新窗口还是本窗口：设置=>系统设置

2. CLion配置SVN，博客用的git，algoserver的用svn，分别配置。[参考链接](https://blog.csdn.net/cmhdl521/article/details/127775960)

3. 快捷键：
   - alt+shift: 多行编辑
   - ctrl+G:跳转到指定行：列  => 下次百度不到了就百度vscode的

4. [使用](https://www.jetbrains.com/zh-cn/clion/features/run-and-debug.html)

## 数据库

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20230728151755.png" alt="20230728151755" width="650" >

点了这个提交，可能还是会锁表；需要自己执行下`commit`


我又碰到这个问题了，但是点了提交，clion这个插件是可以查询到数据，但其他工具都查不到(表被clion锁了)，sql查询界面关掉再查询，也查询不到了

如果无法解锁，可以先停用数据库再刷新