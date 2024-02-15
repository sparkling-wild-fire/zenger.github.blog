# 利用libcurl库多线程文件下载

可以当作自己的一个小小下载器

## linux环境准备

1. 在项目目录下新建:
    - build 目录： 用来编译
    - src目录：用来编写源码（本例比较简单，就没建了）
2. 在build目录下新建CMakeLists.txt，写入以下内容

```shell
cmake_minimum_required(VERSION 3.3)
project(ThreadDownLoad)

set(CMAKE_CXX_STANDARD 14)

# 添加头文件路径
include_directories("/usr/local/curl/include")
# 添加动态库路径
link_directories(/usr/local/curl/lib/ /usr/lib64)

# 添加可执行文件
add_executable(ThreadDownLoad ../main.cpp)

# 链接动态库
## tip2:
## 将CURL库链接到项目中,要写在可知执行文件生成后
## tip3:
## 上面设置了动态库路径，这里要写具体链接哪些动态库
target_link_libraries(ThreadDownLoad curl pthread)
```

3. Cmake生成Makefile等文件
```shell
Cmake . -B ./build 
```
4. 完成main.cpp，进行make

注意可执行文件设置，因为需要在构建目录下make，可执行文件要填相对构建目录的路径

## 多线程文件下载

实现功能：
- 网络文件下载：libcurl库，设置文件写入函数，以及下载进度回调函数
- 多文件下载：先获取服务器文件大小，将文件分段平均分配给子线程下载
    - 慎用mmap，虽然它能较少磁盘IO,但是它只能进行整个文件的映射，可能会造成内存不足
- 断点续传：注册信号（如中断信号），信号发生时，将子线程的下载range存入文件

### 文件下载方式

1. mmap内存映射
    - 先向服务器发送请求，获取文件大小fileLen，创建文件，将其指针移动到fileLen，写入数据1
    - 类似迅雷下载预先分配大小）,将其mmap映射到内存，然后再发请求进行下载
2. fwrite直接写文件

这里选择第二种

mmap实现内存映射原理：
1. 调用mmap函数时，系统会为这个文件在进程的地址空间中分配一块虚拟内存区域，这个区域的大小通常是文件大小的整数倍。
2. 系统会将文件的内容读入内存中，并将这个虚拟内存区域与文件建立映射关系，使得进程可以通过对这个虚拟内存区域的访问来访问文件的内容。
3. 进程对这个虚拟内存区域的访问会被转换为对文件的读写操作，这些操作会被操作系统自动同步到磁盘上，从而保证文件内容的一致性。
4. 当进程不再需要这个虚拟内存区域时，可以调用munmap函数来释放这个区域，这个区域的内容也会被自动同步到磁盘上。

mmap实现进程贡献原理：（mmap不是在进程内分配虚拟内存吗，怎么实现进程的共享内存呢？）
1. 使用共享文件：进程A和进程B都打开同一个文件，并使用mmap将这个文件映射到自己的虚拟内存中。这样，进程A和进程B就可以通过对这个虚拟内存区域的访问来实现共享内存。当一个进程修改了这个虚拟内存区域的内容时，操作系统会自动同步到磁盘上，从而保证数据的一致性。
2. 使用匿名映射：进程A和进程B都使用mmap函数创建一个匿名映射区域，并将这个区域映射到自己的虚拟内存中。这样，进程A和进程B就可以通过对这个虚拟内存区域的访问来实现共享内存。当一个进程修改了这个虚拟内存区域的内容时，操作系统会自动同步到物理内存中，从而保证数据的一致性。

加锁控制：
1. 无论是使用共享文件还是匿名映射，进程间共享内存的原理都是一样的，即通过将同一个物理内存区域映射到多个进程的虚拟内存中来实现共享。 =》 核心原理
2. 由于多个进程可以同时访问这个物理内存区域，因此需要使用同步机制来保证数据的一致性。常用的同步机制包括信号量、互斥锁、读写锁等。


### 多线程下载

首先，开启10个（根据文件大小和机器性能确定）线程，然后为每个子线程创建一个`fileInfo实例`，构成一个fileInfo指针数组传给每个线程（方便子线程打印下载进度）

```c++
struct fileInfo {
    const char *url;   // 服务器下载路径
    char *fileptr;     // 共享内存指针
    int offset; //  start
    int end;   // end
    pthread_t thid;
    double download; // 当前线程下载量
    double totalDownload;  // 所有线程总下载量
    FILE *recordfile;     // 文件句柄
};
```

开启线程下载：

