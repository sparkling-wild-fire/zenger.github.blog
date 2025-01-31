#### buffer

##### 主要成员变量
1. buffer,一个char向量
    - kCheapPrepend预留区：一般用来解决粘包问题，消息的长度定义
    - kInitialSize数据区：为1024字节，数据区中有两根指针，一根读指针，一根写指针
        - size_t readerIndex_ 读指针
        - size_t writerIndex_ 写指针

##### 缓冲区读写

读写完数据记得将指针移动到正确的位置

1. 服务器写buff

如果buff的可写长度不够了，就需要进行扩容+len

```c++
void append(const char *data, size_t len)
{
    ensureWriteableBytes(len);
    std::copy(data, data+len, beginWrite());
    writerIndex_ += len;
}
    
// 扩容
void makeSpace(size_t len)
{
    // 如果可读区前面部分已经被读了，可以把后面的读缓冲区前移，然后写缓存区就变多了
    // 如果往前移动，写缓存区还是不够，那就只能扩容了
    if (writableBytes() + prependableBytes() < len + kCheapPrepend)
    {
        buffer_.resize(writerIndex_ + len);
    }
    else    // 把可读部分移动到最前面去（kCheapPrepend），留出空间来写
    {
        size_t readalbe = readableBytes();
        std::copy(begin() + readerIndex_, 
                begin() + writerIndex_,
                begin() + kCheapPrepend);
        readerIndex_ = kCheapPrepend;
        writerIndex_ = readerIndex_ + readalbe;
    }
}
```

2. buff写fd

```C++
ssize_t Buffer::writeFd(int fd, int* saveErrno)
{
    ssize_t n = ::write(fd, peek(), readableBytes());
    if (n < 0)
    {
        *saveErrno = errno;
    }
    return n;
}
```

3. 读fd到buff

用一块栈上的大内存来缓存fd的数据,通过readv将fd的数据读出来，然后将找上的数据写入到buff，由于此时buff的可写区域为0，则写入是会扩容`n - writable`

```c++
ssize_t Buffer::readFd(int fd, int* saveErrno)
{
    char extrabuf[65536] = {0}; // 栈上的内存空间  64K  =》 分配快，自动回收
    
    struct iovec vec[2];
    
    const size_t writable = writableBytes(); // 这是Buffer底层缓冲区剩余的可写空间大小
    vec[0].iov_base = begin() + writerIndex_;   // 第一块缓冲区
    vec[0].iov_len = writable;

    vec[1].iov_base = extrabuf;    // 第二块缓冲区    =》 扩容时再把这个缓存区的数据写buff
    vec[1].iov_len = sizeof extrabuf;
    
    const int iovcnt = (writable < sizeof extrabuf) ? 2 : 1;   // buff可写长度小于64k，写第二块缓冲区，否则写buff  => 一次最多读64k
    const ssize_t n = ::readv(fd, vec, iovcnt);  // readv函数支持多块缓存区的读写
    if (n < 0)
    {
        *saveErrno = errno;
    }
    else if (n <= writable) // Buffer的可写缓冲区已经够存储读出来的数据了
    {
        writerIndex_ += n;
    }
    else // extrabuf里面也写入了数据 
    {
        writerIndex_ = buffer_.size();
        append(extrabuf, n - writable);  // writerIndex_开始写 n - writable大小的数据
    }
    return n;
}
```


4. 服务器读缓存区的数据

```c++
// 把onMessage函数上报的Buffer数据，转成string类型的数据返回
std::string retrieveAllAsString()
{
    return retrieveAsString(readableBytes()); // 应用可读取数据的长度
}

std::string retrieveAsString(size_t len)
{
    std::string result(peek(), len);
    retrieve(len); // 上面一句把缓冲区中可读的数据，已经读取出来，这里肯定要对缓冲区进行读写索引复位操作
    return result;
}
```