%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "node.h"
#include <getopt.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <time.h>


/* Get current Time 
   20141229 00:38:17 */
int get_current_time(char *timestr)
{
    struct timeval tv = { 0 };
    struct tm loctime = { 0 };
    int len = 0;

    if (NULL == timestr) {
        return 1;
    }

    /* Get the current time. */
    gettimeofday(&tv, NULL);

    /* Convert it to local time representation. */
    localtime_r(&tv.tv_sec, &loctime);

    /* Print out the date and time in the standard format. */
    strftime(timestr, JES_TIME_STR_LEN, "%Y%m%d %H:%M:%S", &loctime);

    len = strlen(timestr);
    snprintf(timestr + len, JES_TIME_STR_LEN, ".%06.6d", (int)(tv.tv_usec));

    return 0;
}


/* JES trace message output */
void jes_log(const char log_level, const char *function, char *fmt, ...)
{
    int ret = 0;
    va_list args;
    char currenttime[JES_TIME_STR_LEN + 8] = { 0 };
    char level[JES_TRACE_LEVEL_STR_LEN + 8] = { 0 };
    int writelen = 0;
    char filepath[JES_FILE_PATH_LEN + 8] = { 0 };
    struct stat stat_buf;

    /* Use a huge buffer to write log, as in debug mode, some log is very large */
    static char *buf = NULL;
    static char *tracemsg = NULL;
    int msglen = 1024 * 1024 * 1;   /* use 1MB */

    if (NULL == buf) {
        buf = malloc(msglen);
    }
    if (NULL == tracemsg) {
        tracemsg = malloc(msglen);
    }

    /* Level */
    switch (log_level) {
    case JES_TRACE_ERROR:
        snprintf(level, JES_TRACE_LEVEL_STR_LEN, "ERROR");
        break;
    case JES_TRACE_WARN:
        snprintf(level, JES_TRACE_LEVEL_STR_LEN, "WARN");
        break;
    case JES_TRACE_INFO:
        snprintf(level, JES_TRACE_LEVEL_STR_LEN, "INFO");
        break;
    case JES_TRACE_DEBUG:
        snprintf(level, JES_TRACE_LEVEL_STR_LEN, "DEBUG");
        break;
    case JES_TRACE_DUMP:
        snprintf(level, JES_TRACE_LEVEL_STR_LEN, "DUMP");
        break;
    default:
        snprintf(level, JES_TRACE_LEVEL_STR_LEN, "DEBUG");
        break;
    }

    /* Message Body */
    memset(buf, 0, msglen);
    va_start(args, fmt);
    vsnprintf(buf, msglen, fmt, args);
    va_end(args);

    ret = get_current_time(currenttime);
    if (0 != ret) {
        return;
    }

    /* Compose trace message written to jestrace file. */

    /* PID: TID: TIMESTAMP: [Level]: Message Body */
    memset(tracemsg, 0, msglen);
    snprintf(tracemsg, msglen, "******** %d: %ld: %s: [%s]: [%s] %s\n", getpid(), pthread_self(), currenttime, level, NC(function), buf);
	printf("%s", tracemsg); 

    return;
}

#define YYDEBUG 1
#define PARSE_DEBUG
 int yydebug=1; 

