# ����libcurl����߳��ļ�����

���Ե����Լ���һ��СС������

## linux����׼��

1. ����ĿĿ¼���½�:
    - build Ŀ¼�� ��������
    - srcĿ¼��������дԴ�루�����Ƚϼ򵥣���û���ˣ�
2. ��buildĿ¼���½�CMakeLists.txt��д����������

```shell
cmake_minimum_required(VERSION 3.3)
project(ThreadDownLoad)

set(CMAKE_CXX_STANDARD 14)

# ���ͷ�ļ�·��
include_directories("/usr/local/curl/include")
# ��Ӷ�̬��·��
link_directories(/usr/local/curl/lib/ /usr/lib64)

# ��ӿ�ִ���ļ�
add_executable(ThreadDownLoad ../main.cpp)

# ���Ӷ�̬��
## tip2:
## ��CURL�����ӵ���Ŀ��,Ҫд�ڿ�ִ֪���ļ����ɺ�
## tip3:
## ���������˶�̬��·��������Ҫд����������Щ��̬��
target_link_libraries(ThreadDownLoad curl pthread)
```

3. Cmake����Makefile���ļ�
```shell
Cmake . -B ./build 
```
4. ���main.cpp������make

ע���ִ���ļ����ã���Ϊ��Ҫ�ڹ���Ŀ¼��make����ִ���ļ�Ҫ����Թ���Ŀ¼��·��

## ���߳��ļ�����

ʵ�ֹ��ܣ�
- �����ļ����أ�libcurl�⣬�����ļ�д�뺯�����Լ����ؽ��Ȼص�����
- ���ļ����أ��Ȼ�ȡ�������ļ���С�����ļ��ֶ�ƽ����������߳�����
    - ����mmap����Ȼ���ܽ��ٴ���IO,������ֻ�ܽ��������ļ���ӳ�䣬���ܻ�����ڴ治��
- �ϵ�������ע���źţ����ж��źţ����źŷ���ʱ�������̵߳�����range�����ļ�

### �ļ����ط�ʽ

1. mmap�ڴ�ӳ��
    - ����������������󣬻�ȡ�ļ���СfileLen�������ļ�������ָ���ƶ���fileLen��д������1
    - ����Ѹ������Ԥ�ȷ����С��,����mmapӳ�䵽�ڴ棬Ȼ���ٷ������������
2. fwriteֱ��д�ļ�

����ѡ��ڶ���

mmapʵ���ڴ�ӳ��ԭ��
1. ����mmap����ʱ��ϵͳ��Ϊ����ļ��ڽ��̵ĵ�ַ�ռ��з���һ�������ڴ������������Ĵ�Сͨ�����ļ���С����������
2. ϵͳ�Ὣ�ļ������ݶ����ڴ��У�������������ڴ��������ļ�����ӳ���ϵ��ʹ�ý��̿���ͨ������������ڴ�����ķ����������ļ������ݡ�
3. ���̶���������ڴ�����ķ��ʻᱻת��Ϊ���ļ��Ķ�д��������Щ�����ᱻ����ϵͳ�Զ�ͬ���������ϣ��Ӷ���֤�ļ����ݵ�һ���ԡ�
4. �����̲�����Ҫ��������ڴ�����ʱ�����Ե���munmap�������ͷ��������������������Ҳ�ᱻ�Զ�ͬ���������ϡ�

mmapʵ�ֽ��̹���ԭ����mmap�����ڽ����ڷ��������ڴ�����ôʵ�ֽ��̵Ĺ����ڴ��أ���
1. ʹ�ù����ļ�������A�ͽ���B����ͬһ���ļ�����ʹ��mmap������ļ�ӳ�䵽�Լ��������ڴ��С�����������A�ͽ���B�Ϳ���ͨ������������ڴ�����ķ�����ʵ�ֹ����ڴ档��һ�������޸�����������ڴ����������ʱ������ϵͳ���Զ�ͬ���������ϣ��Ӷ���֤���ݵ�һ���ԡ�
2. ʹ������ӳ�䣺����A�ͽ���B��ʹ��mmap��������һ������ӳ�����򣬲����������ӳ�䵽�Լ��������ڴ��С�����������A�ͽ���B�Ϳ���ͨ������������ڴ�����ķ�����ʵ�ֹ����ڴ档��һ�������޸�����������ڴ����������ʱ������ϵͳ���Զ�ͬ���������ڴ��У��Ӷ���֤���ݵ�һ���ԡ�

�������ƣ�
1. ������ʹ�ù����ļ���������ӳ�䣬���̼乲���ڴ��ԭ����һ���ģ���ͨ����ͬһ�������ڴ�����ӳ�䵽������̵������ڴ�����ʵ�ֹ��� =�� ����ԭ��
2. ���ڶ�����̿���ͬʱ������������ڴ����������Ҫʹ��ͬ����������֤���ݵ�һ���ԡ����õ�ͬ�����ư����ź���������������д���ȡ�


