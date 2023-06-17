# C++

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