/* 属性操作类型 */
Node * opr(int name, int num, ...);
Node * set_func(int name, int num, ...);
Node * set_func_call(int name, int num, ...);
Node * set_func_ret(int name, int num, ...);
Node * set_index(int value);
Node * set_index3(int v1, int v2, int v3);
Node * set_content(float value);
Node * set_str(char* value);
/* 树结点操作 */
void NodeFree(Node * p);
float NodeExecute(Node * p);
typedef union {
//%union {
    float val;  /* 变量值 */
    int index;  /* 用于存放 变量数组索引 或 一元操作符值 或 多元操作符索引 */
    Node *node; /* 结点地址 */
    char* strval;  /* 变量值 */
} yystype;
#define YYSTYPE yystype
/* 打印分析调试信息 */
void debug_vsp(YYSTYPE , char * , YYSTYPE *, char * );
void print_stmt();
/* 在内存中添加变量 */
void add_var(char *);
int G_iVarMaxIndex = 0;  /* 变量最大个数 */
int G_iVarCurIndex = -1; /* 变量当前索引 */
struct VarIndex G_Var[MAX_VARS];  /* 变量内存数组 */
void yyerror(char *s);
%}
%union {
    float val; /* 变量值 */
    int index; /* 变量数组索引 */
    Node *node; /* 结点地址 */
    char* strval;  /* 变量值 */
};
%token <val> NUMBER
%token <index> VARIABLE
%token <strval> STRING
%token ID
%token PRINT
%token STRING
%token SUBMIT 
%token FUNC FUNCCALL
%token FOR WHILE
%nonassoc IF
%nonassoc ELSE
%left AND OR
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%left ADD_T ADD_TT MUS_T MUS_TT
%nonassoc UMINUS
%type <node> stmt stmt_list expr_set expr_setself expr_comp expr FunctionCall SUBMIT zzystmt
%%
program:
function { exit(0); }
;
function:
function stmt { NodeExecute($2); NodeFree($2); }
| /* NULL */
;
stmt:
';'                 {
    $$ = opr(';', 2, NULL, NULL); debug_vsp(yyval, ";", yyvsp, "0");
}
| expr_set ';'      {
    $$ = $1; debug_vsp(yyval, "es;", yyvsp, "01");
}
| PRINT expr ';'    {
    $$ = opr(PRINT, 1, $2); debug_vsp(yyval, "p(e);", yyvsp, "401");
}
| PRINT expr_set ';'    {
    $$ = opr(PRINT, 1, $2); debug_vsp(yyval, "p(es);", yyvsp, "401");
}
| SUBMIT expr ';'    {
    $$ = opr(SUBMIT, 1, $2); debug_vsp(yyval, "p(e);", yyvsp, "401");
}
| SUBMIT expr_set ';'    {
    $$ = opr(SUBMIT, 1, $2); debug_vsp(yyval, "p(es);", yyvsp, "401");
}
| FOR '(' expr_set ';' expr_comp ';' expr_set ')' stmt {
    $$ = opr(FOR, 4, $3, $5, $7, $9); debug_vsp(yyval, "for(es;ec;es) st", yyvsp, "410101010"); }
| WHILE '(' expr_comp ')' stmt       {
    $$ = opr(WHILE, 2, $3, $5); debug_vsp(yyval, "while(ec) st", yyvsp, "41010"); }
| IF '(' expr_comp ')' stmt %prec IF {
    $$ = opr(IF, 2, $3, $5);    debug_vsp(yyval, "if(ec) st", yyvsp, "41010");    }
| IF '(' expr_comp ')' stmt ELSE stmt %prec ELSE       {
    $$ = opr(IF, 3, $3, $5, $7);      debug_vsp(yyval, "if(ec)else st", yyvsp, "4101040");      }
| '{' stmt_list '}' { $$ = $2; debug_vsp(yyval, "{stl}", yyvsp, "101"); }
;
stmt_list:
stmt              {
    $$ = $1;  debug_vsp(yyval, "st", yyvsp, "0");  }
| stmt_list stmt  {
    $$ = opr(';', 2, $1, $2); debug_vsp(yyval, "stl st", yyvsp, "00"); }
;

zzystmt:
| expr_comp '?' FunctionCall ':' FunctionCall {
    $$ = opr(IF, 3, $1, $3, $5);      debug_vsp(yyval, "if(ec)else st", yyvsp, "4101040");      }
;
expr_set:
VARIABLE '.' VARIABLE '.' VARIABLE '=' expr  {
    $$ = opr('=', 2, set_index3($1, $3, $5), $7); debug_vsp(yyval, "v=e", yyvsp, "210"); }
|VARIABLE '=' expr {
    $$ = opr('=', 2, set_index($1), $3); debug_vsp(yyval, "v=e", yyvsp, "210"); }
| VARIABLE '.' VARIABLE '.' VARIABLE '=' expr  {
    $$ = opr('=', 2, set_index3($1, $3, $5), $7); debug_vsp(yyval, "v=e", yyvsp, "210"); }
