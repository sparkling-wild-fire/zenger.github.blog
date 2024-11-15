# sql语句被截断问题

## 问题现象

当查询条件中的席位较多时，会直接报错`misssing expression ORA-06550`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240927163846.png" alt="20240927163846" width="850">

看日志是`in (...)`条件语句后面的条件被截断了：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240927164142.png" alt="20240927164142" width="850">

## 问题排查

其实也是理代码逻辑

1. 查看适配器：
```xml
<field name="stockholder_id_sql" type ="S" auto_width="true">
    <rule type="Rule_SQL_IN" src="stockholder_id_obj_str" datasource="5" cond_fild="stockholder_id"/>
</field>
<field name="bind_seat_sql" type ="S" auto_width="true">
    <rule type="Rule_SQL_IN" src="bind_seat_obj_str" datasource="6" cond_fild="bind_seat"/>
</field>
```

2. 打包器处理流程

Field类主要字段和处理函数：

```c++
class Field : public Initializable{
public:
    explicit Field(const char* name = NULL);
    //拷贝构造函数使用默认，Initialize对成员值进行初始化，如果有class属性，会初始化一个对象包
    // 初始化好了，mysql工程调进来，怎么触发do_packe呢？也就是调适配文件的第一行代码在哪
    virtual void Initialize(xml_node<>* init_node, Status* init_status);
    inline DataPacker* data_packer() { return data_packer_; }
    inline Rule* rule() { return rule_; }
    void GetFieldValue(const Datasources& datasources, Datasource* datasource, string& result, Status* status);
    void FieldValueTransfer(const Datasources& datasources, Datasource* datasource, string& result, Status* status);
    // ...
protected:
    // 字段名称
    string name_;
    // 字段类型 I,F,S,C,R,U
    char type_;
    // 字段宽度
    int width_;
    // 字段精度
    int scale_;
    // 字段值
    string value_;
    // 字段缺省值，当源字段为空或未打包时，赋给字段改缺省值，当有value属性时，default无效。
    string default_value_;
    // 数据来源字段名称
    string src_;
    // 数据源ID
    int datasource_id_;
    // 数据集ID
    int dataset_id_;
    DataPacker* data_packer_;
    Rule* rule_;
	bool empty_packer_;
    bool check_width_;
    bool auto_width_;
}; 
```
可以看到field需要先经过`Rule_SQL_IN`类处理,调用`Rule_SQL_IN.`