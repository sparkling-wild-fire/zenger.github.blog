# dfs

## 24���㷨

[ţ������](https://www.nowcoder.com/share/jump/1709905961700485932426)

dfs+���ݣ�dfs��Ҫ���ݰɣ�����һ����������4�����У���Щ��δ��ʹ�õģ�Ȼ���4����������о٣���ʵʱ�临�Ӷ��Ϻ����һ���ģ�����O(n!)

01�����ı����㷨�������û��ݣ������ܽ���ʱ�临�Ӷ���

```c++
#include <iostream>
#include<vector>
#include<bitset>
using namespace std;

vector<double> a(4);   // ע���г�������double����int

bitset<4> bt;
bool flag=false;

void dfs(int u, int res){
    if(flag) return;
    if(u==4){
        if(res==24){flag=true;}
        return;
    }
    for(int i=0;i<4;++i){
        if(bt[i]==0){
            bt[i]=1;
            dfs(u+1,res+a[i]);
            dfs(u+1,res-a[i]);
            dfs(u+1,res*a[i]);
            dfs(u+1,res/a[i]);
            bt[i]=0;   // ���ݵ�ʱ�򽫱�־��Ϊ0
        }
    }
}

void solve(){
    dfs(0,0);
    flag ? cout << "true\n" : cout << "false\n";
}

int main() {
    while (cin >> a[0] >> a[1] >> a[2] >> a[3]) { // ע�� while ������ case
        bt=0;
        flag=false;
        solve();
    }
}
```