| VARIABLE '=' expr_setself {
    $$ = opr('=', 2, set_index($1), $3); debug_vsp(yyval, "v=ess", yyvsp, "210"); }
/*| VARIABLE '=' expr '(' expr ')' {*/
/*	$$ = set_func(FUNC, 3, set_index($1), $3, $5); debug_vsp(yyval, "v=ess", yyvsp, "210"); printf("%s", "function zzy0002************\n"); }*/
/*| VARIABLE '=' '(' expr '(' expr ')' ')' { */
	/* $$ = set_func(FUNC, 3, set_index($1), $4, $6); debug_vsp(yyval, "v=ess", yyvsp, "210"); printf("%s", "function zzy0002************\n"); } */
| VARIABLE '=' FunctionCall {
	$$ = set_func(FUNC, 2, set_index($1), $3); debug_vsp(yyval, "v=ess", yyvsp, "210"); printf("%s", "function zzy0002************\n"); }
| VARIABLE '=' '(' FunctionCall ')' {
	$$ = set_func(FUNC, 2, set_index($1), $4); debug_vsp(yyval, "v=ess", yyvsp, "210"); printf("%s", "function zzy0002************\n"); }
| VARIABLE '=' '(' zzystmt ')' {
	$$ = set_func(FUNC, 2, set_index($1), $4); debug_vsp(yyval, "v=ess", yyvsp, "210"); printf("%s", "function zzy0002************\n"); }
| VARIABLE '=' VARIABLE '(' PRINT ')' {
    $$ = opr('=', 2, set_index($1), $3); debug_vsp(yyval, "zzy v=ess", yyvsp, "210"); }
| VARIABLE '=' '$' expr '$' {
    $$ = opr('=', 2, set_index($1), $4); debug_vsp(yyval, "v=ess_submit", yyvsp, "210"); }
/*| Assignment*/
| expr_setself
;
/* Assignment block */
/*
Assignment: VARIABLE '=' Assignment
	| VARIABLE '=' FunctionCall { $$ = $2; }
	;
*/

/* Function Call Block */

FunctionCall : 
expr '('')'  {
	$$ = set_func(FUNCCALL, 1, $1); debug_vsp(yyval, "v=ess", yyvsp, "210"); printf("%s", "function zzy0002************\n"); } 
| expr '(' expr ')' { 
	$$ = set_func(FUNCCALL, 2, $1, $3); debug_vsp(yyval, "v=ess", yyvsp, "210"); printf("%s", "function zzy0002************\n"); }
;

/*| VARIABLE'('Assignment')' { printf("%s", "function zzy0003*********\n"); }*/
;
expr_setself:
ADD_T VARIABLE  {
    $$ = opr(ADD_T, 1, set_index($2));  debug_vsp(yyval, "++v", yyvsp, "42");   }
| MUS_T VARIABLE  {
    $$ = opr(MUS_T, 1, set_index($2));  debug_vsp(yyval, "--v", yyvsp, "42");   }
| VARIABLE ADD_T  {
    $$ = opr(ADD_TT, 1, set_index($1));  debug_vsp(yyval, "v++", yyvsp, "24");  }
| VARIABLE MUS_T  {
    $$ = opr(MUS_TT, 1, set_index($1));  debug_vsp(yyval, "v--", yyvsp, "24");  }
| '(' expr_setself ')' { $$ = $2; debug_vsp(yyval, "(ess)", yyvsp, "101");   }
;
expr_comp:
expr '<' expr   {
    $$ = opr('<', 2, $1, $3); debug_vsp(yyval, "e<e", yyvsp, "010");    }
| expr '>' expr   {
    $$ = opr('>', 2, $1, $3); debug_vsp(yyval, "e>e", yyvsp, "010");    }
| expr GE expr    {
    $$ = opr(GE, 2, $1, $3);  debug_vsp(yyval, "e>=e", yyvsp, "040");   }
| expr LE expr    {
    $$ = opr(LE, 2, $1, $3);  debug_vsp(yyval, "e<=e", yyvsp, "040");   }
