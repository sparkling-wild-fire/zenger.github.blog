# Clion中bash终端乱码问题

问题背景：在clion中新建一个bash终端，一段时间后，键入backup,输入变成^?,并未进行内容的删除

## 防切bash

我发现，在每次出现上述问题时，bash终端的pid似乎都会变化，也就是在这个问题产生的前后，用`echo $$`命令查看终端的pid从91530变成了91531

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231012101601.png" alt="20231012101601" width="850">

（可以看到，切换用户也会导致bash终端pid变化，原bash终端会fork出一个子终端）

所以会不会是centos的bash终端使用期限到了，新开了一个bash导致编码问题呢？

于是进行ssh终端续约设置:

```shell
cd /etc/ssh/ssh_config
ServerAliveInterval 60
ServerAliveCountMax 3
```

其中，ServerAliveInterval表示发送心跳包的时间间隔，单位为秒；ServerAliveCountMax表示最大重试次数。这样设置后，SSH客户端会每隔60秒发送一个心跳包，如果连续3次没有收到服务器的响应，就会自动断开连接，避免因为终端到期导致PID变化的问题。

## 绑定backup键(最终解决方案)

可惜，乱码问题又出现了，而bash终端的pid并没有变化

通过`stty -a`命令查看：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231012142809.png" alt="20231012142809" width="850">

backup键（earse）本应绑定^?的, 而现在却变成绑定^H了，至于为什么会有这种转变，目前原因暂未知晓（就当是clion的一个bug吧）

解决办法：`stty erase ^?`命令修正 ^? 和 backup键的绑定关系。

不要在~/.bashrc中设置命令`stty erase '^?'`，因为你用代码上传工具时，会source ~/.bashrc，报错误：

`stty: standard input: Inappropriate ioctl for device `

可以新增函数,给`stty erase '^?'`重命名为`er`,以后乱码输入个`er`就行

最后发现：在启动mt的时候，会将 erase 更改为 ^H, 所以在runalgo_mt脚本的最后加个`er`命令就行