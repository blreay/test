#include <stdio.h>
#include "node.h"
#include "lexya_e.tab.h"

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
//extern struct NodePoint G_TreeNodePoint[MAX_NODE_COUNT]; /* 树结点全局全量 */ 
extern int G_iNodeCount; //存储树结点个数
extern int G_iNodeParent;//存储树的父结点 
extern struct NodePoint * G_pTreeNodeOrder[MAX_TREE_DEEP][MAX_TREE_WIDTH]; /* 树结点按层次的排序数组 */
extern int G_iTreeNodeOrderCount[MAX_TREE_DEEP]; /* 每层树结点个数 */ 
extern int G_iDeepCount; /* 层次深度 */ 
extern int G_iMinNodeXValue; /* 树结点最小x值 */
extern int G_iGraphNum; /* 图个数 */

int g_print = 0;
int g_onlyprint = 0;
int g_jobid = 0;

int jobcpy(JES2_DB_JOBPARAM* dst, JES2_DB_JOBPARAM* src) {
	JES_DBG("*** BEGIN dst=%p src=%p", dst, src);
	memcpy(dst, src, sizeof(JES2_DB_JOBPARAM));
	JES_DBG("*** END dst=%p src=%p", dst, src);
}

float NodeExecute(Node *p) {
	JES_DBG("IN p=%p **************", p);
	if (1 == g_print) {
		JES_DBG("*** TREE(%p) BEGIN *************************************", p);
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
		JES_DBG("*** TREE(%p) END *************************************", p);
		if (1 == g_onlyprint) return 0;
	}

	//printf("******* call NodeExecute(%p): #############\n", p);
    if (!p) return 0;
	int i = 0;
	JES_DBG("p->type=%d", p->type);
    switch (p->type) {
    case TYPE_CONTENT : JES_DBG("return value=%f", p->content); return p->content;
    case TYPE_INDEX:   JES_DBG("return index=%f", G_Var[p->index].val);  return G_Var[p->index].val;
    case TYPE_STEP:   JES_DBG("return step.xx=%d", G_Var[p->index].job.rc);  return G_Var[p->index].job.rc;
    case TYPE_OP:
		JES_DBG("p->op.name=%d", p->op.name);
        switch (p->op.name) {
        case FUNCCALL:  
			JES_DBG("******* FUNCCALL ***********************************");
			JES_DBG("******* call function: zzy#############");
			JES_DBG("p->op.name=%d", p->op.name);
			//JES_DBG("p->op.node[0].type=%d", p->op.node[0]->type);
			for (i = 0; i < p->op.num; i++){
				JES_DBG("p->op.node[%d]->type=%d", i, p->op.node[i]->type);
				switch (p->op.node[i]->type) {
				case TYPE_CONTENT: JES_DBG("p->op.node[%d].content=%f",i,  p->op.node[i]->content); break;
				case TYPE_INDEX: JES_DBG("p->op.node[%d].index=%d name=%s", i, p->op.node[i]->index, NC(G_Var[p->op.node[i]->index].mark)); break;
				case TYPE_STR: JES_DBG("p->op.node[%d].str=%s", i, NC(p->op.node[i]->str)); break;
				}
			} 
			JES_DBG("update job information p=%p", p);
			strcpy((p->job).jobscript, p->op.node[1]->str);
			(p->job).jobid = ++g_jobid;
			(p->job).rc = g_jobid+1000;
			JES_DBG("after update job information p=%p", p);
			JES_DBG("p=%p new jobscript = %s(%p)***job=%p p=%p",p, (p->job).jobscript, (p->job).jobscript, p->job, p);
			//printf("******* call function: %g", NodeExecute(p->op.node[0]));
            return 0;
        case FUNC:  
			JES_DBG("******* FUNC ***********************************");
			JES_DBG("******* set value to step (%s) idx=%d", G_Var[p->op.node[0]->index].mark, p->op.node[0]->index); 
			JES_DBG("p->op.name=%d", p->op.name);
			//JES_DBG("p->op.node[0].type=%d", p->op.node[0]->type);
			for (i = 0; i < p->op.num; i++){
				JES_DBG("p->op.node[%d]->type=%d", i, p->op.node[i]->type);
				switch (p->op.node[i]->type) {
				case TYPE_CONTENT: JES_DBG("p->op.node[%d]->content=%f",i,  p->op.node[i]->content); break;
				case TYPE_INDEX: JES_DBG("p->op.node[%d]->index=%d name=%s", i, p->op.node[i]->index, NC(G_Var[p->op.node[i]->index].mark)); break;
				case TYPE_STR: JES_DBG("p->op.node[%d]->str=%s", i, NC(p->op.node[i]->str)); break;
				case TYPE_OP: 
						//Node * p1 = p->op.node[i];
						JES_DBG("p->op.node[%d]->op.name=%d", i,  p->op.node[i]->op.name); 
						switch (p->op.node[i]->op.name) {
						case FUNCCALL:
						case IF:
						/* if (FUNCCALL == p->op.node[i]->op.name) { */
							JES_DBG("before run node[%d], jobscript=%s", i,  p->op.node[i]->job.jobscript); 
							NodeExecute(p->op.node[i]);
							jobcpy(&G_Var[p->op.node[0]->index].job, &p->op.node[i]->job);
							JES_DBG("after run node");
							JES_DBG("after run node jobscript=%s",  (p->op.node[i]->job).jobscript); 
							printf("after run node jobscript=%s job=%p \n",  (p->op.node[i]->job).jobscript, p->op.node[i]->job); 
							break;
						}
						break;
				}
			} 
			JES_DBG("******************************************");
			//printf("******* call function: %g", NodeExecute(p->op.node[0]));
            return 0;
        case WHILE:  while (NodeExecute(p->op.node[0]))NodeExecute(p->op.node[1]);
            return 0;
        case FOR:    NodeExecute(p->op.node[0]);
            while (NodeExecute(p->op.node[1])) {
                NodeExecute(p->op.node[3]);
                NodeExecute(p->op.node[2]);
            }
            return 0;
        case IF:     if (NodeExecute(p->op.node[0])) {
				JES_DBG("******* in IF branch #############");
                NodeExecute(p->op.node[1]);
				jobcpy(&(p->job), &p->op.node[1]->job);
            } else if (p->op.num > 2) {
				JES_DBG("******* in ELSE branch #############");
                NodeExecute(p->op.node[2]);
				jobcpy(&(p->job), &p->op.node[2]->job);
			}
            return 0;
        case PRINT:  printf("%g\n", NodeExecute(p->op.node[0]));
            return 0;
        case SUBMIT:  printf("%g\n", NodeExecute(p->op.node[0]));
            return 0;
        case ';':    NodeExecute(p->op.node[0]);
            return NodeExecute(p->op.node[1]);
        case '=':    
			JES_DBG("******* op.name is = #############");
			switch (p->op.node[0]->type) {
			case TYPE_STEP: 
				JES_DBG("******* in TYPE_STEP branch #############");
				return G_Var[p->op.node[0]->index].job.rc = NodeExecute(p->op.node[1]);
			case TYPE_CONTENT:
				JES_DBG("******* in TYPE_CONTENT branch #############");
				return G_Var[p->op.node[0]->index].val = NodeExecute(p->op.node[1]);
			default:
				JES_DBG("******* in DEFAULT branch #############");
				return G_Var[p->op.node[0]->index].val = NodeExecute(p->op.node[1]);
			}
        case UMINUS: return NodeExecute(p->op.node[0]);
        case '+':    return NodeExecute(p->op.node[0]) + NodeExecute(p->op.node[1]);
        case '-':    return NodeExecute(p->op.node[0]) - NodeExecute(p->op.node[1]);
        case '*':    return NodeExecute(p->op.node[0]) * NodeExecute(p->op.node[1]);
        case '/':    return NodeExecute(p->op.node[0]) / NodeExecute(p->op.node[1]);
        case '<':    return NodeExecute(p->op.node[0]) < NodeExecute(p->op.node[1]);
        case '>':    return NodeExecute(p->op.node[0]) > NodeExecute(p->op.node[1]);
        case GE:     return NodeExecute(p->op.node[0]) >= NodeExecute(p->op.node[1]);
        case LE:     return NodeExecute(p->op.node[0]) <= NodeExecute(p->op.node[1]);
        case NE:     return NodeExecute(p->op.node[0]) != NodeExecute(p->op.node[1]);
        case EQ:     return NodeExecute(p->op.node[0]) == NodeExecute(p->op.node[1]);
        case AND:    return NodeExecute(p->op.node[0]) && NodeExecute(p->op.node[1]);
        case OR:     return NodeExecute(p->op.node[0]) || NodeExecute(p->op.node[1]);
        case ADD_T:  return ++G_Var[p->op.node[0]->index].val;
        case MUS_T:  return --G_Var[p->op.node[0]->index].val;
        case ADD_TT: return G_Var[p->op.node[0]->index].val++;
        case MUS_TT: return G_Var[p->op.node[0]->index].val--;
        }
    }
    return 0;
}