| expr NE expr    {
    $$ = opr(NE, 2, $1, $3);  debug_vsp(yyval, "e!=e", yyvsp, "040");   }
| expr EQ expr    {
    $$ = opr(EQ, 2, $1, $3);  debug_vsp(yyval, "e==e", yyvsp, "040");   }
| expr_comp AND expr_comp {
    $$ = opr(AND, 2, $1, $3); debug_vsp(yyval, "ec&&ec", yyvsp, "040"); }
| expr_comp OR expr_comp  {
    $$ = opr(OR, 2, $1, $3);  debug_vsp(yyval, "ec||ec", yyvsp, "040"); }
| '(' expr_comp ')'       { $$ = $2;                  debug_vsp(yyval, "(ec)", yyvsp, "101");   }
;

expr:
NUMBER            {
    $$ = set_content($1);      debug_vsp(yyval, "f", yyvsp, "3");     }
| VARIABLE        {
    $$ = set_index($1);        debug_vsp(yyval, "v", yyvsp, "2");     }
| VARIABLE '.' VARIABLE '.' VARIABLE {
    $$ = set_index3($1, $3, $5);        debug_vsp(yyval, "v", yyvsp, "2");     } 
| STRING        {
    $$ = set_str($1);        debug_vsp(yyval, "v", yyvsp, "0");     }
| SUBMIT {
    $$ = set_str($1);        debug_vsp(yyval, "v", yyvsp, "0");     }
| '-' NUMBER %prec UMINUS {
    $$ = set_content(-$2);   debug_vsp(yyval, "-e", yyvsp, "13"); }
| expr '+' expr   {
    $$ = opr('+', 2, $1, $3);  debug_vsp(yyval, "e+e", yyvsp, "010"); }
| expr '-' expr   {
    $$ = opr('-', 2, $1, $3);  debug_vsp(yyval, "e-e", yyvsp, "010"); }
| expr '*' expr   {
    $$ = opr('*', 2, $1, $3);  debug_vsp(yyval, "e*e", yyvsp, "010"); }
| expr '/' expr   {
    $$ = opr('/', 2, $1, $3);  debug_vsp(yyval, "e/e", yyvsp, "010"); }
