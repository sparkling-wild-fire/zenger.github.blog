# dfs

## 24点算法

[牛客链接](https://www.nowcoder.com/share/jump/1709905961700485932426)

dfs+回溯（dfs都要回溯吧）：用一个数组区分4个数中，哪些是未被使用的，然后对4种运算进行列举，其实时间复杂度上和穷举一样的，都是O(n!)

01背包的暴力算法就是利用回溯，回溯能降低时间复杂度吗？

```c++
#include <iostream>
#include<vector>
#include<bitset>
using namespace std;

vector<double> a(4);   // 注意有除法，用double别用int

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
            bt[i]=0;   // 回溯的时候将标志置为0
        }
    }
}

void solve(){
    dfs(0,0);
    flag ? cout << "true\n" : cout << "false\n";
}

int main() {
    while (cin >> a[0] >> a[1] >> a[2] >> a[3]) { // 注意 while 处理多个 case
        bt=0;
        flag=false;
        solve();
    }
}
```