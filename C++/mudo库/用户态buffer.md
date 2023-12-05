#### buffer

##### ��Ҫ��Ա����
1. buffer,һ��char����
    - kCheapPrependԤ������һ���������ճ�����⣬��Ϣ�ĳ��ȶ���
    - kInitialSize��������Ϊ1024�ֽڣ���������������ָ�룬һ����ָ�룬һ��дָ��
        - size_t readerIndex_ ��ָ��
        - size_t writerIndex_ дָ��

##### ��������д

��д�����ݼǵý�ָ���ƶ�����ȷ��λ��

1. ������дbuff

���buff�Ŀ�д���Ȳ����ˣ�����Ҫ��������+len

```c++
void append(const char *data, size_t len)
{
    ensureWriteableBytes(len);
    std::copy(data, data+len, beginWrite());
    writerIndex_ += len;
}
    
// ����
void makeSpace(size_t len)
{
    // ����ɶ���ǰ�沿���Ѿ������ˣ����԰Ѻ���Ķ�������ǰ�ƣ�Ȼ��д�������ͱ����
    // �����ǰ�ƶ���д���������ǲ������Ǿ�ֻ��������
    if (writableBytes() + prependableBytes() < len + kCheapPrepend)
    {
        buffer_.resize(writerIndex_ + len);
    }
    else    // �ѿɶ������ƶ�����ǰ��ȥ��kCheapPrepend���������ռ���д
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

2. buffдfd

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

3. ��fd��buff

��һ��ջ�ϵĴ��ڴ�������fd������,ͨ��readv��fd�����ݶ�������Ȼ�����ϵ�����д�뵽buff�����ڴ�ʱbuff�Ŀ�д����Ϊ0����д���ǻ�����`n - writable`

```c++
ssize_t Buffer::readFd(int fd, int* saveErrno)
{
    char extrabuf[65536] = {0}; // ջ�ϵ��ڴ�ռ�  64K  =�� ����죬�Զ�����
    
    struct iovec vec[2];
    
    const size_t writable = writableBytes(); // ����Buffer�ײ㻺����ʣ��Ŀ�д�ռ��С
    vec[0].iov_base = begin() + writerIndex_;   // ��һ�黺����
    vec[0].iov_len = writable;

    vec[1].iov_base = extrabuf;    // �ڶ��黺����    =�� ����ʱ�ٰ����������������дbuff
    vec[1].iov_len = sizeof extrabuf;
    
    const int iovcnt = (writable < sizeof extrabuf) ? 2 : 1;   // buff��д����С��64k��д�ڶ��黺����������дbuff  => һ������64k
    const ssize_t n = ::readv(fd, vec, iovcnt);  // readv����֧�ֶ�黺�����Ķ�д
    if (n < 0)
    {
        *saveErrno = errno;
    }
    else if (n <= writable) // Buffer�Ŀ�д�������Ѿ����洢��������������
    {
        writerIndex_ += n;
    }
    else // extrabuf����Ҳд�������� 
    {
        writerIndex_ = buffer_.size();
        append(extrabuf, n - writable);  // writerIndex_��ʼд n - writable��С������
    }
    return n;
}
```


4. ��������������������

```c++
// ��onMessage�����ϱ���Buffer���ݣ�ת��string���͵����ݷ���
std::string retrieveAllAsString()
{
    return retrieveAsString(readableBytes()); // Ӧ�ÿɶ�ȡ���ݵĳ���
}

std::string retrieveAsString(size_t len)
{
    std::string result(peek(), len);
    retrieve(len); // ����һ��ѻ������пɶ������ݣ��Ѿ���ȡ����������϶�Ҫ�Ի��������ж�д������λ����
    return result;
}
```