### ���߳�����

���ȣ�����10���������ļ���С�ͻ�������ȷ�����̣߳�Ȼ��Ϊÿ�����̴߳���һ��`fileInfoʵ��`������һ��fileInfoָ�����鴫��ÿ���̣߳��������̴߳�ӡ���ؽ��ȣ�

```c++
struct fileInfo {
    const char *url;   // ����������·��
    char *fileptr;     // �����ڴ�ָ��
    int offset; //  start
    int end;   // end
    pthread_t thid;
    double download; // ��ǰ�߳�������
    double totalDownload;  // �����߳���������
    FILE *recordfile;     // �ļ����
};
```

�����߳����أ�

```c++
int download(const char *url, const char *filename) {
    // 1. ����������������󣬻�ȡ�ļ���С�����������ļ���Ѹ������Ԥ�ȷ����С����Ȼ���ٷ�һ�������������
    // �ļ���������˼·��fwriteֱ��д�ļ���Ԥ�ȴ����ļ�ͨ��mmap�ڴ�ӳ�䣻����ѡ�ڶ���
    long fileLength = getDownloadFileLength(url);
    printf("downloadFileLength: %ld\n", fileLength);

    // write
    int fd = open(filename, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR); //
    if (fd == -1) {
        return -1;
    }
    // �ƶ��ļ�ָ�룬ʹ��Ԥ�������ļ��ͷ��������ļ�һ���������дһ��1��
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
    
    // 2. ���ļ�ӳ�䵽�ڴ�
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

    // 3.��������̣߳�ÿ���߳�һ���ļ�������
    for (i = 0;i <= THREAD_NUM;i ++) {

        info[i] = (struct fileInfo*)malloc(sizeof(struct fileInfo));
        memset(info[i], 0, sizeof(struct fileInfo));

        // ����߳̽��ļ��ֿ�����
        info[i]->offset = i * partSize;
        if (i < THREAD_NUM) {
            info[i]->end = (i+1) * partSize - 1;
        } else {
            info[i]->end = fileLength - 1;
        }
        info[i]->fileptr = fileptr;   // �ڴ�ӳ�䣨���̹߳����ڴ棩
        info[i]->url = url;
        info[i]->download = 0;
        info[i]->recordfile = fp;
    }
    pInfoTable = info;

    //pthread_t thid[THREAD_NUM+1] = {0};
    for (i = 0;i <= THREAD_NUM;i ++) {
        pthread_create(&(info[i]->thid), NULL, worker, info[i]);  // ��Ҫ����worker���ļ���Ϣ��װ��һ���ṹ��
        usleep(1);
    }
    // �ȵ����̶߳��˳������̲߳��˳�
    for (i = 0;i <= THREAD_NUM;i ++) {
        pthread_join(info[i]->thid, NULL);
    }
    // �ͷ���Դ
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

### ���߳�����curl������

���߳�ʵ���߼�: �ļ�д��ص�����Ȼص�

```c++
void *worker(void *arg) {

    struct fileInfo *info = (struct fileInfo*)arg;

    char range[64] = {0};

    // mutex_lock
    if (info->recordfile) {
        // ���ڶϵ����������ļ��ж�ȡrange
        fscanf(info->recordfile, "%d-%d", &info->offset, &info->end);
    }
    // mutex_unlock
    if (info->offset > info->end) return NULL;

    snprintf(range, 64, "%d-%d", info->offset, info->end);

    CURL *curl = curl_easy_init();
    curl_easy_setopt(curl, CURLOPT_URL, info->url); // url
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeFunc); // �ļ����غ�����libcurl��д��ʱִ��
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, info);          // д��ص�����
    curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L); // progress  =�� û�����ؽ���Ϊ0
    curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progressFunc);   // �ص�������libcurl��������ʱ����
    curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, info);         // ���Ȼص���������
    curl_easy_setopt(curl, CURLOPT_RANGE, range);  // ���ƴӷ������ļ������ط�Χ
    // http range
    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        printf("res %d\n", res);
    }
    curl_easy_cleanup(curl);

    return NULL;
}
```

�ļ�д�룺�����������ص�n���ļ�д�빲���ڴ�,���ﲻ��Ҫ������ÿ������д��Ĺ����ڴ��ַ��һ��

```c++
// д��ص���ptr �����ǽ��յ������ݵ�ָ�룻size ������ÿ�����ݿ�Ĵ�С��memb ���������ݿ������
size_t writeFunc(void *ptr, size_t size, size_t memb, void *userdata) {

    struct fileInfo *info = (struct fileInfo *)userdata;
    printf("writeFunc\n");

    memcpy(info->fileptr + info->offset, ptr, size * memb);
    info->offset += size * memb;

    return size * memb;
}
```

���Ȼص����ӽ��̴�ӡ�ļ��ĵ�ǰ���ؽ���
```c++
// ���Ȼص�
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

