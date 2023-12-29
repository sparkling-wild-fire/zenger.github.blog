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

# clion的bash终端进程号变化问题

clion的bash终端开了一会后，输入回车老是出现^?，一查看pdi已经变化了

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231012101601.png" alt="20231012101601" width="850">

（可以看到，切换用户也会导致bash终端pid变化，也就是成为原bash终端的一个子终端）

所以会不会是centos的bash终端使用期限到了，无形中新开了一个bash导致编码问题呢？

## clion检查连接时成功，但拉不了代码

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231214171258.png" alt="20231214171258" width="850">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231214171447.png" alt="20231214171447" width="450">

推送失败: `fatal: unable to access 'https://github.com/sparkling-wild-fire/zenger.github.blog/': Failed to connect to github.com port 443 after 32150 ms: Couldn't connect to server`

手动推送：
```shell
# 首先，将本地代码提交到本地仓库：
git add .
git commit -m "提交信息"
# 然后，将本地仓库与远程仓库进行关联(第一次关联就行了)
git remote add origin 远程仓库地址
# 最后，将本地代码推送到远程仓库：
git push -u origin main
```

如果手动推也推不上，那就在终端加代理：
```shell
git config --global http.proxy http://127.0.0.1:7890
# 取消代理
git config --global --unset http.proxy
```

如果拉取失败，就手动拉取：
```shell
cd 本地仓库目录
git pull 远程仓库别名 远程仓库分支名
```

其中，远程仓库别名，可以使用 git remote -v 命令查看，如果本地仓库已经与远程仓库进行了关联，可以省略远程仓库别名和分支名