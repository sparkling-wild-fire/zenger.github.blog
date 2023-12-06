#include "syncTable.h"
#include <algorithm>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <sstream>
#include "ufx_log.h"

// 在主线程中初始化一个数据表同步管理器
CSyncTableManager *CSyncTableManager::m_CSyncTableManager = new CSyncTableManager();

// 子线程 获取数据表同步管理器
// 如果多个子线程都获取到了这个管理器，也没关系，会判断当前子线程同步的表如果在同步中，就直接退出了
CSyncTableManager *CSyncTableManager::GetInstance()
{
    return m_CSyncTableManager;
}

CSyncTableManager::CSyncTableManager()
{
}

// 服务退出，释放数据表同步管理器
CSyncTableManager::~CSyncTableManager()
{
    if (m_CSyncTableManager)
    {
        delete m_CSyncTableManager;
        m_CSyncTableManager = NULL;
    }
}

bool CSyncTableManager::IsOneTableSync(const char* sTableName){
    FBASE2::CAutoMutex lock(&m_SyncTableMutex);
    return IsOneTableSyncNoLock(sTableName);
}

// 子线程设置一个表在同步中
bool CSyncTableManager::setTableSync(std::string sTableName){
    FBASE2::CAutoMutex lock(&m_SyncTableMutex);
    m_TableSync.push_back(sTableName);
    return true;
}

bool CSyncTableManager::IsOneTableSyncNoLock(const char* sTableName){
    return find(m_TableSync.begin(), m_TableSync.end(), sTableName)!=m_TableSync.end();
}

bool CSyncTableManager::setTableFinish(const char* sTableName){
    FBASE2::CAutoMutex lock(&m_SyncTableMutex);
    std::vector<std::string> tmp =m_TableSync;
    int vSize = tmp.size();
    int i=0;
    for (; i < vSize; i++){
        if(strcmp(tmp[i].data(), sTableName)==0){
            tmp.erase(tmp.begin() + i);
            break;
        }
    }
    m_TableSync = tmp;
    return i!=vSize;
}

std::vector<std::string>& CSyncTableManager::GetAllSyncTable(){
    return m_TableSync;
}


bool CSyncTableManager::IsAllTableNoSync(IF2UnPacker * lpInUnPacker, IF2Packer * lpOutPacker){
    FBASE2::CAutoMutex lock(&m_SyncTableMutex);
    bool bRes=true;
    char v_cur_table_name[1024]={0};
    lpOutPacker->AddField("table_name",'S',1024);
    while(!lpInUnPacker->IsEOF()){
        strcpy(v_cur_table_name, lpInUnPacker->GetStr("table_name"));
        // 记录下同步中的表，返回给客户端
        if(IsOneTableSyncNoLock(v_cur_table_name)){
            lpOutPacker->AddStr(v_cur_table_name);
            bRes = false;
        }
        lpInUnPacker->Next();
    }
    return bRes;
}