| '(' expr ')'    {
    $$ = $2;                   debug_vsp(yyval, "(e)", yyvsp, "101");
}
;
//| '(' expr error        { $$ = $2; printf("ERROR"); exit(0); }
%%
#define SIZE_OF_NODE ((char *)&p->content - (char *)p)
Node *set_content(float value) {
    Node *p;
    size_t sizeNode;
	JES_DBG("BEGIN value=%f", value);
    /* 分配结点空间 */
    sizeNode = SIZE_OF_NODE + sizeof(float);
    if ((p = malloc(sizeNode)) == NULL)
        yyerror("out of memory");
    /* 复制内容 */
    p->type = TYPE_CONTENT;
    p->content = value;
	JES_DBG("END value=%f node=%p", value, p);
    return p;
}
Node *set_str(char* value) {
    Node *p;
    size_t sizeNode;
	JES_DBG("BEGIN value=%s", value);
    /* 分配结点空间 */
    sizeNode = SIZE_OF_NODE + sizeof(char*);
    if ((p = malloc(sizeNode)) == NULL)
        yyerror("out of memory");
    /* 复制内容 */
    p->type = TYPE_STR;
    p->str = strdup(value);
	JES_DBG("END value=%s node=%p", value, p);
    return p;
}
Node *set_index(int value) {
    Node *p;
    size_t sizeNode;
	JES_DBG("BEGIN value=%d", value);
    /* 分配结点空间 */
    sizeNode = SIZE_OF_NODE + sizeof(int);

    if ((p = malloc(sizeNode)) == NULL)
        yyerror("out of memory");
    /* 复制内容 */
    p->type = TYPE_INDEX;
    p->index = value;
	JES_DBG("END value=%d node=%p", value, p);
    return p;
}
Node *set_index3(int v1, int v2, int v3) {
    Node *p;
    size_t sizeNode;
	JES_DBG("BEGIN v1=%d, v2=%d, v3=%d", v1, v2, v3);
    /* 分配结点空间 */
    sizeNode = SIZE_OF_NODE + sizeof(int);

    if ((p = malloc(sizeNode)) == NULL)
        yyerror("out of memory");
    /* 复制内容 */
    p->type = TYPE_STEP;
    p->index = v1;
	JES_DBG("END value=%d node=%p", v1, p);
    return p;
}
	Node *opr(int name, int num, ...) {
		va_list valist;
		Node *p;
		size_t sizeNode;
		int i;
		JES_DBG("BEGIN name=%d, num=%d", name, num);
		/* 分配结点空间 */
		sizeNode = SIZE_OF_NODE + sizeof(OpNode) + (num - 1) * sizeof(Node*);

		if ((p = malloc(sizeNode)) == NULL)
			yyerror("out of memory");
		/* 复制内容 */
		p->type = TYPE_OP;
		p->op.name = name;
		p->op.num = num;
		va_start(valist, num);
		for (i = 0; i < num; i++)
			p->op.node[i] = va_arg(valist, Node*);
		va_end(valist);
		JES_DBG("END name=%d node=%p", name, p);
		return p;
	}
	Node *set_func(int name, int num, ...) {
		va_list valist;
		Node *p;
		size_t sizeNode;
		int i;
		/* 分配结点空间 */
		sizeNode = SIZE_OF_NODE + sizeof(OpNode) + (num - 1) * sizeof(Node*);
		JES_DBG("BEGIN name=%d, num=%d", name, num);

		if ((p = malloc(sizeNode)) == NULL)
			yyerror("out of memory");
		/* 复制内容 */
		p->type = TYPE_OP;
		p->op.name = name;
		p->op.num = num;
		va_start(valist, num);
		for (i = 0; i < num; i++) {
			p->op.node[i] = va_arg(valist, Node*);
			JES_DBG("add one node: p->op.node[%d]=%p", i, p->op.node[i]);
		}
		va_end(valist);
		JES_DBG("END p=%p **************", p);
		return p;
	}
	Node *set_func_call(int name, int num, ...) {
		va_list valist;
		Node *p;
		size_t sizeNode;
		int i;
		/* 分配结点空间 */
		sizeNode = SIZE_OF_NODE + sizeof(OpNode) + (num - 1) * sizeof(Node*);
		JES_DBG("BEGIN name=%d, num=%d", name, num);

		if ((p = calloc(1,sizeNode)) == NULL)
			yyerror("out of memory");
		/* 复制内容 */
		p->type = TYPE_OP;
		p->op.name = name;
		p->op.num = num;
		va_start(valist, num);
		for (i = 0; i < num; i++) {
			p->op.node[i] = va_arg(valist, Node*);
			JES_DBG("add one node: p->op.node[%d]=%p", i, p->op.node[i]);
		}
		va_end(valist);
		JES_DBG("END p=%p **************", p);
		return p;
	}
	/**/
	void debug_vsp(YYSTYPE yval, char * info, YYSTYPE * vsp, char * mark) {
	#ifdef PARSE_DEBUG1111
		printf("\n -RULE  0x%x  %s vsp=%p mark=%s\n ", yval.node, info , vsp , mark);
		int i;
		int ilen = strlen(mark);
		for (i = 1 - ilen; i <= 0; i++) {
			printf("\n zzy: %c ==>\n", mark[ilen + i - 1]);
			switch (mark[ilen + i - 1]) {
			case '0':
				printf(" [ 0x%x ", vsp[i].node); //「」
				switch (vsp[i].node->type) {
				case TYPE_STR:
					printf("%s ] ", vsp[i].node->str);
					break;
				case TYPE_CONTENT:
					printf("%g ] ", vsp[i].node->content);
					break;
				case TYPE_INDEX:
					printf("%s ] ", G_Var[vsp[i].node->index].mark);
					break;
				case TYPE_OP:
					if (vsp[i].node->op.name < USER_DEF_NUM)
						printf("%c ] ", vsp[i].node->op.name);
					else
						printf("%s ] ", G_Def[vsp[i].node->op.name - USER_DEF_NUM].name);
					break;
				}
				break;
			case '1':
				printf(" %c ", vsp[i].index);  /* 打印运算符 */
				break;
			case '2':
				printf(" %s ", G_Var[vsp[i].index].mark);
				break;
			case '3':
				printf(" %g ", vsp[i].val);
				break;
			case '4':
				printf(" %s ", G_Def[vsp[i].index].name);
				break;
			}
		}
		printf("\n");
		print_stmt();
	#endif
	}
	void add_var(char *mark) {
		if (G_iVarMaxIndex == 0) {
			strcpy(G_Var[0].mark, mark);
			G_iVarMaxIndex++;
			G_iVarCurIndex = 0;
			return;
		}
		int i;
		for (i = 0; i <= G_iVarMaxIndex - 1; i++) {
			if (strcmp(G_Var[i].mark, mark) == 0) {
				G_iVarCurIndex = i;
				return;
			}
		}
		strcpy(G_Var[G_iVarMaxIndex].mark, mark);
		G_iVarCurIndex = G_iVarMaxIndex;
		G_iVarMaxIndex++;
	}
	void print_stmt() {
		printf(" -STMT: \n");
		/*
		int i;
		for(i=0;i<=G_iBuffRowCount;i++)
		 printf("%s \n",G_sBuff[i]);
		*/
		if (G_iBuffColCount == 0)
			printf("  %s \n", G_sBuff[G_iBuffRowCount - 1]);
		else
			printf("  %s \n", G_sBuff[G_iBuffRowCount]);
		printf("\n");
	}
	void NodeFree(Node *p) {
		JES_DBG("BEGIN p=%p", p);
		int i;
		if (!p) return;
		if (p->type == TYPE_OP) {
			JES_DBG("p->op.num=%d", p->op.num);
			for (i = 0; i < p->op.num; i++)
				NodeFree(p->op.node[i]);
		}
		free (p);
	}
	void yyerror(char *s) {
		fprintf(stdout, "%s\n", s);
		printf("<Parser Error> Line %d ,Col %d \n", G_iBuffRowCount + 1, G_iBuffColCount + 1);
		printf(" %s\n", G_sBuff[G_iBuffRowCount]);
	}

	int main(int argc, char** argv, char** env) {
	   int flags, opt;
	   int nsecs, tfnd;
		char* insrc = NULL;

	   nsecs = 0;
	   tfnd = 0;
	   flags = 0;
	   while ((opt = getopt(argc, argv, "nt:i:")) != -1) {
		   switch (opt) {
		   case 'n':
			   flags = 1;
			   break;
		   case 't':
			   nsecs = atoi(optarg);
			   tfnd = 1;
			   break;
		   case 'i':
			   insrc = optarg;
			   break;
		   default: /* '?' */
			   fprintf(stderr, "Usage: %s [-t nsecs] [-n] name\n",
					   argv[0]);
			   exit(EXIT_FAILURE);
		   }
	   }

	   printf("flags=%d; tfnd=%d; optind=%d\n", flags, tfnd, optind);

	   if (optind >= argc) {
		   fprintf(stderr, "Expected argument after options\n");
		   //exit(EXIT_FAILURE);
	   }

	   printf("name argument = %s\n", argv[optind]);

		FILE* fp=NULL;
		if (NULL != insrc) {
			printf("begin to open file %s\n", insrc);
			FILE* fp=fopen(insrc, "r");
			if(fp==NULL)
			{
				printf("cannot open %s\n", insrc);
				return -1;
			}
			extern FILE* yyin;				//yyin和yyout都是FILE*类型
			yyin=fp;						//yacc会从yyin读取输入，yyin默认是标准输入，这里改为磁盘文件。yacc默认向yyout输出，可修改yyout改变输出目的
		}

		printf("-----begin parsing %s\n", insrc);
		yyparse();						//使yacc开始读取输入和解析，它会调用lex的yylex()读取记号
		puts("-----end parsing");

		if (NULL != fp) {
			fclose(fp);
		} 
		return 0;
}
