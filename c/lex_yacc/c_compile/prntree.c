 #include <stdio.h>
 #include <string.h>
 #include "node.h"
 #include "lexya_e.tab.h"
 
 /* 树结点 图信息 */
 struct NodePoint {
   
   int x;  /* 标准坐标X */
   int y;  /* 标准坐标Y */
   
   char text[MAX_NODE_TEXT_LEN]; /* 显示内容 */
   int textoffset1;
   int textoffset2;
   
   int parent; /* 父结点索引 */
   int idx;    /* 当前结点索引 */
   
   Node * node; /* 实际内存树节点 */
   
   int oppx;    /* 相对坐标 */
   int oppx_mid;/* 相对坐标中值 */
   
   int childnum; /* 子结点个数 */
   int child[MAX_SUBNODE_COUNT]; /* 子结点索引 */
   
 };
 
 struct NodePoint G_TreeNodePoint[MAX_NODE_COUNT]; /* 树结点全局全量 */
 
 int G_iNodeCount; //存储树结点个数
 int G_iNodeParent;//存储树的父结点
 
 struct NodePoint * G_pTreeNodeOrder[MAX_TREE_DEEP][MAX_TREE_WIDTH]; /* 树结点按层次的排序数组 */
 int G_iTreeNodeOrderCount[MAX_TREE_DEEP]; /* 每层树结点个数 */ 
 
 int G_iDeepCount; /* 层次深度 */ 
 int G_iMinNodeXValue; /* 树结点最小x值 */
 int G_iGraphNum=-1; /* 图个数 */
 
 /* 函数定义 */
 
 void GraphNode(Node *, int, int, int);
 void GraphNode_Set(int, int, int, char *, Node *);
 void GraphNode_PrintVars();
 
 void GraphNode_Order();
 void GraphNode_Adjust();
 void GraphNode_FillPos();
 
 void GraphNode_Print();
 
 struct NodePoint * NodeFind(struct NodePoint *, struct NodePoint *);
 void NodeAdjust(struct NodePoint *, int tmp);
 
 void PrintInfo(int, char *);
 void InitVars();
 
 int GetOffset(int, int, int);
 
 char * itoa(int,char*);
 
 /* 供内部调用函数 */
 int zzy_NodeExecute(Node *p) {
   
   G_iNodeCount=-1;
   G_iNodeParent=-1;
   G_iMinNodeXValue=0;
   
   InitVars();
   
   GraphNode(p, 0, 0, G_iNodeParent);
   
   GraphNode_Order();
   GraphNode_PrintVars();
   GraphNode_Adjust();
   GraphNode_FillPos();
   GraphNode_PrintVars();
   
   GraphNode_Print();
   
   return 0;
 }
 
 /* 主递归函数，用于填充全局变量值 */
 void GraphNode(Node *p, int xoffset, int yoffset, int parent) {
   
   char sWord[MAX_NODE_TEXT_LEN];
   char *sNodeText;
   int i;
   
   G_iNodeCount++;
   
   if(parent!=-1) {
     G_TreeNodePoint[parent].child[G_TreeNodePoint[parent].childnum]=G_iNodeCount;
     G_TreeNodePoint[parent].childnum++;  
   }  
 
   switch(p->type) {
     
     case TYPE_CONTENT: 
       sprintf (sWord, "c(%g)", p->content); 
       sNodeText = sWord;
       GraphNode_Set (xoffset, yoffset, parent, sNodeText, p);
       break;
       
     case TYPE_INDEX:   
       sprintf (sWord, "idx(%s)",NC(G_Var[p->index].mark)); 
       sNodeText = sWord;
       GraphNode_Set (xoffset, yoffset, parent, sNodeText, p);
       break;
       
     case TYPE_OP:
       switch(p->op.name){
         case WHILE:  sNodeText = "while"; break;
         case IF:     sNodeText = "if";    break;
         case FOR:    sNodeText = "for";   break;
         case PRINT:  sNodeText = "print"; break;
         case ';':    sNodeText = "[;]";   break;
         case '=':    sNodeText = "[=]";   break;
         case UMINUS: sNodeText = "[_]";   break;
         case '+':    sNodeText = "[+]";   break;
         case '-':    sNodeText = "[-]";   break;
         case '*':    sNodeText = "[*]";   break;
         case '/':    sNodeText = "[/]";   break;
         case '<':    sNodeText = "[<]";   break;
         case '>':    sNodeText = "[>]";   break;
         case GE:     sNodeText = "[>=]";  break;
         case LE:     sNodeText = "[<=]";  break;
         case NE:     sNodeText = "[!=]";  break;
         case EQ:     sNodeText = "[==]";  break;
         case AND:    sNodeText = "[&&]";  break;
         case OR:     sNodeText = "[||]";  break;
         case ADD_T:  sNodeText = "[++v]";  break;
         case MUS_T:  sNodeText = "[--v]";  break;
         case ADD_TT: sNodeText = "[v++]";  break;
         case MUS_TT: sNodeText = "[v--]";  break;
          
       }
       GraphNode_Set (xoffset, yoffset, parent, sNodeText, p);
 
       for (i=0; i<p->op.num; i++) {
         GraphNode(p->op.node[i], GetOffset(p->op.num,i+1,2), yoffset+1, GetNodeIndex(p));
       }
       break;
   }
   
 }
 
 /* 树结点赋值函数 */
 void GraphNode_Set(int xoffset, int yoffset, int parent, char * text, Node * p ) {
 
   int iBaseValue;
   
   if(parent<=-1)
     iBaseValue=0;
   else
     iBaseValue=G_TreeNodePoint[parent].x;
 
   G_TreeNodePoint[G_iNodeCount].x = (iBaseValue + xoffset) ;
   G_TreeNodePoint[G_iNodeCount].y = yoffset;
 
   strcpy(G_TreeNodePoint[G_iNodeCount].text, text);
   
   iBaseValue = strlen(text);
   if(iBaseValue&1) {
    G_TreeNodePoint[G_iNodeCount].textoffset1 = strlen(text)/2 ;
    G_TreeNodePoint[G_iNodeCount].textoffset2 = strlen(text) - G_TreeNodePoint[G_iNodeCount].textoffset1 ;
  }
  else {
    G_TreeNodePoint[G_iNodeCount].textoffset1 = strlen(text)/2 - 1;
    G_TreeNodePoint[G_iNodeCount].textoffset2 = strlen(text) - G_TreeNodePoint[G_iNodeCount].textoffset1 ; 
  }
  
   G_TreeNodePoint[G_iNodeCount].parent = parent;
   G_TreeNodePoint[G_iNodeCount].idx = G_iNodeCount;
   G_TreeNodePoint[G_iNodeCount].node = p;
 
   G_TreeNodePoint[G_iNodeCount].oppx = 0;
   G_TreeNodePoint[G_iNodeCount].oppx_mid = 0;
 
   G_TreeNodePoint[G_iNodeCount].child[0] = 0;
   G_TreeNodePoint[G_iNodeCount].childnum = 0;
 
   /* 记录最小值 */
  if(G_TreeNodePoint[G_iNodeCount].x<G_iMinNodeXValue)G_iMinNodeXValue=G_TreeNodePoint[G_iNodeCount].x;
 
 
 }
 
 /* 根据树结点层次排序 */
 void GraphNode_Order() {
 
   int i;
   int iDeep;
   
   G_iDeepCount=-1;
 
   for(i=0;i<=G_iNodeCount;i++) {
    G_TreeNodePoint[i].x = G_TreeNodePoint[i].x - G_iMinNodeXValue + 1;
     iDeep=G_TreeNodePoint[i].y;
     G_iTreeNodeOrderCount[iDeep]++;
     G_pTreeNodeOrder[iDeep][G_iTreeNodeOrderCount[iDeep]]=&G_TreeNodePoint[i];
     if(iDeep>G_iDeepCount)G_iDeepCount=iDeep;
   }
 
 }
 
 /* 填充树结点真实坐标，相对坐标 */
 void GraphNode_FillPos() {
  
  int iInt;
   int iBlank;
   int idx;
   int i,j;
   
   for(j=0;j<=G_iDeepCount;j++) {
     iBlank = 0;
     for(i=0;i<=G_iTreeNodeOrderCount[j];i++) {
       idx=G_pTreeNodeOrder[j][i]->idx;
       if(i!=0) {
         iInt = (G_TreeNodePoint[idx].x - G_TreeNodePoint[G_pTreeNodeOrder[j][i-1]->idx].x) * NODE_WIDTH ;
         iBlank = iInt - G_TreeNodePoint[idx].textoffset1 - G_TreeNodePoint[G_pTreeNodeOrder[j][i-1]->idx].textoffset2;
       }
       else {
         iInt = (G_TreeNodePoint[idx].x) * NODE_WIDTH ;
         iBlank = iInt - G_TreeNodePoint[idx].textoffset1;
       }
       G_TreeNodePoint[idx].oppx = iInt ;
       G_TreeNodePoint[idx].oppx_mid = iBlank ;  
    } 
  }
 
 }
 
 /* 调整树结点位置 */
 void GraphNode_Adjust() {
 
   int i,j;
   int tmp;
   
   for(i=G_iDeepCount;i>=0;i--)
   
     for(j=0;j<=G_iTreeNodeOrderCount[i];j++)
     
       if(j!=G_iTreeNodeOrderCount[i]) {
        
        if(j==0) {
         tmp = G_pTreeNodeOrder[i][j]->textoffset1 / NODE_WIDTH ;
         if(tmp>=1)
          NodeAdjust(NodeFind(G_pTreeNodeOrder[i][j], G_pTreeNodeOrder[i][j+1]), tmp);
        }
        
       tmp = G_pTreeNodeOrder[i][j]->x - G_pTreeNodeOrder[i][j+1]->x + ( G_pTreeNodeOrder[i][j]->textoffset2 + G_pTreeNodeOrder[i][j+1]->textoffset1 ) / NODE_WIDTH + 1;
       if(tmp>=1)
         NodeAdjust(NodeFind(G_pTreeNodeOrder[i][j], G_pTreeNodeOrder[i][j+1]), tmp);
 
      }
      
 }
 
 /* 查找需要调整的子树的根结点 
 struct NodePoint * NodeFind(struct NodePoint * p) {
   
   while(p->parent!=-1 && G_TreeNodePoint[p->parent].child[0]==p->idx) {
     p=&G_TreeNodePoint[p->parent];
   } 
   return p;
   
 }
 */
 
 /* 查找需要调整的子树的根结点 */
 struct NodePoint * NodeFind(struct NodePoint * p1, struct NodePoint * p2) {
   
   while(p2->parent!=-1 && p1->parent!=p2->parent) {
     p1=&G_TreeNodePoint[p1->parent];
     p2=&G_TreeNodePoint[p2->parent];
   } 
   return p2;
   
 }
 
 /* 递归调整坐标 */
 void NodeAdjust(struct NodePoint * p, int tmp) {
   
   int i;
   if(p->childnum==0)
     p->x=p->x+tmp;
   else {
     p->x=p->x+tmp;
     for(i=0;i<=p->childnum-1;i++)
       NodeAdjust(&G_TreeNodePoint[p->child[i]], tmp);
   }
   
 }
 
 /* 打印内存变量 */
 void GraphNode_PrintVars() {
 
  printf("\n");
   int i,j;
   for(i=0;i<=G_iNodeCount;i++) {
     printf("ID:%2d x:%2d y:%2d txt:%6s ofs:%d/%d rx:%2d b:%2d pa:%2d num:%2d child:",
     i, 
     G_TreeNodePoint[i].x, 
     G_TreeNodePoint[i].y, 
     G_TreeNodePoint[i].text, 
     G_TreeNodePoint[i].textoffset1,
     G_TreeNodePoint[i].textoffset2,
     G_TreeNodePoint[i].oppx,
     G_TreeNodePoint[i].oppx_mid,
     G_TreeNodePoint[i].parent,
     G_TreeNodePoint[i].childnum
     );
     for(j=0;j<=G_TreeNodePoint[i].childnum-1;j++)
       printf("%d ",G_TreeNodePoint[i].child[j]);
     printf("\n");
   }
  printf("\n");
 }
 
 /* 打印语法树 */
 void GraphNode_Print() {
 
  G_iGraphNum++;
   printf("<Graph %d>\n", G_iGraphNum);
   
   int idx;
   int i,j;
   
   for(j=0;j<=G_iDeepCount;j++) {
     
     /* 打印首行结点 [] */ 
     for(i=0;i<=G_iTreeNodeOrderCount[j];i++) {
       idx=G_pTreeNodeOrder[j][i]->idx;
       PrintInfo( G_TreeNodePoint[idx].oppx_mid , G_TreeNodePoint[idx].text); 
     }
     printf("\n");
     
     if(j==G_iDeepCount)return; /* 结束 */  
     
     /* 打印第二行分隔线 |  */
     int iHave=0;
     for(i=0;i<=G_iTreeNodeOrderCount[j];i++) {
       idx=G_pTreeNodeOrder[j][i]->idx;
       if(G_pTreeNodeOrder[j][i]->childnum) {
        if(iHave==0)
          PrintInfo( G_TreeNodePoint[idx].oppx , "|"); 
         else 
          PrintInfo( G_TreeNodePoint[idx].oppx - 1 , "|"); 
         iHave=1;
       }
       else
         PrintInfo( G_TreeNodePoint[idx].oppx , ""); 
     }
     printf("\n");
     
     /* 打印第三行连接线 ------   */
     for(i=0;i<=G_iTreeNodeOrderCount[j+1];i++) {
       idx=G_pTreeNodeOrder[j+1][i]->idx;
       int k;
       if(i!=0 && G_pTreeNodeOrder[j+1][i]->parent==G_pTreeNodeOrder[j+1][i-1]->parent) {
         for(k=0;k<=G_pTreeNodeOrder[j+1][i]->oppx - 2; k++) 
           printf("-");
         printf("|");
       }
       else if(i==0) {
         PrintInfo( G_TreeNodePoint[idx].oppx , "|"); 
       }
       else {
        PrintInfo( G_TreeNodePoint[idx].oppx - 1 , "|"); 
      }
     }
     printf("\n");
     
     /* 打印第四行分割连接线 | */
     for(i=0;i<=G_iTreeNodeOrderCount[j+1];i++) {
       idx=G_pTreeNodeOrder[j+1][i]->idx;
       if(i==0)
        PrintInfo( G_TreeNodePoint[idx].oppx , "|"); 
       else
        PrintInfo( G_TreeNodePoint[idx].oppx - 1 , "|"); 
     }
     printf("\n");
     
   }
 
 
 }
 
 /* 获取节点位移 */
 int GetOffset(int count, int idx, int base) {
 
   if(count&1)
     return (idx-(count+1)/2)*base;
   else
     return idx*base-(count+1)*base/2;
 
 }
 
 /* 根据节点地址获取内存索引 */
 int GetNodeIndex(Node * p) {
 
   int i;
   for(i=G_iNodeCount;i>=0;i--) {
     if(p==G_TreeNodePoint[i].node)return G_TreeNodePoint[i].idx;
   }
 
 }
 
 /* 初始化变量 */
 void InitVars() {
 
 /*
   int i,j;
   for(j=0;j<=MAX_TREE_DEEP-1;j++)
     for(i=0;i<=MAX_TREE_WIDTH-1;i++)
       G_pTreeNodeOrder[j][i]=0;
 */
   
   int i;
   for(i=0;i<=MAX_TREE_DEEP-1;i++)
     G_iTreeNodeOrderCount[i]=-1;
 }
 
 /* 打印固定信息 */
 void PrintInfo(int val, char * str) {
 
   char sInt[10];
   char sPrint[20];
   itoa( val , sInt);
   strcpy(sPrint, "%");
   strcat(sPrint, sInt);
   strcat(sPrint,"s");
   printf(sPrint,"");
   printf(str);
 
 }
 
 /* int 转 char */
 char * itoa(int n, char *buffer) {
   
   int i=0,j=0;
   int iTemp;  /* 临时int  */
   char cTemp; /* 临时char */
 
   do
   {
     iTemp=n%10;
     buffer[j++]=iTemp+'0';
     n=n/10;
   }while(n>0);
     
   for(i=0;i<j/2;i++)
   {
     cTemp=buffer[i];
     buffer[i]=buffer[j-i-1];
     buffer[j-i-1]=cTemp;
   }
   buffer[j]='/0';
   return buffer;
   
 }
