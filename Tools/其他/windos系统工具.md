# windows系统工具

## Process Explorer

作为任务管理器的enchanned版，能更好地管理windows下的进程

如这种常见的问题，知道一个文件夹被另一个进程占用，又不知道被哪个进程占用的问题：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202310141458782.png" alt="202310141458782" width="450px">

一般来说，如果是该文件夹中起了一个进程，是可以在任务管理的资源监视器中查看的，但是如果是一个系统进程占用了这个文件夹，那任务管理器就没有根据这个文件夹查看占用的进程了

这时，可以通过Process Explorer工具进程查找：点击`Find` => 输入文件夹路径

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202310141449075.png" alt="202310141449075" width="450px">

如上图，干掉3242进程就ok了：`taskkill /pid 3242`

## C++遍历进程

测试下文件非exe占用的情况

获取一个进程快照，遍历快照中的所有进程，打开句柄获取其运行文件路径，如果运行文件在指定目录下，就打印输出

```c++
#include <iostream>
#include <Windows.h>
#include <TlHelp32.h>
#include <string>
#include <psapi.h>
#include <fcntl.h>

using namespace std;

int main()
{
    _setmode(_fileno(stdout), _O_TEXT); // 修改控制台编码为 gbk
    string targetPath = "D:\\AresNew\\CRES_64"; // 目标文件目录路径

    // 创建进程快照
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapshot == INVALID_HANDLE_VALUE)
    {
        cout << "CreateToolhelp32Snapshot failed" << endl;
        return 1;
    }else{
        // cout<<"CreateToolhelp32Snapshot success."<< endl;
    }

    PROCESSENTRY32 pe = { 0 };
    pe.dwSize = sizeof(pe);

    // 遍历进程快照
    if (Process32First(hSnapshot, &pe))
    {
        do
        {
            // 打开进程句柄
            HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pe.th32ProcessID);
            if (hProcess == NULL)
            {
                continue;
            }else{
                // cout<<"Open Process Handle success."<< endl;
            }

            HMODULE hModule = NULL;
            DWORD cbNeeded = 0;

            // 获取进程中所有模块的句柄
            if (!EnumProcessModules(hProcess, &hModule, sizeof(hModule), &cbNeeded))
            {
                CloseHandle(hProcess);
                continue;
            }

            char szPath[MAX_PATH] = { 0 };

            // 遍历模块句柄
            if (GetModuleFileNameEx(hProcess, hModule, szPath, sizeof(szPath)))
            {
                string filePath(szPath);

                // 判断文件路径是否以目标文件目录路径开头
                if (filePath.substr(0, targetPath.length()) == targetPath)
                {
                    cout << "Process ID: " << pe.th32ProcessID << endl;
                    cout << "Process Name: " << pe.szExeFile << endl;
                    cout << "File Path: " << filePath << endl;
                    cout << endl;
                }else{
                    // cout << "File Path: " << filePath << endl;
                }
            }

            CloseHandle(hProcess);
        } while (Process32Next(hSnapshot, &pe));
    }

    CloseHandle(hSnapshot);

    return 0;
}
```