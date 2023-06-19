# valgrind

## ��װ��ʹ��

1. ��װ��`yum install valgrin`
2. ���У�`valgrind --tool=toolname args-val program args-pro`
   - �����У��������õ����`valgrind --log-file=valgrind.log --tool=memcheck --leak-check=full \ 
                          --show-leak-kinds=all ./your_app arg1 arg2`

����:
`--log-file` �����ļ��������û��ָ���������stderr�� 
`--tool=memcheck` ָ��Valgrindʹ�õĹ��ߡ�Valgrind��һ�����߼�������Memcheck��Cachegrind��Callgrind�ȶ�����ߡ�
memcheck��ȱʡ� 
`--leak-check` ָ����α����ڴ�й©��memcheck�ܼ������ڴ�ʹ�ô����ڴ�й©�����г�����һ�֣�����ѡֵ��:
  - no ������
  - summary ��ʾ��Ҫ��Ϣ���ж��ٸ��ڴ�й©��summary��ȱʡֵ��
  - yes �� full ��ʾÿ��й©���ڴ���������䡣
  - show-leak-kinds ָ����ʾ�ڴ�й©�����͵���ϡ����Ͱ���definite, indirect, possible,reachable��Ҳ����ָ��all��none��
  ȱʡֵ��definite,possible�� ����һ��ʱ�����ֹͣ���̲�Ҫkill������Ҫctrl + c�������������log�������������е�
  valgrind.log�С�


�ù��߿��Լ���������ڴ���ص�����:
  - δ�ͷ��ڴ��ʹ��
    - ���ͷź��ڴ�Ķ�/д
        - ���ѷ����ڴ��β���Ķ�/д
  - �ڴ�й¶
  - ��ƥ���ʹ��malloc/new/new[] �� free/delete/delete[]
  - �ظ��ͷ��ڴ�


## ��ʹ��

[�ο�����](https://zhuanlan.zhihu.com/p/92074597)

���μ򵥵Ĵ��룺
```C++
#include <stdlib.h>

void f(void){
    int* x =(int*)malloc(10 * sizeof(int));
    x[10] = 0;         // problem 1: heap block overrun
}                    // problem 2: memory leak -- x not freed

int main(void){
    f();
    return 0;
}
```

���룺`gcc -g -o a.out a.cpp`
��⣺`valgrind --leak-check=yes ./a.out`

valgrind���Ϊ��
```txt
==253== Memcheck, a memory error detector
==253== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==253== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==253== Command: ./a.out
==253==
==253== Invalid write of size 4       
==253==    at 0x40054E: f() (a.cpp:6)
==253==    by 0x40055E: main (a.cpp:11)
==253==  Address 0x5205068 is 0 bytes after a block of size 40 alloc'd  # 2.�ڴ�Խ�磬x[10]д����ʧ��
==253==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==253==    by 0x400541: f() (a.cpp:5)
==253==    by 0x40055E: main (a.cpp:11)
==253==
==253==
==253== HEAP SUMMARY:
==253==     in use at exit: 40 bytes in 1 blocks
==253==   total heap usage: 1 allocs, 0 frees, 40 bytes allocated
==253==
==253== 40 bytes in 1 blocks are definitely lost in loss record 1 of 1
==253==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==253==    by 0x400541: f() (a.cpp:5)       # 1.�����Ǻ�������ջ����Ҫ���µ���׷��
==253==    by 0x40055E: main (a.cpp:11)   
==253==
==253== LEAK SUMMARY:
==253==    definitely lost: 40 bytes in 1 blocks
==253==    indirectly lost: 0 bytes in 0 blocks
==253==      possibly lost: 0 bytes in 0 blocks
==253==    still reachable: 0 bytes in 0 blocks
==253==         suppressed: 0 bytes in 0 blocks
==253==
==253== For lists of detected and suppressed errors, rerun with: -s
==253== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)
```

���У�==253==�е�����Ϊ���̺ţ�һ�㲻�ÿ���

## ԭ��

valgrind ������߲������ڵ����������еĳ�����Ϊ�������ĳ�����������ĺϳ�CPU�ϲ������С�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202306191950919.png" alt="202306191950919" width="450px">

[MemCheck����ԭ��](https://zhuanlan.zhihu.com/p/510362477)���ص�֪��ʹ��valgrind�ڴ�ʹ���ʻ��ռ��25%����

## ����






