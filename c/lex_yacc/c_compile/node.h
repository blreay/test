#include <sys/types.h>

#define JES_NO_DATA 1   
#define JES_JOBRC_LEN 5 
/*Define structure for job management data.*/
typedef struct _jes2_db_jobparam {
    int jobid;
    char jobname[128 + 1];
    char jobclass;
    short prty;
    char status[64 + 1];
    long submittime;
    char typrun[32 + 1];
    char owner[128 + 1];
    char jobtype[32];
    char execgrp[256 + 1];
    long machine;
    long grpid;
    long srvid;
    long srvpid;
    long exectime;
    long endtime;
    pid_t jobpid;  
    char jobrc[JES_JOBRC_LEN + 1];  /*EJR return code */
    long u_sec;
    long u_usec;
    long s_sec;
    long s_usec;
    char jobscript[2048 + 1];
    char ejroption[256 + 1];
    char shelloption[256 + 1];
    int inputtype;              /*How job is input to JES. 0:by file; 1:by buffer */
    char clientmode[32 + 1];
    long cltiddata1;
    long cltiddata2;
    long cltiddata3;
    long cltiddata4;
    char profileContent[1024 + 1];  /*jes security profile content string */
    char jobenv[1024 + 1];      /*environment variables to be set when executing a job */
/* Add for scheduler  BEGIN*/
	int rc;
/* Add for scheduler  END*/
} JES2_DB_JOBPARAM;
/* 定义树结点的权举类型 */
typedef enum { TYPE_CONTENT, TYPE_INDEX, TYPE_OP, TYPE_STR, TYPE_STEP } NodeEnum;

/* 操作符 */
typedef struct {
    int name; /* 操作符名称 */
    int num; /* 操作元个数 */
    struct NodeTag * node[100]; /* 操作元地址 可扩展 */
} OpNode;
typedef struct NodeTag {
	JES2_DB_JOBPARAM job;
    NodeEnum type; /* 树结点类型 */
    /* Union 必须是最后一个成员 */
     union { 
        float content; /* 内容 */
        char* str; /* 内容 */
        int index; /* 索引 */
        OpNode op; /* 操作符对象 */
    };

} Node;

struct VarIndex
{
	JES2_DB_JOBPARAM job;
    float val;
    char mark[100];
};

struct VarDefine
{
    int index;
    char * name;
};

#define USER_DEF_NUM 259 /* Yacc编译的保留字开始索引 */

#define MAX_VARS 100     /* 最多变量数 */
#define MAX_DEFS 20      /* 最多保留字数 */

#define MAX_BUFF_COLS 40   /* 分析语句最多行数 */
#define MAX_BUFF_ROWS 40   /* 分析语句每行最多字符数 */

extern struct VarIndex G_Var[MAX_VARS];  /* 存储的变量数组 */
extern struct VarDefine G_Def[MAX_DEFS]; /* 系统保留字变量 */

extern int G_iVarMaxIndex;   /* 变量目前总数 */
extern int G_iVarCurIndex;   /* 当前操作变量索引 */

extern char G_sBuff[MAX_BUFF_ROWS][MAX_BUFF_COLS];  /* 存储分析语句 */
extern int G_iBuffRowCount;  /* 当前语句行数 */
extern int G_iBuffColCount;  /* 当前语句列数 */

/* 是否打印调试信息的开关 */
#define PARSE_DEBUG

#define JES_TRACE_ERROR   0
#define JES_TRACE_WARN    1
#define JES_TRACE_INFO    2
#define JES_TRACE_DEBUG   3
#define JES_TRACE_DUMP    4

#define JES_ERR(...)  jes_log(JES_TRACE_ERROR,__func__,##__VA_ARGS__)
#define JES_WARN(...) jes_log(JES_TRACE_WARN,__func__,##__VA_ARGS__)
#define JES_INFO(...) jes_log(JES_TRACE_INFO,__func__,##__VA_ARGS__)
#define JES_DBG(...)  jes_log(JES_TRACE_DEBUG,__func__,##__VA_ARGS__)
#define JES_DUMP(...) jes_log(JES_TRACE_DUMP,__func__,##__VA_ARGS__)

#define JES_TRACE_LEVEL_STR_LEN 64
#define JES_TIME_STR_LEN 64
#define JES_FILE_PATH_LEN 1024
#define NC(A) (A==NULL?"NULL":A)

 /* 节点最大文本宽度 */
 #define MAX_NODE_TEXT_LEN 10
 /* 节点最大子节点个数 */
 #define MAX_SUBNODE_COUNT 5
 
 /* 节点宽度 */
 #define NODE_WIDTH  4
 
 #define MAX_NODE_COUNT    100
 
 /* 排序后 树结点 */
 #define MAX_TREE_WIDTH 20
 #define MAX_TREE_DEEP  10

