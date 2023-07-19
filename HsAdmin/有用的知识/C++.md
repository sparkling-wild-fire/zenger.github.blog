# C++

1. ��
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

// class����Ӹ����Ǹ��
class EXPORT_API COptionInfo
{
    IMPL_CLASS_CONSTRUCTOR_DEF(COptionInfo)
}
```

2. ��ʱ���Դ���
```C++
void func(){
    // ��ʱ���Դ���
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
    
    if(iRetCode==RET_OK){// �Խ�����д���}
}
```

3. �ҵĴ���

�������Ա������
- ������Ҫ����Ϊchar*��const char*, ��Ҫ��ʼ��ʱ�����ڴ�ռ䣬��Ȼʹ��strcpy��strncpyʱ�����core������ʹ��std::string
  - `OptionInfo.m_Impl->m_sTradeMonth = pUnPacker->GetStr("trade_month");`����д��������������⣬����m_sTradeMonthΪ��const�� char*
  - ���־��ǽ�ָ����ָ��ָ������һ���ڴ棬�������� const char* m_sTradeMonth=std::string(���ָ��Ӧ�û�����ʱ�ģ�ֵΪcu1704), ���m_sTradeMonth�����ݿ��ܻ��Ϊcu17U��������
- ��ĳ�Ա�������ͽ�������Ϊconst char *


4. rpc�������

```C++
//LS_�ܱ߽ӿ�_���ؿͻ��˰�װ��
int FUNCTION_CALL_MODE F403825(IAS2Context * lpContext,IF2UnPacker * lpInUnPacker,IF2Packer * lpOutPacker)   // �����ġ���ΰ������ΰ�
{
    // ����ΰ�
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
    
    // ҵ���߼�����
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
        hs_snprintf(v_error_info,CNST_ERRORINFO_LEN, "�ļ�����ʧ��[file_name=%s,offset=%d,error_info=%s]",v_file_name,v_offset,v_error_info);
        goto svr_end;
        
    }
    // ���ΰ�
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