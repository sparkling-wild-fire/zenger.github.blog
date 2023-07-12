# 小功能shell脚本

1. 回收站：~/.bashrc
```shell
# Source global definitions
if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi


# User specific aliases and functions
mkdir -p ~/.trash  #在home目录下创建一个.trash文件夹 ： 目录已存在不是会报错吗
# alias rm=del    #使用别名del代替rm =>  这种系统的命令别替换,因为程序中可能会用到rm命令
del()        #函数del，作用：将rm命令修改为mv命令
{
stamp=$(date "+%Y-%m-%d_%H:%M") # date以时间戳的形式赋值
# 这里不能用 "~/.trash/"${stamp}"_trash"，会在当前目录下新建~,被删除的文件会移动到当前目录的~目录下
# 创建子文件是方便 rm *时，方便批量恢复,同时避免同名文件覆盖
subfolder="/home/"${USER}"/.trash/"${stamp}"_trash"
mkdir -p $subfolder
mv $@ $subfolder
}

cleardel()     #函数cleardel，作用：清空回收站.trash文件夹，y或Y表示确认，n表示取消
{
read -p "clear sure[Input 'y' or 'Y' to confirm. && Input 'n' to cancel.]" confirm
[ $confirm == 'y' ] || [ $confirm == 'Y' ] && /bin/rm -rf ~/.trash/*
}

# 不要输出内容，不然Arestudio会提示上传目录不存在
# echo "Welcome to zenger's world!"
```

定时任务：crontab执行清理回收站脚本

使用：
- 将要删除的文件移入回收站：del 文件名/*
- 清空回收站：cleardel