# Clion

1. ����Ŀʱ����ô�Լ�ѡ�����´��ڻ��Ǳ����ڣ�����=>ϵͳ����

2. CLion����SVN��������Ŀ����git��algoserver����svn���ֱ����á�[�ο�����](https://blog.csdn.net/cmhdl521/article/details/127775960)

3. ��ݼ���
   - alt+shift: ���б༭
   - ctrl+G:��ת��ָ���У���  => �´ΰٶȲ����˾Ͱٶ�vscode��

```C++


```

std::multimap<int, int> multimapRiskNo;
if(NULL != @risk_detail_obj && @risk_detail_obj->GetRowCount() > 0)
{
LogFlow("risk_detail_obj, ���� ��" << @risk_detail_obj->GetRowCount());
@rowid = 0;
while(!@risk_detail_obj->IsEOF())
{
++@rowid;
[�ֹ������][@risk_serial_no][@risk_detail_obj]
multimapRiskNo.insert(std::make_pair(@risk_serial_no, @rowid));
LogFlow("risk_detail_objItem, risk_serial_no ��" << @risk_serial_no);
@risk_detail_obj->Next();
}
[���������][risk_detail_obj_tmp]
LogFlow("entrustwaste_msg_obj, ���� ��" << @entrustwaste_msg_obj->GetRowCount());
if(NULL != @entrustwaste_msg_obj && @entrustwaste_msg_obj->GetRowCount() > 0)
{
strcpy(@topic_name, "stp.api.entrust_waste");
[���������][entrustwaste_msg_obj_tmp]
while(!@entrustwaste_msg_obj->IsEOF())
{
@entrustwaste_msg_obj_tmp->BeginPack();
CopyPackerHead(@entrustwaste_msg_obj,@entrustwaste_msg_obj_tmp);

    			[�ֹ������][@risk_serial_no][@entrustwaste_msg_obj]
    			LogFlow("entrustwaste_msg_objItem, risk_serial_no ��" << @risk_serial_no);
    			
  				std::multimap<int, int>::iterator iterBegin = multimapRiskNo.lower_bound(@risk_serial_no);
 				std::multimap<int, int>::iterator iterEnd = multimapRiskNo.upper_bound(@risk_serial_no);
    			if(iterBegin != iterEnd)
    			{
    				@risk_count = 0;
    				@risk_detail_obj_tmp->BeginPack();
	    			CopyPackerHead(@risk_detail_obj,@risk_detail_obj_tmp);
    				for(;iterBegin != iterEnd; ++iterBegin)
	    			{
	    				@risk_detail_obj->Go(iterBegin->second);
	    				
	    				CopyPackerBody(@risk_detail_obj,@risk_detail_obj_tmp);
	    				++@risk_count;
	    			}
	    			@risk_detail_obj_tmp->EndPack();
	    			
	    			@entrustwaste_msg_obj_tmp->AddField("risk_count", 'I');
	    			[���������ͷ][risk_detail_obj][risk_detail_obj_tmp][entrustwaste_msg_obj_tmp]
	    			CopyPackerBody(@entrustwaste_msg_obj,@entrustwaste_msg_obj_tmp);
	    			@entrustwaste_msg_obj_tmp->AddInt(@risk_count);
	    			[�������������][risk_detail_obj_tmp][entrustwaste_msg_obj_tmp]
    			}
    			else
    			{
	    			CopyPackerBody(@entrustwaste_msg_obj,@entrustwaste_msg_obj_tmp);
    			}
    			@entrustwaste_msg_obj_tmp->EndPack();
	    		[��������󷵻�][@entrustwaste_msg_obj_tmp]
	    			
	        	<R>[AF_STP_������Ϣ][msg_body=@entrustwaste_msg_obj_tmp]
    			@entrustwaste_msg_obj->Next();
    		}
	    }
	    if(NULL != @entrust_msg_obj && @entrust_msg_obj->GetRowCount() > 0) 
	    {
	    	[�ֹ������][@entrust_state][@entrust_msg_obj]
	    	if('b' == @entrust_state)
    		{
    			strcpy(@topic_name, "stp.api.entrust_approve");
    		}
	        else
	        {
	        	strcpy(@topic_name, "stp.api.entrust");
	        }
	    	[���������][entrust_msg_obj_tmp]
	    	while(!@entrust_msg_obj->IsEOF())
    		{
    			@entrust_msg_obj_tmp->BeginPack();
	    		CopyPackerHead(@entrust_msg_obj,@entrust_msg_obj_tmp);
	    		
    			[�ֹ������][@risk_serial_no][@entrust_msg_obj]
    			
  				std::multimap<int, int>::iterator iterBegin = multimapRiskNo.lower_bound(@risk_serial_no);
 				std::multimap<int, int>::iterator iterEnd = multimapRiskNo.upper_bound(@risk_serial_no);
    			if(iterBegin != iterEnd)
    			{
    				@risk_count = 0;
    				@risk_detail_obj_tmp->BeginPack();
	    			CopyPackerHead(@risk_detail_obj,@risk_detail_obj_tmp);
    				for(;iterBegin != iterEnd; ++iterBegin)
	    			{
	    				@risk_detail_obj->Go(iterBegin->second);
	    				
	    				CopyPackerBody(@risk_detail_obj,@risk_detail_obj_tmp);
	    				++@risk_count;
	    			}
	    			@risk_detail_obj_tmp->EndPack();
	    			
	    			@entrust_msg_obj_tmp->AddField("risk_count", 'I');
	    			[���������ͷ][risk_detail_obj][risk_detail_obj_tmp][entrust_msg_obj_tmp]
	    			CopyPackerBody(@entrust_msg_obj,@entrust_msg_obj_tmp);
	    			@entrust_msg_obj_tmp->AddInt(@risk_count);
	    			[�������������][risk_detail_obj_tmp][entrust_msg_obj_tmp]
    			}
    			else
    			{
	    			CopyPackerBody(@entrust_msg_obj,@entrust_msg_obj_tmp);
    			}
    			@entrust_msg_obj_tmp->EndPack();
	    		[��������󷵻�][@entrust_msg_obj_tmp]
	    			
	        	<R>[AF_STP_������Ϣ][msg_body=@entrust_msg_obj_tmp]
    			@entrust_msg_obj->Next();
    		}
	    }
    }
    else
    {
    	LogFlow("�����ϢΪ��");
	    if(NULL != @entrustwaste_msg_obj && @entrustwaste_msg_obj->GetRowCount() > 0) 
	    {
	    	LogFlow("�ϵ���Ϣ��Ϊ��");
	        strcpy(@topic_name, "stp.api.entrust_waste");
	        <R>[AF_STP_������Ϣ][msg_body=@entrustwaste_msg_obj]
	    }else{
	    	LogFlow("�ϵ���ϢΪ��");
	    }