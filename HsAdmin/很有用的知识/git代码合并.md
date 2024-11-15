# 代码合并

## 脚本合并

### 文件名不同进行合并 

如OT的04版本合并到QT的01版本sql文件  

1. 先用clion进行merger，查看文件名不同的文件（从下图可以看到，文件都只是该了版本名）
2. 先把原分支的代码备份，然后becompare

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240701142527.png" alt="20240701142527" width="850">

注意：
1. OT的升级脚本一部分在QT的安装脚本里
2. 别人删除的代码别给加回来了
3. 虽然`交易所债券做市`相关行sql改了，但是直接覆盖OT的sql，也是OK的
4. 最终，我将OT的DML升级脚本全部覆盖过来了，会有其他问题吗！！！没想出来会有啥问题 => ALGOV202401.02.000_DML.sql
5. mysql的历史脚本DDL，指令明细表新增cashgroup_prop cashgroup_no本来就是从QT搞过来的，现在又放到历史脚本DDL里去了
6. `T202303096664`这个修改但，安装脚本和升级脚本都有，不过应该不影响执行，DML（安装，升级也有类似的问题）
7. 为啥最下面的版本还是01版本啊


<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240701152109.png" alt="20240701152109" width="850">


## mysql

像这种两边都改了同一段逻辑的地方，我就不太好合，这里还算好一点，QT只是改了个数字，大概率不会出问题。

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240701195417.png" alt="20240701195417" width="850">

有个人的代码不能合到QT,所以需要以OT的为准

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240702094422.png" alt="20240702094422" width="850">


升级脚本注意更新版本号：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240709161053.png" alt="20240709161053" width="850">

## 遇到的问题：

`GIT邮箱账号配置错误的有：zgdeastravajx@163.com,339387784@qq.com，请使用正确邮箱账号配置后再递交！`


<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240709171049.png" alt="20240709171049" width="850">
