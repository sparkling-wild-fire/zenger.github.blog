# STL

## vector

底层结构：连续的扩容数组

1. 删除，利用迭代器删除一个元素后，会将后面的所有元素全部前移一个位置，原迭代器会失效，需要用erase()新返回的迭代器进行遍历


如删除vector中的偶数：

```c++
vector<int> vec{1, 2, 3, 4, 5, 7};

    for (auto it = vec.begin(); it != vec.end(); )
    {
        if (*it % 2 == 0)
        {
            it = vec.erase(it); // 删除偶数元素，并返回下一个元素的迭代器
        }
        else
        {
            ++it; // 继续遍历下一个元素
        }
    }
```

tip：
- vector元素插入：会将所有元素全部后移一个位置
- vector元素修改: 不支持直接修改元素，一般是通过元素的引用进行修改，如[]和at()都是返回元素的引用

2. 释放vector资源

- 通过swap一个空的vector容器：`vector<int>().swap(vec);`
- c++11支持shrink_to_fit释放一个vector中未使用的空间

tip: 当vector中的元素为指针时，指针元素不会调用析构函数，需要手动调用

3. vector内存分配机制

vector使用无参构造，也就是不设置vector大小，不设置vector元素，默认就是1，2，4，8...这种形势增长，

假如一开始的大小是5，那就会以5，10，20...这种形式增长


4. reverse和resize的区别

如现在有一个vector: `1,2,3,_,_,_ `；那么它的容量capacity()为6，大小size()为3

reverse
- 能够增大vector的capacity，如reverse(8),vector会变成：`1,2,3,_,_,_,_,_`
- 用来避免多次内存分配，如在一个循环中需要初始化一百个元素，可以直接reverse(100)，这样就只会扩容一次了

resize
- 能够增大vector的size和capacity，如resize(8)，vector会变成: `1,2,3,0,0,0,0,0`
- 保证访问的安全性，如我们用[]和at取元素时，可能会发生内存越界，这时我们可以先resize，就能避免core damp了

当然，reverse和resize只支持增长操作，如果参数值小于原来的容量或size，则会直接无视


## list

底层结构：双向循环链表


## deque

底层结构：map+多段线性空间实现的双端数组

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202401072231363.png" alt="202401072231363" width="850px">


## priority_queue

底层结构：堆（完全二叉树,物理上可以用数组存储，如vector,dequeue），最大堆、最小堆，只限定父子间的大小，不限制兄弟间的大小

接口：front、push_back、pop_back

## multiset

底层结构：红黑树（还有map、set、multimap、multiset），允许键值重复的有序集合

