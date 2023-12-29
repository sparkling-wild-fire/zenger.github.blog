# windowsϵͳ����

## Process Explorer

��Ϊ�����������enchanned�棬�ܸ��õع���windows�µĽ���

�����ֳ��������⣬֪��һ���ļ��б���һ������ռ�ã��ֲ�֪�����ĸ�����ռ�õ����⣺

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202310141458782.png" alt="202310141458782" width="450px">

һ����˵������Ǹ��ļ���������һ�����̣��ǿ���������������Դ�������в鿴�ģ����������һ��ϵͳ����ռ��������ļ��У��������������û�и�������ļ��в鿴ռ�õĽ�����

��ʱ������ͨ��Process Explorer���߽��̲��ң����`Find` => �����ļ���·��

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202310141449075.png" alt="202310141449075" width="450px">

����ͼ���ɵ�3242���̾�ok�ˣ�`taskkill /pid 3242`

## C++��������

�������ļ���exeռ�õ����

��ȡһ�����̿��գ����������е����н��̣��򿪾����ȡ�������ļ�·������������ļ���ָ��Ŀ¼�£��ʹ�ӡ���

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
    _setmode(_fileno(stdout), _O_TEXT); // �޸Ŀ���̨����Ϊ gbk
    string targetPath = "D:\\AresNew\\CRES_64"; // Ŀ���ļ�Ŀ¼·��

    // �������̿���
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

    // �������̿���
    if (Process32First(hSnapshot, &pe))
    {
        do
        {
            // �򿪽��̾��
            HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pe.th32ProcessID);
            if (hProcess == NULL)
            {
                continue;
            }else{
                // cout<<"Open Process Handle success."<< endl;
            }

            HMODULE hModule = NULL;
            DWORD cbNeeded = 0;

            // ��ȡ����������ģ��ľ��
            if (!EnumProcessModules(hProcess, &hModule, sizeof(hModule), &cbNeeded))
            {
                CloseHandle(hProcess);
                continue;
            }

            char szPath[MAX_PATH] = { 0 };

            // ����ģ����
            if (GetModuleFileNameEx(hProcess, hModule, szPath, sizeof(szPath)))
            {
                string filePath(szPath);

                // �ж��ļ�·���Ƿ���Ŀ���ļ�Ŀ¼·����ͷ
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