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