### �ϵ�����

ע��һ���źţ����ж��źţ������źŷ���ʱ�����ļ��м�¼ÿ���̵߳���һ������range,��һ�����߳�����ʱ�������ļ��е�range���ּ���

```c++
// ���յ��ж��źź󣬼�¼ÿ���̵߳����ؽ���
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

## Դ��

```c++

// gcc -o multi_download multi_download.c -lcurl

#include <stdio.h>
#include <unistd.h>
#include <curl/curl.h>
#include <fcntl.h>
// ��Ҫ��linux��ʹ��
#include <sys/mman.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <signal.h>

// fork();

struct fileInfo {
    const char *url;   // ����������·��
    char *fileptr;     // �����ڴ�ָ��
    int offset; //  start
    int end;   // end
    pthread_t thid;
    double download; // ��ǰ�߳�������
    double totalDownload;  // �����߳���������
    FILE *recordfile;     // �ļ����
};

#define THREAD_NUM		10

struct fileInfo **pInfoTable;   // ����ָ��=>ָ������
double downloadFileLength = 0;

// д��ص���ptr �����ǽ��յ������ݵ�ָ�룻size ������ÿ�����ݿ�Ĵ�С��memb ���������ݿ������
size_t writeFunc(void *ptr, size_t size, size_t memb, void *userdata) {

    struct fileInfo *info = (struct fileInfo *)userdata;
    printf("writeFunc\n");

    memcpy(info->fileptr + info->offset, ptr, size * memb);
    info->offset += size * memb;

    return size * memb;
}

// ���Ȼص�
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
        // ���ڶϵ����������ļ��ж�ȡrange
        fscanf(info->recordfile, "%d-%d", &info->offset, &info->end);
    }
    // mutex_unlock
    if (info->offset > info->end) return NULL;

    snprintf(range, 64, "%d-%d", info->offset, info->end);

    CURL *curl = curl_easy_init();
    curl_easy_setopt(curl, CURLOPT_URL, info->url); // url
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeFunc); // �ļ����غ�����libcurl��д��ʱִ��
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, info);          // д��ص�����
    curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L); // progress  =�� û�����ؽ���Ϊ0
    curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progressFunc);   // �ص�������libcurl��������ʱ����
    curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, info);         // ���Ȼص���������
    curl_easy_setopt(curl, CURLOPT_RANGE, range);  // ���ƴӷ������ļ������ط�Χ
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
    // 1. ����������������󣬻�ȡ�ļ���С�����������ļ���Ѹ������Ԥ�ȷ����С����Ȼ���ٷ�һ�������������
    // �ļ���������˼·��fwriteֱ��д�ļ���Ԥ�ȴ����ļ�ͨ��mmap�ڴ�ӳ�䣻����ѡ�ڶ���
    long fileLength = getDownloadFileLength(url);
    printf("downloadFileLength: %ld\n", fileLength);

    // write
    int fd = open(filename, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR); //
    if (fd == -1) {
        return -1;
    }
    // �ƶ��ļ�ָ�룬ʹ��Ԥ�������ļ��ͷ��������ļ�һ���������дһ��1��
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

    // 2. ���ļ�ӳ�䵽�ڴ�
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

    // 3.��������̣߳�ÿ���߳�һ���ļ�������
    for (i = 0;i <= THREAD_NUM;i ++) {

        info[i] = (struct fileInfo*)malloc(sizeof(struct fileInfo));
        memset(info[i], 0, sizeof(struct fileInfo));

        // ����߳̽��ļ��ֿ�����
        info[i]->offset = i * partSize;
        if (i < THREAD_NUM) {
            info[i]->end = (i+1) * partSize - 1;
        } else {
            info[i]->end = fileLength - 1;
        }
        info[i]->fileptr = fileptr;   // �ڴ�ӳ�䣨���̹߳����ڴ棩
        info[i]->url = url;
        info[i]->download = 0;
        info[i]->recordfile = fp;
    }
    pInfoTable = info;

    //pthread_t thid[THREAD_NUM+1] = {0};
    for (i = 0;i <= THREAD_NUM;i ++) {
        pthread_create(&(info[i]->thid), NULL, worker, info[i]);  // ��Ҫ����worker���ļ���Ϣ��װ��һ���ṹ��
        usleep(1);
    }
    // �ȵ����̶߳��˳������̲߳��˳�
    for (i = 0;i <= THREAD_NUM;i ++) {
        pthread_join(info[i]->thid, NULL);
    }
    // �ͷ���Դ
    for (i = 0;i <= THREAD_NUM;i ++) {
        free(info[i]);
    }

    if (fp)
        fclose(fp);

    munmap(fileptr, fileLength);
    close(fd);
    return 0;
}

// ���յ��ж��źź󣬼�¼ÿ���̵߳����ؽ���
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