```c++
int download(const char *url, const char *filename) {
    // 1. 先向服务器发送请求，获取文件大小，创建本地文件（迅雷下载预先分配大小），然后再发一次请求进行下载
    // 文件下载两种思路：fwrite直接写文件；预先创建文件通过mmap内存映射；这里选第二种
    long fileLength = getDownloadFileLength(url);
    printf("downloadFileLength: %ld\n", fileLength);

    // write
    int fd = open(filename, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR); //
    if (fd == -1) {
        return -1;
    }
    // 移动文件指针，使得预创建的文件和服务器的文件一样大（在最后写一个1）
    if (-1 == lseek(fd, fileLength-1, SEEK_SET)) {
        perror("lseek");
        close(fd);
        return -1;
    }
    if (1 != write(fd, "", 1)) {
        perror("write");
        close(fd);
        return -1;
    }
    
    // 2. 将文件映射到内存
    char *fileptr = (char *)mmap(NULL, fileLength, PROT_READ| PROT_WRITE, MAP_SHARED, fd, 0);
    if (fileptr == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return -1;
    }
    FILE *fp = fopen("a.txt", "r");

    // thread arg
    int i = 0;
    long partSize = fileLength / THREAD_NUM;
    struct fileInfo *info[THREAD_NUM+1] = {NULL};

    // 3.创建多个线程，每个线程一个文件下载器
    for (i = 0;i <= THREAD_NUM;i ++) {

        info[i] = (struct fileInfo*)malloc(sizeof(struct fileInfo));
        memset(info[i], 0, sizeof(struct fileInfo));

        // 多个线程将文件分块下载
        info[i]->offset = i * partSize;
        if (i < THREAD_NUM) {
            info[i]->end = (i+1) * partSize - 1;
        } else {
            info[i]->end = fileLength - 1;
        }
        info[i]->fileptr = fileptr;   // 内存映射（多线程共享内存）
        info[i]->url = url;
        info[i]->download = 0;
        info[i]->recordfile = fp;
    }
    pInfoTable = info;

    //pthread_t thid[THREAD_NUM+1] = {0};
    for (i = 0;i <= THREAD_NUM;i ++) {
        pthread_create(&(info[i]->thid), NULL, worker, info[i]);  // 将要传给worker的文件信息封装成一个结构体
        usleep(1);
    }
    // 等到子线程都退出，子线程才退出
    for (i = 0;i <= THREAD_NUM;i ++) {
        pthread_join(info[i]->thid, NULL);
    }
    // 释放资源
    for (i = 0;i <= THREAD_NUM;i ++) {
        free(info[i]);
    }
    if (fp)
        fclose(fp);
    munmap(fileptr, fileLength);
    close(fd);
    return 0;
}
```

### 子线程利用curl库下载

子线程实现逻辑: 文件写入回调与进度回调

```c++
void *worker(void *arg) {

    struct fileInfo *info = (struct fileInfo*)arg;

    char range[64] = {0};

    // mutex_lock
    if (info->recordfile) {
        // 用于断点续传，从文件中读取range
        fscanf(info->recordfile, "%d-%d", &info->offset, &info->end);
    }
    // mutex_unlock
    if (info->offset > info->end) return NULL;

    snprintf(range, 64, "%d-%d", info->offset, info->end);

    CURL *curl = curl_easy_init();
    curl_easy_setopt(curl, CURLOPT_URL, info->url); // url
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeFunc); // 文件下载函数，libcurl在写入时执行
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, info);          // 写入回调传参
    curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L); // progress  =》 没有下载进度为0
    curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progressFunc);   // 回调函数：libcurl发起请求时调用
    curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, info);         // 进度回调函数传参
    curl_easy_setopt(curl, CURLOPT_RANGE, range);  // 控制从服务器文件的下载范围
    // http range
    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        printf("res %d\n", res);
    }
    curl_easy_cleanup(curl);

    return NULL;
}
```

文件写入：将服务器传回的n块文件写入共享内存,这里不需要加锁，每个进程写入的共享内存地址不一样

```c++
// 写入回调：ptr 参数是接收到的数据的指针；size 参数是每个数据块的大小；memb 参数是数据块的数量
size_t writeFunc(void *ptr, size_t size, size_t memb, void *userdata) {

    struct fileInfo *info = (struct fileInfo *)userdata;
    printf("writeFunc\n");

    memcpy(info->fileptr + info->offset, ptr, size * memb);
    info->offset += size * memb;

    return size * memb;
}
```

