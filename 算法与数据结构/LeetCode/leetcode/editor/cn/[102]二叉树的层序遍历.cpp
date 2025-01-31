//给你二叉树的根节点 root ，返回其节点值的 层序遍历 。 （即逐层地，从左到右访问所有节点）。 
//
// 
//
// 示例 1： 
// 
// 
//输入：root = [3,9,20,null,null,15,7]
//输出：[[3],[9,20],[15,7]]
// 
//
// 示例 2： 
//
// 
//输入：root = [1]
//输出：[[1]]
// 
//
// 示例 3： 
//
// 
//输入：root = []
//输出：[]
// 
//
// 
//
// 提示： 
//
// 
// 树中节点数目在范围 [0, 2000] 内 
// -1000 <= Node.val <= 1000 
// 
//
// Related Topics 树 广度优先搜索 二叉树 👍 2047 👎 0


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
    vector<vector<int>> levelOrder(TreeNode* root) {
        vector<vector<int>> res;
        queue<TreeNode*> que;
        if(root==NULL) return res;
        vector<int> tmp={root->val};
        res.push_back(tmp);
        que.push(root);
        while(!que.empty()){
            int nodeLevNum=tmp.size();
            vector<int>().swap(tmp);
            while(nodeLevNum>0){
                TreeNode* curNode = que.front();
                que.pop();
                nodeLevNum--;
                if(curNode->left){
                    tmp.push_back(curNode->left->val);
                    que.push(curNode->left);
                }
                if(curNode->right){
                    tmp.push_back(curNode->right->val);
                    que.push(curNode->right);
                }
            }
            if(tmp.size()>0) {
                res.push_back(tmp);
            }
        }
        return res;
    }
};
//leetcode submit region end(Prohibit modification and deletion)
