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
    // 给其他服务提供的接口，查看哪些表处于同步中
    std::vector<std::string>& GetAllSyncTable();
    // 将一个表设置为同步中
    bool setTableSync(std::string tableName);
    // 将一个表设置为非同步
    bool setTableFinish(const char* tableName);
    // 判断一个表是否处于同步中，由于只考虑同步、非同步两种状态，所以返回值用bool不用int
    bool IsOneTableSync(const char* tableName);
    // 解决锁重入的问题
    bool IsOneTableSyncNoLock(const char* tableName);
    // 判断要同步的表是否全部在同步状态，有一个在同步状态，就返回false
    bool IsAllTableNoSync(IF2UnPacker * lpInUnPacker, IF2Packer * lpOutPacker);
private:
    static CSyncTableManager* m_CSyncTableManager;
    std::vector<std::string> m_TableSync;
    FBASE2::CThreadMutex m_SyncTableMutex;
};

#endif
