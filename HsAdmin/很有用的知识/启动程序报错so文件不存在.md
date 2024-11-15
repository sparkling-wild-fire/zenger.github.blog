# so文件不存在

问题：启动mt，报错：`ERROR: LOAD FUNCTION LIB [s_as_as_mc_smp_publishflow] FAILURE!!![libs_as_as_mc_smp_publishflow.so: cannot open shared object file: No such file or directory]`

## 排查

1. 检查环境变量，没问题

2. 文件权限，没问题

3. 检查依赖：`ldd /home/algotran/appcom/libs_as_as_mc_smp_publishflow.so`

报错：`ldd: warning: you do not have execution permission for /home/algotran/appcom/libs_as_as_mc_smp_publishflow.so not a dynamic executable`

这就很奇怪了，查看文件类型:`file /home/algotran/appcom/libs_as_as_mc_smp_publishflow.so`

结果为：`/home/algotran/appcom/libs_as_as_mc_smp_publishflow.so: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked, BuildID[sha1]=71e902adec08f66be8c0e053421c8b5c70d2b5bf, not stripped`

显而易见：取错包了，取了到arm架构的包




