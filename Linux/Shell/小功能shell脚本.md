# С����shell�ű�

1. ����վ��~/.bashrc
```shell
# Source global definitions
if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi


# User specific aliases and functions
mkdir -p ~/.trash  #��homeĿ¼�´���һ��.trash�ļ��� �� Ŀ¼�Ѵ��ڲ��ǻᱨ����
# alias rm=del    #ʹ�ñ���del����rm =>  ����ϵͳ��������滻,��Ϊ�����п��ܻ��õ�rm����
del()        #����del�����ã���rm�����޸�Ϊmv����
{
stamp=$(date "+%Y-%m-%d_%H:%M") # date��ʱ�������ʽ��ֵ
# ���ﲻ���� "~/.trash/"${stamp}"_trash"�����ڵ�ǰĿ¼���½�~,��ɾ�����ļ����ƶ�����ǰĿ¼��~Ŀ¼��
# �������ļ��Ƿ��� rm *ʱ�����������ָ�,ͬʱ����ͬ���ļ�����
subfolder="/home/"${USER}"/.trash/"${stamp}"_trash"
mkdir -p $subfolder
mv $@ $subfolder
}

cleardel()     #����cleardel�����ã���ջ���վ.trash�ļ��У�y��Y��ʾȷ�ϣ�n��ʾȡ��
{
read -p "clear sure[Input 'y' or 'Y' to confirm. && Input 'n' to cancel.]" confirm
[ $confirm == 'y' ] || [ $confirm == 'Y' ] && /bin/rm -rf ~/.trash/*
}

# ��Ҫ������ݣ���ȻArestudio����ʾ�ϴ�Ŀ¼������
# echo "Welcome to zenger's world!"
```

��ʱ����crontabִ���������վ�ű�

ʹ�ã�
- ��Ҫɾ�����ļ��������վ��del �ļ���/*
- ��ջ���վ��cleardel