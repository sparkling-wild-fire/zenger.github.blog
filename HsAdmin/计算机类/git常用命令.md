# git常用命令

如果需要将一个文件同步到另一个文件（如Otrade改了某一个文件，现在要同步到另一个文件）：

```shell
git checkout origin/dev-ALGOV202301.02.000.LS -- ./algo_mysql/logic/scheme_mgr/quant_schemehandle/LS_LHTOOLS_SCHEMESUB_INFO_MNG.logicservice
```

如果需要将某分支A的一次提交同步到另一个分支B：
```shell
# 1.在分支A上查看这次提交的hashid
# 2.切换到目标分支
# 3.执行命令 
git cherry-pick <commit-hash>
# 如：git cherry-pick 4aae810bd2c417a1f05f1f57ba70a73ef3ece7bf
# 4.cherry-pick过程如果有冲突，先解决冲突，然后
git add <resolved-files>
git cherry-pick --continue
# 5. 如果cherry-pick成功，提交就会被复制到当前分支
# tip: 这个过程可以修改提交信息，如果想要后续修改，也可以先回退再次提交 git reset --soft HEAD~123456...
```

如果cherry-pick过程出现问题：`fatal: unknown write failure on standard output`

用IDE要打开git bash而不是普通的bash