进度回调：子进程打印文件的当前下载进度
```c++
// 进度回调
int progressFunc(void *userdata, double totalDownload, double nowDownload, double totalUpload, double nowUpload) {
    printf("progressFunc\n");
    int percent = 0;
    static int print = 1;
    struct fileInfo *info = (struct fileInfo*)userdata;
    info->download = nowDownload;
    info->totalDownload = totalDownload;
    // save

    if (totalDownload > 0) {

        int i = 0;
        double allDownload = 0;
        double total = 0;

        for (i = 0;i <= THREAD_NUM;i ++) {
            allDownload += pInfoTable[i]->download;
            total += pInfoTable[i]->totalDownload;
        }

        percent = (int)(allDownload / total * 100);
    }

    if (percent == print) {
        printf("threadid: %ld, percent: %d%%\n", info->thid, percent);
        print += 1;
    }

    return 0;
}
```

### 断点续传

注册一个信号（如中断信号），当信号发生时，在文件中记录每个线程的下一次下载range,下一次子线程下载时，下载文件中的range部分即可

```c++
// 当收到中断信号后，记录每个线程的下载进度
void signal_handler(int signum) {

    printf("signum: %d\n", signum);

    int fd = open("a.txt",  O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
    if (fd == -1) {
        exit(1);
    }

    int i = 0;
    for (i = 0;i <= THREAD_NUM;i ++) {
        char range[64] = {0};
        snprintf(range, 64, "%d-%d\r\n", pInfoTable[i]->offset, pInfoTable[i]->end);
        write(fd, range, strlen(range));
    }
    close(fd);
    exit(1);
}
```

## 源码

