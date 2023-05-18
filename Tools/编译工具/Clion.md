# Clion

1. 打开项目时，怎么自己选择是新窗口还是本窗口：设置=>系统设置

2. CLion配置SVN，博客项目的用git，algoserver的用svn，分别配置。[参考链接](https://blog.csdn.net/cmhdl521/article/details/127775960)

3. 快捷键：
   - alt+shift: 多行编辑
   - ctrl+G:跳转到指定行：列  => 下次百度不到了就百度vscode的

```C++


```

std::multimap<int, int> multimapRiskNo;
if(NULL != @risk_detail_obj && @risk_detail_obj->GetRowCount() > 0)
{
LogFlow("risk_detail_obj, 个数 ：" << @risk_detail_obj->GetRowCount());
@rowid = 0;
while(!@risk_detail_obj->IsEOF())
{
++@rowid;
[手工解包体][@risk_serial_no][@risk_detail_obj]
multimapRiskNo.insert(std::make_pair(@risk_serial_no, @rowid));
LogFlow("risk_detail_objItem, risk_serial_no ：" << @risk_serial_no);
@risk_detail_obj->Next();
}
[打包器声明][risk_detail_obj_tmp]
LogFlow("entrustwaste_msg_obj, 个数 ：" << @entrustwaste_msg_obj->GetRowCount());
if(NULL != @entrustwaste_msg_obj && @entrustwaste_msg_obj->GetRowCount() > 0)
{
strcpy(@topic_name, "stp.api.entrust_waste");
[打包器声明][entrustwaste_msg_obj_tmp]
while(!@entrustwaste_msg_obj->IsEOF())
{
@entrustwaste_msg_obj_tmp->BeginPack();
CopyPackerHead(@entrustwaste_msg_obj,@entrustwaste_msg_obj_tmp);

    			[手工解包体][@risk_serial_no][@entrustwaste_msg_obj]
    			LogFlow("entrustwaste_msg_objItem, risk_serial_no ：" << @risk_serial_no);
    			
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
	    			[打包二进制头][risk_detail_obj][risk_detail_obj_tmp][entrustwaste_msg_obj_tmp]
	    			CopyPackerBody(@entrustwaste_msg_obj,@entrustwaste_msg_obj_tmp);
	    			@entrustwaste_msg_obj_tmp->AddInt(@risk_count);
	    			[打包二进制数据][risk_detail_obj_tmp][entrustwaste_msg_obj_tmp]
    			}
    			else
    			{
	    			CopyPackerBody(@entrustwaste_msg_obj,@entrustwaste_msg_obj_tmp);
    			}
    			@entrustwaste_msg_obj_tmp->EndPack();
	    		[结果集对象返回][@entrustwaste_msg_obj_tmp]
	    			
	        	<R>[AF_STP_发送消息][msg_body=@entrustwaste_msg_obj_tmp]
    			@entrustwaste_msg_obj->Next();
    		}
	    }
	    if(NULL != @entrust_msg_obj && @entrust_msg_obj->GetRowCount() > 0) 
	    {
	    	[手工解包体][@entrust_state][@entrust_msg_obj]
	    	if('b' == @entrust_state)
    		{
    			strcpy(@topic_name, "stp.api.entrust_approve");
    		}
	        else
	        {
	        	strcpy(@topic_name, "stp.api.entrust");
	        }
	    	[打包器声明][entrust_msg_obj_tmp]
	    	while(!@entrust_msg_obj->IsEOF())
    		{
    			@entrust_msg_obj_tmp->BeginPack();
	    		CopyPackerHead(@entrust_msg_obj,@entrust_msg_obj_tmp);
	    		
    			[手工解包体][@risk_serial_no][@entrust_msg_obj]
    			
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
	    			[打包二进制头][risk_detail_obj][risk_detail_obj_tmp][entrust_msg_obj_tmp]
	    			CopyPackerBody(@entrust_msg_obj,@entrust_msg_obj_tmp);
	    			@entrust_msg_obj_tmp->AddInt(@risk_count);
	    			[打包二进制数据][risk_detail_obj_tmp][entrust_msg_obj_tmp]
    			}
    			else
    			{
	    			CopyPackerBody(@entrust_msg_obj,@entrust_msg_obj_tmp);
    			}
    			@entrust_msg_obj_tmp->EndPack();
	    		[结果集对象返回][@entrust_msg_obj_tmp]
	    			
	        	<R>[AF_STP_发送消息][msg_body=@entrust_msg_obj_tmp]
    			@entrust_msg_obj->Next();
    		}
	    }
    }
    else
    {
    	LogFlow("风控消息为空");
	    if(NULL != @entrustwaste_msg_obj && @entrustwaste_msg_obj->GetRowCount() > 0) 
	    {
	    	LogFlow("废单消息不为空");
	        strcpy(@topic_name, "stp.api.entrust_waste");
	        <R>[AF_STP_发送消息][msg_body=@entrustwaste_msg_obj]
	    }else{
	    	LogFlow("废单消息为空");
	    }