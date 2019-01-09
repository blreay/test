%{

#define YYSTYPE  double
#define  BIGINT unsigned int 
#include <ctype.h>
#include <string>
#include <stack>
using namespace std;
#include "yacc.h"

stack<string> lex_id_value;
%}
			
digit		[0-9]
xdigit		[0-9a-fA-F]
odigit		[0-7]
char		[a-zA-Z_]

decnum	(0?(\.{digit}+)?)|([1-9]{digit}*(\.{digit}+)?)
octnum	0{odigit}+
hexnum	0(x|X){xdigit}+

reg			{char}+	
opt1		"+"|"-"|"*"|"/"|"&"|"|"|"%"|"^"|"~"|"!"|"<"|">"
opt2		(&&)|(\|\|)|(\<\<)|(\>\>)|(==)

exit		((E|e)(X|x)(I|i)(T|t))|((Q|q)(U|u)(I|i)(T|t))
clear		(C|c)(L|l)(E|e)(A|a)(R|r)
list		(L|l)(I|i)(S|s)(T|t)
erase 		(E|e)(R|r)(A|a)(S|s)(E|e)
hex		(H|h)(E|e)(X|x)
oct		(O|o)(C|c)(T|t)
dec		(D|d)(E|e)(C|c)
help		(H|h)(E|e)(L|l)(P|p)

%%
	int i ;
    BIGINT val;
		
[" "; \t]	{}
{decnum}	{sscanf(yytext,"%lf",&yylval);return(NUM); }
{octnum}	{
			i=1;val=0;
			while(i<yyleng)
			{
				val=(val<<3)+yytext[i]-'0';
				i++;
			}
			yylval=val;
			return(NUM);
		}

{hexnum}	{
			i=2;val=0;
			while(i<yyleng)
			{
				if(islower(yytext[i])) val=(val<<4)+yytext[i]-'a'+10;
				else if(isupper(yytext[i])) val=(val<<4)+yytext[i]-'A'+10;
				else val=(val<<4)+yytext[i]-'0';
				i++;
			}
			yylval=val;
			return(NUM);
		}

{reg}		{
			/*
			if(islower(yytext[0]))yylval=yytext[0]-'a';
			else yylval=yytext[0]-'A';
			*/
			lex_id_value.push(yytext);
			return(REG);
		}
		
{opt1}	{
			switch(yytext[0])
			{
				case '+':
					return ADD;
					break;
				case '-':
					return SUB;
					break;
				case '*':
					return MUL;
					break;
				case '/':
					return DIV;
					break;
				case '%':	
					return MOD;
					break;
				case '^':
					return BITXOR;
					break;
				case '&':
					return BITAND;
					break;
				case '|':
					return BITOR;
					break;
				case '<':
					return LESS;
					break;
				case '>':
					return MORE;
					break;
				case '!':
					return NOT;
					break;
				case '~':
					return BITREV;
					break;
			}
		}

{opt2}	{
			switch(yytext[0])
			{
				case '&':
					return AND;
					break;
				case '|':
					return OR;
					break;
				case '<':
					return LSHIFT;
					break;
				case '>':
					return RSHIFT;
					break;
				case '=':
					return EQUAL;
					break;
			}		
					
		}		
.|\n		{return(yytext[0]);}

%%

