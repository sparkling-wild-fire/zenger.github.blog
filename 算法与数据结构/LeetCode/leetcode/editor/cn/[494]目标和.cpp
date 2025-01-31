//给你一个非负整数数组 nums 和一个整数 target 。 
//
// 向数组中的每个整数前添加 '+' 或 '-' ，然后串联起所有整数，可以构造一个 表达式 ： 
//
// 
// 例如，nums = [2, 1] ，可以在 2 之前添加 '+' ，在 1 之前添加 '-' ，然后串联起来得到表达式 "+2-1" 。 
// 
//
// 返回可以通过上述方法构造的、运算结果等于 target 的不同 表达式 的数目。 
//
// 
//
// 示例 1： 
//
// 
//输入：nums = [1,1,1,1,1], target = 3
//输出：5
//解释：一共有 5 种方法让最终目标和为 3 。
//-1 + 1 + 1 + 1 + 1 = 3
//+1 - 1 + 1 + 1 + 1 = 3
//+1 + 1 - 1 + 1 + 1 = 3
//+1 + 1 + 1 - 1 + 1 = 3
//+1 + 1 + 1 + 1 - 1 = 3
// 
//
// 示例 2： 
//
// 
//输入：nums = [1], target = 1
//输出：1
// 
//
// 
//
// 提示： 
//
// 
// 1 <= nums.length <= 20 
// 0 <= nums[i] <= 1000 
// 0 <= sum(nums[i]) <= 1000 
// -1000 <= target <= 1000 
// 
//
// Related Topics 数组 动态规划 回溯 👍 2053 👎 0


//leetcode submit region begin(Prohibit modification and deletion)
class Solution {
public:
    int findTargetSumWays(vector<int>& nums, int target) {
        // 先计算总和*-1，然后每个物品的价格就固定了*2，选一些物品使得背包里的价值为target
        // d[p]为价值为p的方式数，公式为d[p]=d[p]+d[p-val*2]
        for(int i=0;i<nums.size();++i){
            target+=nums[i];
        }

        vector<int> dp(target+1,0);

        // 初始化,只放自己，相应的target位置加1
//        for(int i=0;i<nums.size();++i){
//            dp[nums[i]*2]=1;
//        }
        dp[nums[0]*2]=1;

        for(int i=1;i<nums.size();++i){
            for(int j=target;j>0;j=j-2){
                if((j-2*nums[i])>0) {
                    dp[j] +=  dp[j - 2 * nums[i]];
                    if(j==nums[i]*2) dp[j]++;
                }
            }
        }

        return dp[target];
    }
};
//leetcode submit region end(Prohibit modification and deletion)
