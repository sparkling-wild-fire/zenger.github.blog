#ifndef __SYSTABLE_H__
#define __SYSTABLE_H__
#include <vector>
#include <string>
#include <os/thread_mutex.h>
#include <os/thread.h>
#include <Include/esb_message_interface.h>
#include <Include/pack_interface.h>

class CSyncTableManager
{
private:
    CSyncTableManager();
    virtual ~CSyncTableManager();
public:
    static CSyncTableManager* GetInstance();
    // �����������ṩ�Ľӿڣ��鿴��Щ����ͬ����
    std::vector<std::string>& GetAllSyncTable();
    // ��һ��������Ϊͬ����
    bool setTableSync(std::string tableName);
    // ��һ��������Ϊ��ͬ��
    bool setTableFinish(const char* tableName);
    // �ж�һ�����Ƿ���ͬ���У�����ֻ����ͬ������ͬ������״̬�����Է���ֵ��bool����int
    bool IsOneTableSync(const char* tableName);
    // ��������������
    bool IsOneTableSyncNoLock(const char* tableName);
    // �ж�Ҫͬ���ı��Ƿ�ȫ����ͬ��״̬����һ����ͬ��״̬���ͷ���false
    bool IsAllTableNoSync(IF2UnPacker * lpInUnPacker, IF2Packer * lpOutPacker);
private:
    static CSyncTableManager* m_CSyncTableManager;
    std::vector<std::string> m_TableSync;
    FBASE2::CThreadMutex m_SyncTableMutex;
};

#endif
