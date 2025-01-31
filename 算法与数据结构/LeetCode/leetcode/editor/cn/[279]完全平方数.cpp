//给你一个整数 n ，返回 和为 n 的完全平方数的最少数量 。 
//
// 完全平方数 是一个整数，其值等于另一个整数的平方；换句话说，其值等于一个整数自乘的积。例如，1、4、9 和 16 都是完全平方数，而 3 和 11 不是。
// 
//
// 
//
// 示例 1： 
//
// 
//输入：n = 12
//输出：3 
//解释：12 = 4 + 4 + 4 
//
// 示例 2： 
//
// 
//输入：n = 13
//输出：2
//解释：13 = 4 + 9 
//
// 
//
// 提示： 
//
// 
// 1 <= n <= 10⁴ 
// 
//


//leetcode submit region begin(Prohibit modification and deletion)
class Solution {
public:
    int numSquares(int n) {
        // 有1到100个物品，每个物品的价值是x^2
        // 公式：dp[j]=min(dp[j],dp[j-x^2]+1)
        vector<int> dp(n+1,n+1);
        dp[0]=0;
        for(int i=0;i<=100;++i){
            int val = i*i;
            for(int j=val;j<=n;++j){
                dp[j]=min(dp[j],dp[j-val]+1);
            }
        }
        return dp[n];
    }
};
//leetcode submit region end(Prohibit modification and deletion)
