%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <functional>
#include <algorithm>
#include <string>
using namespace std;

int yyerror(const char*);
#include "lex.c"

map<string, double> reg;
static BIGINT ival;

int i;

%}

%token		CLEAR EXIT LIST ERASE DEC HEX OCT HELP
%token		NUM	REG
%token		ADD SUB MUL DIV MOD LSHIFT RSHIFT
%token		AND OR  NOT LESS MORE EQUAL
%token		BITAND BITOR BITXOR BITREV

%left		OR
%left		AND
%left		BITOR
%left		BITXOR
%left		BITAND
%left		LESS MORE EQUAL
%left		LSHIFT RSHIFT
%left		ADD	SUB
%left		MUL	DIV MOD
%right		RMINUS BITREV NOT

%%
	
lines		: lines statement '\n'		
		| lines '\n'				{printf("> ");}
		| lines error '\n'			{yyerrok;printf("\n> ");}
		|
		;
		
statement	: expr				{
							printf( "\t=%lf\n> " , $1 );
						}
		| REG '=' expr			{
							string reg_name = lex_id_value.top();
							reg.insert(pair<string, double>(reg_name, $3)); 
							lex_id_value.pop();
							const char *str = reg_name.c_str();
							printf( "\t%s=%lf\n> " , str, $3);
						}
		;
		
expr		: expr ADD expr			{ $$ = $1 + $3 ; }
		| expr SUB expr			{ $$ = $1 - $3 ; }
		| expr MUL expr			{ $$ = $1 * $3 ; }
		| expr DIV expr			{ $$ = $1 / $3 ; }
		| expr MOD expr			{ $$ = (BIGINT)$1 % (BIGINT)$3 ; }
		| expr BITAND expr		{ $$ = (BIGINT)$1 & (BIGINT)$3 ; }
		| expr BITOR expr		{ $$ = (BIGINT)$1 | (BIGINT)$3 ; }
		| expr BITXOR expr		{ $$ = (BIGINT)$1 ^ (BIGINT)$3 ; }
		| expr LSHIFT expr		{ $$ = (BIGINT)$1 << (BIGINT)$3 ; }
		| expr RSHIFT expr		{ $$ = (BIGINT)$1 >> (BIGINT)$3 ; }
		| expr AND expr			{ $$ = (BIGINT)$1 && (BIGINT)$3 ; }
		| expr OR expr			{ $$ = (BIGINT)$1 || (BIGINT)$3 ; }
		| expr LESS expr		{ $$ = $1<$3?1:0; }
		| expr MORE expr		{ $$ = $1>$3?1:0; }
		| expr EQUAL expr		{ $$ = $1==$3?1:0; }
		| expr EQUAL expr '?' expr ':' expr		{ $$ = $1==$3?$5:$7; }
		| '(' expr ')'			{ $$ = $2 ; }
		| SUB expr %prec RMINUS		{ $$ = -$2 ; }
		| BITREV expr			{ $$ = ~((BIGINT)$2); }
		| NOT expr 			{ $$ = !( (BIGINT)$2 ) ; }
		| NUM				{ $$ = $1 ; }
		| REG				{ $$ = reg[lex_id_value.top()] ; lex_id_value.pop(); }
		;

%%

int yyerror(const char *str)
{
 	fprintf(stderr,"Error? %s\n",str);
	return 1;      
 }

int yywrap()
{
         
      return 1;
}
int main()
{
	printf("--------------------------------------------------------------\n");
	printf(">> nepc - A mini limited precision caculator.\n");
	printf(">> Copyright (C) 2005 neplusultra@linuxsir.org\n");
	printf(">> nepc is open software; you can redistribute it and/or modify\n\
   it under the terms of the version 2.1 of the GNU Lesser \n\
   General Public License as published by the Free Software\n\
   Foundation.\n");
	printf("--------------------------------------------------------------\n");
	printf("> ");
	yyparse();
}


