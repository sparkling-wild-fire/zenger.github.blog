# algoserver �ֱ��ָ�

5180509
15180028
45180009: ����վ���ѯ   =�� ���˲�ѯ������Ϊɶ���ǿ�ֵ
35180402 �� ��վ�㣨�����е��̣߳�������Ϣ`asset.algo.recover_scheme`  =�� ����

���ԣ�
AlgoDealThread.cpp���յ�������Ϣ�����߳�1�յ�������Ϣ����Ϊɶֻ��27�����ŵ�(Ӧ���Ǵ�С����һ��һ����)
AlgoOrder.cpp����������Ϣ�������ķ����Ŷ���0��  =�� Ӧ�����ؽ����ˣ�Ӧ���Ǵ������ķ�����
Login.cpp����¼������վ�����6
����5180268����;ӳ���˻���ѯ�����ݷ���id��ѯ�� =�� ��ѯ���������е��˻���Ϣ  =��Ҳ���Ƿ�����ϸ�£�����account_info�е��˻���
...
���������ɹ� =�� 51802020(����״̬) =�� 5180246 =�� ����վ��ɹ��ӹܷ���ID[31]

�ֱ������ӵ���ɣ���ƽ̨���ͷ��������Ϣ  =�� 5180224 �������ָ���Ϣ��ȷ�����ǻص�����ô���������Ϣ������������ѵģ� =�� AsynCallServer()�첽����

���� =�� �����������վ���߳����߰�

��ô��֮ǰ�ķ���ȫ��ɾ��

�����ؽ� => ���߳� 

����ί����,�ɽ����ָ���`����֤ȯ���ܷ���ί����Ϣ������֤ȯ����ί����Ϣ��`



���Ե�OnSchemeInit => ?
int CSchemeMessageProc::OnSchemeInit(IF2UnPacker* pUnPacker, std::string& sOutParam) =>
int CSchemeImpl::OnSchemeInit(IF2UnPacker* pUnPacker, std::string& sOutParam)    =>  ���pUnPacker�ĸ�ƽ̨������
    => int CSchemeImpl::GatherSchemeStocksInfo(IF2UnPacker* pUnPacker, std::string& sErrMsg)   