```c++

// gcc -o multi_download multi_download.c -lcurl

#include <stdio.h>
#include <unistd.h>
#include <curl/curl.h>
#include <fcntl.h>
// 需要在linux上使用
#include <sys/mman.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <signal.h>

// fork();

struct fileInfo {
    const char *url;   // 服务器下载路径
    char *fileptr;     // 共享内存指针
    int offset; //  start
    int end;   // end
    pthread_t thid;
    double download; // 当前线程下载量
    double totalDownload;  // 所有线程总下载量
    FILE *recordfile;     // 文件句柄
};

#define THREAD_NUM		10

struct fileInfo **pInfoTable;   // 二级指针=>指针数组
double downloadFileLength = 0;

// 写入回调：ptr 参数是接收到的数据的指针；size 参数是每个数据块的大小；memb 参数是数据块的数量
size_t writeFunc(void *ptr, size_t size, size_t memb, void *userdata) {

    struct fileInfo *info = (struct fileInfo *)userdata;
    printf("writeFunc\n");

    memcpy(info->fileptr + info->offset, ptr, size * memb);
    info->offset += size * memb;

    return size * memb;
}

// 进度回调
int progressFunc(void *userdata, double totalDownload, double nowDownload, double totalUpload, double nowUpload) {
    printf("progressFunc\n");
    int percent = 0;
    static int print = 1;
    struct fileInfo *info = (struct fileInfo*)userdata;
    info->download = nowDownload;
    info->totalDownload = totalDownload;
    // save

    if (totalDownload > 0) {

        int i = 0;
        double allDownload = 0;
        double total = 0;

        for (i = 0;i <= THREAD_NUM;i ++) {
            allDownload += pInfoTable[i]->download;
            total += pInfoTable[i]->totalDownload;
        }

        percent = (int)(allDownload / total * 100);
    }

    if (percent == print) {
        printf("threadid: %ld, percent: %d%%\n", info->thid, percent);
        print += 1;
    }

    return 0;
}

//
double getDownloadFileLength(const char *url) {

    CURL *curl = curl_easy_init();

    printf("url: %s\n", url);
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36");
    curl_easy_setopt(curl, CURLOPT_HEADER, 1);
    curl_easy_setopt(curl, CURLOPT_NOBODY, 1);

    CURLcode res = curl_easy_perform(curl);
    if (res == CURLE_OK) {
        printf("downloadFileLength success\n");
        curl_easy_getinfo(curl, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &downloadFileLength);
    } else {
        printf("downloadFileLength error\n");
        downloadFileLength = -1;
    }
    curl_easy_cleanup(curl);

    return downloadFileLength;
}

int recordnum = 0;

void *worker(void *arg) {

    struct fileInfo *info = (struct fileInfo*)arg;

    char range[64] = {0};

    // mutex_lock
    if (info->recordfile) {
        // 用于断点续传，从文件中读取range
        fscanf(info->recordfile, "%d-%d", &info->offset, &info->end);
    }
    // mutex_unlock
    if (info->offset > info->end) return NULL;

    snprintf(range, 64, "%d-%d", info->offset, info->end);

    CURL *curl = curl_easy_init();
    curl_easy_setopt(curl, CURLOPT_URL, info->url); // url
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeFunc); // 文件下载函数，libcurl在写入时执行
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, info);          // 写入回调传参
    curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L); // progress  =》 没有下载进度为0
    curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progressFunc);   // 回调函数：libcurl发起请求时调用
    curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, info);         // 进度回调函数传参
    curl_easy_setopt(curl, CURLOPT_RANGE, range);  // 控制从服务器文件的下载范围
    // http range
    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        printf("res %d\n", res);
    }
    curl_easy_cleanup(curl);

    return NULL;
}


// https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso.zsync
// ubuntu.zsync.backup
int download(const char *url, const char *filename) {
    // 1. 先向服务器发送请求，获取文件大小，创建本地文件（迅雷下载预先分配大小），然后再发一次请求进行下载
    // 文件下载两种思路：fwrite直接写文件；预先创建文件通过mmap内存映射；这里选第二种
    long fileLength = getDownloadFileLength(url);
    printf("downloadFileLength: %ld\n", fileLength);

    // write
    int fd = open(filename, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR); //
    if (fd == -1) {
        return -1;
    }
    // 移动文件指针，使得预创建的文件和服务器的文件一样大（在最后写一个1）
    if (-1 == lseek(fd, fileLength-1, SEEK_SET)) {
        perror("lseek");
        close(fd);
        return -1;
    }
    if (1 != write(fd, "", 1)) {
        perror("write");
        close(fd);
        return -1;
    }

    // 2. 将文件映射到内存
    char *fileptr = (char *)mmap(NULL, fileLength, PROT_READ| PROT_WRITE, MAP_SHARED, fd, 0);
    if (fileptr == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return -1;
    }
    FILE *fp = fopen("a.txt", "r");

    // thread arg
    int i = 0;
    long partSize = fileLength / THREAD_NUM;
    struct fileInfo *info[THREAD_NUM+1] = {NULL};

    // 3.创建多个线程，每个线程一个文件下载器
    for (i = 0;i <= THREAD_NUM;i ++) {

        info[i] = (struct fileInfo*)malloc(sizeof(struct fileInfo));
        memset(info[i], 0, sizeof(struct fileInfo));

        // 多个线程将文件分块下载
        info[i]->offset = i * partSize;
        if (i < THREAD_NUM) {
            info[i]->end = (i+1) * partSize - 1;
        } else {
            info[i]->end = fileLength - 1;
        }
        info[i]->fileptr = fileptr;   // 内存映射（多线程共享内存）
        info[i]->url = url;
        info[i]->download = 0;
        info[i]->recordfile = fp;
    }
    pInfoTable = info;

    //pthread_t thid[THREAD_NUM+1] = {0};
    for (i = 0;i <= THREAD_NUM;i ++) {
        pthread_create(&(info[i]->thid), NULL, worker, info[i]);  // 将要传给worker的文件信息封装成一个结构体
        usleep(1);
    }
    // 等到子线程都退出，子线程才退出
    for (i = 0;i <= THREAD_NUM;i ++) {
        pthread_join(info[i]->thid, NULL);
    }
    // 释放资源
    for (i = 0;i <= THREAD_NUM;i ++) {
        free(info[i]);
    }

    if (fp)
        fclose(fp);

    munmap(fileptr, fileLength);
    close(fd);
    return 0;
}

// 当收到中断信号后，记录每个线程的下载进度
void signal_handler(int signum) {

    printf("signum: %d\n", signum);

    int fd = open("a.txt",  O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
    if (fd == -1) {
        exit(1);
    }

    int i = 0;
    for (i = 0;i <= THREAD_NUM;i ++) {
        char range[64] = {0};
        snprintf(range, 64, "%d-%d\r\n", pInfoTable[i]->offset, pInfoTable[i]->end);
        write(fd, range, strlen(range));
    }
    close(fd);
    exit(1);
}

//
#if 1
// 2G:  ./ThreadDownLoad https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso ubuntu.zenger
// 11M: ./ThreadDownLoad https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso.zsync ubuntu.zenger
int main(int argc, const char *argv[]) {
    if (argc != 3) {
        printf("arg error\n");
        return -1;
    }

    if (SIG_ERR == signal(SIGINT, signal_handler)) {
        perror("signal");
        return -1;
    }

    return download(argv[1], argv[2]);

}
#endif
```