//小偷又发现了一个新的可行窃的地区。这个地区只有一个入口，我们称之为
// root 。 
//
// 除了
// root 之外，每栋房子有且只有一个“父“房子与之相连。一番侦察之后，聪明的小偷意识到“这个地方的所有房屋的排列类似于一棵二叉树”。 如果 两个直接相连的
//房子在同一天晚上被打劫 ，房屋将自动报警。 
//
// 给定二叉树的 root 。返回 在不触动警报的情况下 ，小偷能够盗取的最高金额 。 
//
// 
//
// 示例 1: 
//
// 
//
// 
//输入: root = [3,2,3,null,3,null,1]
//输出: 7 
//解释: 小偷一晚能够盗取的最高金额 3 + 3 + 1 = 7 
//
// 示例 2: 
//
// 
//
// 
//输入: root = [3,4,5,1,3,null,1]
//输出: 9
//解释: 小偷一晚能够盗取的最高金额 4 + 5 = 9
// 
//
// 
//
// 提示： 
//
// 
// 
//
// 
// 树的节点数在 [1, 10⁴] 范围内 
// 0 <= Node.val <= 10⁴ 
// 
//
// Related Topics 树 深度优先搜索 动态规划 二叉树 👍 2032 👎 0


//leetcode submit region begin(Prohibit modification and deletion)
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    vector<int> robSelect(TreeNode* root){
        vector<int> curRes(2,0);
        if(root==NULL) return curRes;
        vector<int> leftVec=robSelect(root->left);
        vector<int> rightVec=robSelect(root->right);

        // 0是选，1是不选
        // 注意在不选的时候，要取下个节点选与不选的最大值
        curRes[0]=root->val+leftVec[1]+rightVec[1];
        curRes[1]=max(leftVec[0],leftVec[1])+max(rightVec[0],rightVec[1]);

        return curRes;
    }

    int rob(TreeNode* root) {
        // 用dp(体现在节点的值实时更改)后续遍历二叉树
        // 选根节点，那就不能选左右两节点，最大值就是自己加上孙子节点选与不选的最大值
        vector<int> res= robSelect(root);
        return max(res[0],res[1]);
    }
};
//leetcode submit region end(Prohibit modification and deletion)
