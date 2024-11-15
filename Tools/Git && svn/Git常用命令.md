# Git常用命令

获取某次提交的文件列表：`git log` + `git diff --name-only aa8d41cc74f89e93eda2063e75afbb9dd9805c12`

版本回退：`git reset --hard commitId`,记录先把本地的提交了或者备份，不然会被清空，回退之后，commitId就变成回退的commitId了

`git reflog`：可以查看已经删除的commit记录和reset记录

让git不去管理某些文件：`touch .gitignore` 写入 `*.zip`

解决冲突：
```shell
# 确定冲突的地方要保留的内容
git add .
git commit -m ""
```

查看远程仓库: `git remote`


clion集成git：

几条铁令：

1. 切分支、reset前一直要先提交代码，提交了就能找回来


终端bash可以将shell path设置成Git\bin\bash.exe

