# Clion��bash�ն���������

���ⱳ������clion���½�һ��bash�նˣ�һ��ʱ��󣬼���backup,������^?,��δ�������ݵ�ɾ��

## ����bash

�ҷ��֣���ÿ�γ�����������ʱ��bash�ն˵�pid�ƺ�����仯��Ҳ������������������ǰ����`echo $$`����鿴�ն˵�pid��91530�����91531

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231012101601.png" alt="20231012101601" width="850">

�����Կ������л��û�Ҳ�ᵼ��bash�ն�pid�仯��ԭbash�ն˻�fork��һ�����նˣ�

���Ի᲻����centos��bash�ն�ʹ�����޵��ˣ��¿���һ��bash���±��������أ�

���ǽ���ssh�ն���Լ����:

```shell
cd /etc/ssh/ssh_config
ServerAliveInterval 60
ServerAliveCountMax 3
```

���У�ServerAliveInterval��ʾ������������ʱ��������λΪ�룻ServerAliveCountMax��ʾ������Դ������������ú�SSH�ͻ��˻�ÿ��60�뷢��һ�����������������3��û���յ�����������Ӧ���ͻ��Զ��Ͽ����ӣ�������Ϊ�ն˵��ڵ���PID�仯�����⡣

## ��backup��(���ս������)

��ϧ�����������ֳ����ˣ���bash�ն˵�pid��û�б仯

ͨ��`stty -a`����鿴��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20231012142809.png" alt="20231012142809" width="850">

backup����earse����Ӧ��^?��, ������ȴ��ɰ�^H�ˣ�����Ϊʲô��������ת�䣬Ŀǰԭ����δ֪�����͵���clion��һ��bug�ɣ�

����취��`stty erase ^?`�������� ^? �� backup���İ󶨹�ϵ��

��Ҫ��~/.bashrc����������`stty erase '^?'`����Ϊ���ô����ϴ�����ʱ����source ~/.bashrc��������

`stty: standard input: Inappropriate ioctl for device `

������������,��`stty erase '^?'`������Ϊ`er`,�Ժ����������`er`����

����֣�������mt��ʱ�򣬻Ὣ erase ����Ϊ ^H, ������runalgo_mt�ű������Ӹ�`er`�������