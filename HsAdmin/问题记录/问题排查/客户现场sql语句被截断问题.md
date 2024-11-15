# sql��䱻�ض�����

## ��������

����ѯ�����е�ϯλ�϶�ʱ����ֱ�ӱ���`misssing expression ORA-06550`

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240927163846.png" alt="20240927163846" width="850">

����־��`in (...)`������������������ض��ˣ�

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/20240927164142.png" alt="20240927164142" width="850">

## �����Ų�

��ʵҲ��������߼�

1. �鿴��������
```xml
<field name="stockholder_id_sql" type ="S" auto_width="true">
    <rule type="Rule_SQL_IN" src="stockholder_id_obj_str" datasource="5" cond_fild="stockholder_id"/>
</field>
<field name="bind_seat_sql" type ="S" auto_width="true">
    <rule type="Rule_SQL_IN" src="bind_seat_obj_str" datasource="6" cond_fild="bind_seat"/>
</field>
```

2. �������������

Field����Ҫ�ֶκʹ�������

```c++
class Field : public Initializable{
public:
    explicit Field(const char* name = NULL);
    //�������캯��ʹ��Ĭ�ϣ�Initialize�Գ�Աֵ���г�ʼ���������class���ԣ����ʼ��һ�������
    // ��ʼ�����ˣ�mysql���̵���������ô����do_packe�أ�Ҳ���ǵ������ļ��ĵ�һ�д�������
    virtual void Initialize(xml_node<>* init_node, Status* init_status);
    inline DataPacker* data_packer() { return data_packer_; }
    inline Rule* rule() { return rule_; }
    void GetFieldValue(const Datasources& datasources, Datasource* datasource, string& result, Status* status);
    void FieldValueTransfer(const Datasources& datasources, Datasource* datasource, string& result, Status* status);
    // ...
protected:
    // �ֶ�����
    string name_;
    // �ֶ����� I,F,S,C,R,U
    char type_;
    // �ֶο��
    int width_;
    // �ֶξ���
    int scale_;
    // �ֶ�ֵ
    string value_;
    // �ֶ�ȱʡֵ����Դ�ֶ�Ϊ�ջ�δ���ʱ�������ֶθ�ȱʡֵ������value����ʱ��default��Ч��
    string default_value_;
    // ������Դ�ֶ�����
    string src_;
    // ����ԴID
    int datasource_id_;
    // ���ݼ�ID
    int dataset_id_;
    DataPacker* data_packer_;
    Rule* rule_;
	bool empty_packer_;
    bool check_width_;
    bool auto_width_;
}; 
```
���Կ���field��Ҫ�Ⱦ���`Rule_SQL_IN`�ദ��,����`Rule_SQL_IN.`