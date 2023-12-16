```c++

vector<int> getRight(TNode *root){
    queue<TNode*> cur;
    int level=0;
    cur.push(root);
    vector<int> res;
    while(!cur.empty()){
        TNode* tcur=cur.pop();
        if(tcur->left!=null){
            cur.push(tcur->left);    
        }
        if(tcur->right!=null){
            tcur.push(right);
        }
        
    }
}

```