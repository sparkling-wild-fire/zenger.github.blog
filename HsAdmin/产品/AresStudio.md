# AresStudio

1. 适配文件映射：`DEFAULT\functions\database\algo_correlationfunc.xml`

2. 打印包体：LogFlow(lpAnswer->UnPack()) 
手工打包的包体，都要结果集返回

3. 包体的函数：`D:\vscode\AlgoServer\Sources\Include\pack_interface.h`   => 不要找错了,Go，last这些函数都在这里，之前找错了文件，还以为没有这些函数
   - GetStr()等函数路径：`D:\vscode\AlgoServer\Sources\Include\jsonpackex_interface.h`
   - 智能指针：F:\Algoserver\Sources\src\algo_public\auto_ptr.h

4. dd
```text
记录的最后一行：!lpResultSet440276915->IsEOF() 
指针：lpResultSet440276915!=NULL 为true
获取行数：GetRowCount
```

5. uft的入参不支持IO吗，出参和入参名可以一样，且入参自动作为出参

