# windows系统工具

# Process Explorer

作为任务管理器的enchanned版，能更好地管理windows下的进程

如这种常见的问题，知道一个文件夹被另一个进程占用，又不知道被哪个进程占用的问题：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202310141458782.png" alt="202310141458782" width="450px">

一般来说，如果是该文件夹中起了一个进程，是可以在任务管理的资源监视器中查看的，但是如果是一个系统进程占用了这个文件夹，那任务管理器就没有根据这个文件夹查看占用的进程了

这时，可以通过Process Explorer工具进程查找：点击`Find` => 输入文件夹路径

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202310141449075.png" alt="202310141449075" width="450px">

如上图，干掉3242进程就ok了：`taskkill /pid 3242`