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
