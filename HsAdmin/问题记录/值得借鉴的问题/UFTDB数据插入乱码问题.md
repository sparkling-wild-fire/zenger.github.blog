# UFTDB数据插入乱码问题

问题现象：我修改了内存表（其实就是个结构体）的表tstp_gspayment结构，增加了一个字段并修改了内存表的字段顺序，然后全编UFT模块，结果插入任何数据都乱码了（即使全是数字）

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240909153035.png" alt="20240909153035" width="850">

调试后，发现数据正常，但是在调用插入函数后，HSSQL的数据就乱了

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/206bac1747a92a7bf0413235830f10a2.png" alt="206bac1747a92a7bf0413235830f10a2" width="850">

由于我修改了表字段顺序，就检查了下STPUFT_datamgr模块和fix_income中tstp_gspayment结构体，发现二者的定义不一样：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/f09f9694935ae57bd326d7a7ec4f58cf.png" alt="f09f9694935ae57bd326d7a7ec4f58cf" width="850">

libs_uft_STPUFT_datmgr.so中的tstp_gspayment结构体并没有更新，但我是将UFT代码全编的，服务器上的代码这个结构体确实被调整了，问题原因应该是
`UFT代码并发编译之前，.o文件没有删，然后 libs_uft_STPUFT_datamgr.so 里面用了旧的 .o 文件`

所以makeall前先要make clean下，问题解决