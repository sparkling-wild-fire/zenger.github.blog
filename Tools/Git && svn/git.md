# git

[��������Է���github����git��ȡ����](https://blog.csdn.net/u010096608/article/details/119179550)

## ��֧

- ������֧��
   - github����master�Ļ����ϴ���һ����֧company��Ȼ����ȡ�����أ�
   - �����½�һ����֧��Ȼ��push��Զ�̣�`git checkout -b ��֧��` ����idea������֧
- ��ȡ���£���Ҫ���ø��ٷ�֧ =>  Զ�� company
- �ύ���ͣ��Ƶ�company��֧����github��ѯ���ļ����л���main��֧���ļ���û���ĵ�

[������֧����](https://blog.csdn.net/ding43930053/article/details/128318677)
[��֧�ύ](https://blog.csdn.net/u011746120/article/details/128075036)

## ��֧�ϲ�

���

```shell
# �е�����֧
git checkout main
# ��ȡ����֧���������֧
# �����ʾ��fatal: no such remote or remote group: origin
# git remote add origin https://github.com/sparkling-wild-fire/zenger.github.blog/
# Ȼ�� git checkout -b  remote -v
#�������fatal: refusing to merge unrelated histories   => �� --allow-unrelated-histories
git pull origin main --allow-unrelated-histories
# �ϲ����ط�֧
git merge company 
# �ύ
git push origin main
```


clion ��ô���з�֧�ϲ���
## HEAD

���ύ�����ƶ�
���Կ�������ʼǵ�ͼ�е��ύ��֧������ύ�������±ʼǼ�¼����ڸ��ӵ��ύ�����ƶ���

�����˽���HEAD��HEAD ����ָ��ǰ��֧�����һ���ύ��¼��������޸��ύ���� Git ����ǴӸı� HEAD ��ָ��ʼ�ġ�

[�ƶ���](https://zhuanlan.zhihu.com/p/459542346)