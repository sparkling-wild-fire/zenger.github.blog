//给定一个正整数 n ，将其拆分为 k 个 正整数 的和（ k >= 2 ），并使这些整数的乘积最大化。 
//
// 返回 你可以获得的最大乘积 。 
//
// 
//
// 示例 1: 
//
// 
//输入: n = 2
//输出: 1
//解释: 2 = 1 + 1, 1 × 1 = 1。 
//
// 示例 2: 
//
// 
//输入: n = 10
//输出: 36
//解释: 10 = 3 + 3 + 4, 3 × 3 × 4 = 36。 
//
// 
//
// 提示: 
//
// 
// 2 <= n <= 58 
// 
//
// Related Topics 数学 动态规划 👍 1430 👎 0


//leetcode submit region begin(Prohibit modification and deletion)
class Solution {
public:
    int integerBreak(int n) {
        // dp[n]=max(dp[x]*dp[n-x])  x=【2,n/2】
        if(n<3) return 1;
        if(n==3) return 2;
        vector<int> dp(n+1,0);
        // 这几个是拆分比不拆分还小的，得统一起来，所以都初始化了
        dp[1]=1;
        dp[2]=2;
        dp[3]=3;
        for(int idx=4;idx<=n;++idx){
            for(int j=1;j<=(idx+1)/2;++j){
                dp[idx]=max(dp[idx],dp[idx-j]*dp[j]);
            }
        }
        return dp[n];
    }
};


























//leetcode submit region end(Prohibit modification and deletion)
