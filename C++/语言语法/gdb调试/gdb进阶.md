# gdb进阶

## 观察点

观察点的相关命令：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152240312.png" alt="202306152240312" width="450px">

- 如写观察点：`watch gdata`,当执行`gdata=1`等命令时，就会触发该观察点，停下来。

- 观察点分为硬件观察点和软件观察点（执行很慢，很影响性能），现在一般的操作系统都是硬件观察点

- 加入有两个子线程，我们只想为其中一个线程设置观察点，可通过
`watch gdata thread 3`实现，

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152248765.png" alt="202306152248765" width="450px">

- 条件观察点：
`watch gdata1+gdata2>10`,只要线程的这两个值相加大于0，就会停下来

## 捕获点

在代码中，我们经常会使用try catch throw来捕捉异常，如文件确实，内存不足等，捕获点就是帮助我们捕捉类似的bug，它是一个特殊的断点，命令为：
`catch event`,即当捕获到event这个事件时，程序就会停止下来

为什么断点代替不了捕获点，因为在大型项目中，try catch这样的代码非常多，我们不可能打那么多断点，我们只要设置一个捕获点，捕获到异常就行，而不用管是哪里抛出的异常。

1. 捕获点调试案例:

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152302610.png" alt="202306152302610" width="450px">

从上可发现，是因为入参传了个0，导致抛出异常。至此，我们还可以继续切换到2号帧查看为什么会传个0过来...

注意：捕获点是捕获的事件，而不仅仅是异常。如 catch catch、catch throw，那么产生一个异常时，会中断两次

2. 捕获系统调用

通过
`catch syscall 系统函数/系统号`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152310723.png" alt="202306152310723" width="450px">

以close函数为例，在程序启动时，操作系统可能会进行一些close（不是我们代码中的close）的操作，导致我们捕获到了很多无用的事件，
这时候可以先在我们的close函数前打个断点，等程序执行到这个断点时，再去捕获系统事件。

3. 常用的捕捉事件

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306152315407.png" alt="202306152315407" width="450px">
 