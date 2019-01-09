%{
#include <stdlib.h>
#include "node.h"
#include "lexya_e.tab.h"
struct VarDefine G_Def[MAX_DEFS];             /* 存储的变量数组 */
char G_sBuff[MAX_BUFF_ROWS][MAX_BUFF_COLS];   /* 存储分析语句   */
int G_iBuffRowCount = 0;     /* 当前语句行数 */
int G_iBuffColCount = 0;     /* 当前语句列数 */
extern void add_var(char *);  /* 在内存中添加变量 */
void add_buff(char *); /* 在内存中添加语句 */
void yyerror(char *);
%}
/* 使用代变量表示任意字符 */
any  .
%%
#{any}*[\n] {
    add_buff(yytext);
    G_iBuffColCount = 0;
    G_iBuffRowCount++;
} /* 单行注释 */
[\n]    {
    G_iBuffColCount = 0;
    G_iBuffRowCount++;
} /* 回车 */
"for"   {
    yylval.index = FOR - USER_DEF_NUM;
    G_Def[yylval.index].name = "for";
    add_buff(yytext);
    return FOR;
}
"while" {
    yylval.index = WHILE - USER_DEF_NUM;
    G_Def[yylval.index].name = "while";
    add_buff(yytext);
    return WHILE;
}
"if"    {
    yylval.index = IF - USER_DEF_NUM;
    G_Def[yylval.index].name = "if";
    add_buff(yytext);
    return IF;
}
"else"  {
    yylval.index = ELSE - USER_DEF_NUM;
    G_Def[yylval.index].name = "else";
    add_buff(yytext);
    return ELSE;
}
"print" {
    yylval.index = PRINT - USER_DEF_NUM ;
    G_Def[yylval.index].name = "print";
    add_buff(yytext);
    return PRINT;
}
"dumy_zzysubmit" {
    yylval.index = SUBMIT - USER_DEF_NUM ;
    G_Def[yylval.index].name = "submit";
    add_buff(yytext);
    return SUBMIT;
}
"submit" {
    yylval.strval = strdup(yytext);
    add_buff(yytext);
    return SUBMIT;
}
[a-zA-Z][a-zA-Z0-9]* {
    add_var(yytext);
    yylval.index = G_iVarCurIndex;
    add_buff(yytext);
    return VARIABLE;
}
\"[a-zA-Z0-9]*\" {
    yylval.strval = strdup(yytext);
    add_buff(yytext);
    return STRING;
}
[0-9]+ {
    yylval.val = atof(yytext);
    add_buff(yytext);
    return NUMBER;
}
[0-9]*\.[0-9]+ {
    yylval.val = atof(yytext);
    add_buff(yytext);
    return NUMBER;
}
"++" { yylval.index = ADD_T - USER_DEF_NUM; G_Def[yylval.index].name = "++"; G_Def[yylval.index + 1].name = "++";  add_buff(yytext); return ADD_T; }
"--" { yylval.index = MUS_T - USER_DEF_NUM; G_Def[yylval.index].name = "--"; G_Def[yylval.index + 1].name = "++";  add_buff(yytext); return MUS_T; }
">=" { yylval.index = GE - USER_DEF_NUM;  G_Def[yylval.index].name = ">=";  add_buff(yytext); return GE;}
"<=" { yylval.index = LE - USER_DEF_NUM;  G_Def[yylval.index].name = "<=";  add_buff(yytext); return LE;}
"==" { yylval.index = EQ - USER_DEF_NUM;  G_Def[yylval.index].name = "==";  add_buff(yytext); return EQ;}
"!=" { yylval.index = NE - USER_DEF_NUM;  G_Def[yylval.index].name = "!=";  add_buff(yytext); return NE;}
"&&" { yylval.index = AND - USER_DEF_NUM; G_Def[yylval.index].name = "&&";  add_buff(yytext); return AND;}
"||" { yylval.index = OR - USER_DEF_NUM;  G_Def[yylval.index].name = "||";  add_buff(yytext); return OR; }

[()<>=+/\-*/;{}\.?:] {
    yylval.index = *yytext;  /* 存储运算符 */
	printf("zzy: yytext=[%s]\n", yytext);
    add_buff(yytext);
    return *yytext;
}
[\t]    { add_buff(yytext); } /* 去除TAB  */
[ ]     { add_buff(yytext); }  /* 去除空格 */
{any}   { printf("Ignore Unknow Symbol:[%s]/n", yytext); }
%%
void add_buff(char * buff) {
    strcat(G_sBuff[G_iBuffRowCount], buff);
    G_iBuffColCount = G_iBuffColCount + strlen(buff);
}
int yywrap(void) {
    return 1;
}
