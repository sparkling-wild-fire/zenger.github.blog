# git��������

�����Ҫ��һ���ļ�ͬ������һ���ļ�����Otrade����ĳһ���ļ�������Ҫͬ������һ���ļ�����

```shell
git checkout origin/dev-ALGOV202301.02.000.LS -- ./algo_mysql/logic/scheme_mgr/quant_schemehandle/LS_LHTOOLS_SCHEMESUB_INFO_MNG.logicservice
```

�����Ҫ��ĳ��֧A��һ���ύͬ������һ����֧B��
```shell
# 1.�ڷ�֧A�ϲ鿴����ύ��hashid
# 2.�л���Ŀ���֧
# 3.ִ������ 
git cherry-pick <commit-hash>
# �磺git cherry-pick 4aae810bd2c417a1f05f1f57ba70a73ef3ece7bf
# 4.cherry-pick��������г�ͻ���Ƚ����ͻ��Ȼ��
git add <resolved-files>
git cherry-pick --continue
# 5. ���cherry-pick�ɹ����ύ�ͻᱻ���Ƶ���ǰ��֧
# tip: ������̿����޸��ύ��Ϣ�������Ҫ�����޸ģ�Ҳ�����Ȼ����ٴ��ύ git reset --soft HEAD~123456...
```

���cherry-pick���̳������⣺`fatal: unknown write failure on standard output`

��IDEҪ��git bash��������ͨ��bash
