# kmp

```c++
class Solution {
public:
    void next(string modstr, vector<int>& nextArr){
        int j=0;
        int i=1;
        nextArr[0]=j;
        while(i<modstr.size() && j<modstr.size()){
            while(modstr[i]!=modstr[j] && j>0){
                // j--; ע�ⲻ��j--
                // ����aabaabaaf��ģʽ����i -> f
                j=nextArr[j-1];
            }
            if(modstr[i]==modstr[j]){
                ++j;
            }
            nextArr[i++]=j;
        }
    }

    int strStr(string haystack, string needle) {
        vector<int> pre(needle.size(),0);
        next(needle,pre);

        for(int ind=0;ind<pre.size();++ind){
            cout<<pre[ind]<<endl;
        }

        int i=0;
        int j=0;
        while(i<haystack.size()){
            while(haystack[i]==needle[j] && i<haystack.size() && j<needle.size()){
                ++i;
                ++j;
            }

            if(j==needle.size()){
                return i-needle.size();
            }

            // �߽紦��j=0�����
            // ���ﲻ���ж�haystack[i]!=needle[j]���϶��ǲ����ڲ������ߵ����
            if(j==0 ){
                i++;
            }
            j=j==0?0:pre[j-1];   
        }
        return -1;
    }
};
```