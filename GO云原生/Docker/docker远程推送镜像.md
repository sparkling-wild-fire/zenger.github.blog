# dockerԶ�����;���

## ����Զ�� dockerhub �ֿ�

��¼��ַ��https://hub.docker.com/

û���˺ž�ע��һ������֤��ݺ�������½��棺

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304071716938.png" alt="202304071716938" width="450px">

�������ؾ���
```shell
# docker commit ������  ������:�汾��
docker commit centos7s centos7_img:v2
```

���ӱ��ؾ����Զ�ֿ̲⣺
```shell
# docker tag ���ؾ�����:�汾�� dockerhub�û���/�ֿ���:�汾�ţ�Ӧ���ټ�һ��/��������
docker tag centos7_img:v2 zenger01/develop_linux:v2
```

���ض˵�¼�˻���push����:
```shell
docker login
# Ȼ����������docker�û���,����.

# push���ؾ��񵽲ֿ�
docker push zjh96/mmdetection_zjh:v1
```

�ϴ��ɹ���

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304071804890.png" alt="202304071804890" width="450px">


