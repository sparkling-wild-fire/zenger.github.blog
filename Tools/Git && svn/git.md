# git

[浏览器可以访问github，但git拉取不了](https://blog.csdn.net/u010096608/article/details/119179550)

## 分支

- 创建分支：
   - github上在master的基础上创建一个分支company，然后拉取到本地；
   - 本地新建一个分支，然后push到远程：`git checkout -b 分支名` 或者idea创建分支
- 拉取更新：需要设置跟踪分支 =>  远程 company
- 提交推送：推到company分支，到github查询该文件，切换到main分支，文件是没更改的

[基础分支操作](https://blog.csdn.net/ding43930053/article/details/128318677)
[分支提交](https://blog.csdn.net/u011746120/article/details/128075036)

## 分支合并

命令：

```shell
# 切到主分支
git checkout main
# 拉取主分支或更新主分支
# 如果提示：fatal: no such remote or remote group: origin
# git remote add origin https://github.com/sparkling-wild-fire/zenger.github.blog/
# 然后 git checkout -b  remote -v
#如果报错：fatal: refusing to merge unrelated histories   => 加 --allow-unrelated-histories
git pull origin main --allow-unrelated-histories
# 合并本地分支
git merge company 
# 提交
git push origin main
```


clion 怎么进行分支合并啊
## HEAD

在提交树上移动
可以看到上面笔记的图中的提交分支组成了提交树，以下笔记记录如何在复杂的提交树种移动。

首先了解下HEAD，HEAD 总是指向当前分支上最近一次提交记录。大多数修改提交树的 Git 命令都是从改变 HEAD 的指向开始的。

[移动树](https://zhuanlan.zhihu.com/p/459542346)