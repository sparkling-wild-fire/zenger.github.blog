# C++

1. 宏
```C++
#ifdef _WIN32
    #if !defined(FUNCTION_CALL_MODE)
        #define FUNCTION_CALL_MODE __stdcall
    #endif
    #if !defined(EXPORT_API)
        #define EXPORT_API  __declspec(dllexport)
    #endif
#else
    #define FUNCTION_CALL_MODE
    #define EXPORT_API
#endif

// class后面加个宏是干嘛？
class EXPORT_API COptionInfo
{
    IMPL_CLASS_CONSTRUCTOR_DEF(COptionInfo)
}
```

2. 超时重试代码
```C++
void func(){
    // 超时重试代码
    while (iRetryTimes < 3) {
        iRetCode=rpc();
        if(iRetCode==RET_OK){
            // ...
            break;
        }
        else if(iRetCode == ERR_SYN_REQUEST_TIMEOUT){
            iRetryTimes++;
            continue;
        }
        else{
            // ... 
            // break;
            }
        }
    }
    
    if(iRetCode==RET_OK){// 对结果进行处理}
}
```

3. 我的错误

对于类成员变量：
- 尽量不要设置为char*和const char*, 需要初始化时分配内存空间，不然使用strcpy或strncpy时会产生core。建议使用std::string
  - `OptionInfo.m_Impl->m_sTradeMonth = pUnPacker->GetStr("trade_month");`这种写法会产生乱码问题，其中m_sTradeMonth为（const） char*
  - 这种就是将指向常量指针指向了另一块内存，本质上是 const char* m_sTradeMonth=std::string(这个指针应该还是临时的，值为cu1704), 这个m_sTradeMonth的内容可能会变为cu17U或其他的
- 类的成员函数类型建议设置为const char *


4. rpc代码分析

```C++
//LS_周边接口_下载客户端安装包
int FUNCTION_CALL_MODE F403825(IAS2Context * lpContext,IF2UnPacker * lpInUnPacker,IF2Packer * lpOutPacker)   // 上下文、入参包、出参包
{
    // 解入参包
    int iReturnCode = 0;
    char v_error_pathinfo[4001] = {0};
    hs_strcpy(v_error_pathinfo, "F403825()");
    int v_branch_no = lpInUnPacker->GetInt("branch_no");
    int v_sysnode_id = 0;
    int v_subsys_id = 0;
    int v_timeout = 0;
    char v_audit_action = lpInUnPacker->GetChar("audit_action");
    IF2PackSvr * lpPackService = lpContext->GetF2PackSvr();
    IESBMessage * lpMsgReq = lpContext->GetOrgRequest();
    char v_error_code[17] = {0};
    char v_error_extinfo[1025] = {0};
    char v_subsys_abbr[17] = {0};
    
    
    IF2Packer * lpFuncInPacker = lpPackService->GetPacker(2);
    char p_loadid[129] = {0};
    hs_strncpy(p_loadid,conversion((char *)lpInUnPacker->GetStr("loadid")),128);
    int v_error_no = 0;
    char v_file_name[257] = {0};
    int v_offset = 0;
    int vi_download_file_data = 0;
    void * v_download_file_data = NULL;
    char v_error_info[1025] = {0};
    
    // 业务逻辑代码
    hs_strcpy(v_file_name,"QT");
    v_offset=0;
    vi_download_file_data = func_quant_down(v_file_name,v_offset,p_loadid,v_download_file_data,v_error_info);
    v_error_no=0;
    if(vi_download_file_data<=0)
    {
        v_error_no=-1;
        free(v_download_file_data);
        v_download_file_data=NULL;
        iReturnCode = -1;
        v_error_no   = -1;
        hs_snprintf(v_error_info,CNST_ERRORINFO_LEN, "文件下载失败[file_name=%s,offset=%d,error_info=%s]",v_file_name,v_offset,v_error_info);
        goto svr_end;
        
    }
    // 出参包
    else
    {
        lpOutPacker->AddField("error_no", 'I');
        lpOutPacker->AddField("error_info", 'S', 1024);
        lpOutPacker->AddField("download_file_data", 'R',vi_download_file_data);
        
        lpOutPacker->AddInt(v_error_no);
        lpOutPacker->AddStr(v_error_info);
        lpOutPacker->AddRaw(v_download_file_data,vi_download_file_data);
        
    }
    free(v_download_file_data);
    v_download_file_data=NULL;
    goto svr_end;
    svr_end:
    if (iReturnCode == OK_SUCCESS || iReturnCode  == ERR_SYSWARNING)
    {
        
    }
    else
    {
        if (lpMsgReq)
        {
            SystemErrorPacker(lpOutPacker, lpMsgReq->GetItem(TAG_COMP_ID)->GetString(), lpMsgReq->GetItem(TAG_SUB_SYSTEM_NO)->GetInt(),v_error_code,v_error_no,v_error_info, v_error_extinfo, v_error_pathinfo);
        }
        
        
    }
    if (lpFuncInPacker)
    {
        free(lpFuncInPacker->GetPackBuf());
        lpFuncInPacker->Release();
    }
    return iReturnCode;
}

```