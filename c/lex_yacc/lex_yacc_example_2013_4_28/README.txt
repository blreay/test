作者: 胡彦 2013-4-28
本框架是一个lex/yacc完整的示例，包括详细的注释，用于学习lex/yacc程序基本的搭建方法，在linux/cygwin下敲入make就可以编译和执行。大部分框架已经搭好了，你只要稍加扩展就可以成为一个计算器之类的程序，用于《编译原理》的课程设计，或者对照理解其它lex/yacc项目的代码。
本例子虽小却演示了lex/yacc程序最重要和常用的特征：
* lex/yacc程序组成结构、文件格式。
* 如何在lex/yacc中使用C++和STL库，用extern "C"声明那些lex/yacc生成的、要链接的C函数，如yylex(), yywrap(), yyerror()。
* 重定义YYSTYPE/yylval为复杂类型。
* lex里多状态的定义和使用，用BEGIN宏在初始态和其它状态间切换。
* lex里正则表达式的定义、识别方式。
* lex里用yylval向yacc返回数据。
* yacc里用%token<>方式声明yacc记号。
* yacc里用%type<>方式声明非终结符的类型。
* 在yacc嵌入的C代码动作里，对记号属性($1, $2等)、和非终结符属性($$)的正确引用方法。
* 对yyin/yyout重赋值，以改变yacc默认的输入/输出目标。

本例子功能是，对当前目录下的file.txt文件，解析出其中的标识符、数字、其它符号，显示在屏幕上。linux调试环境是Ubuntu 10.04。

文件列表：
lex.l:		lex程序文件。
yacc.y:		yacc程序文件。
main.h:		lex.l和yacc.y共同使用的头文件。
Makefile:	makefile文件。
lex.yy.c:	用lex编译lex.l后生成的C文件。
yacc.tab.c:	用yacc编译yacc.y后生成的C文件。
yacc.tab.h:	用yacc编译yacc.y后生成的C头文件，内含%token、YYSTYPE、yylval等定义，供lex.yy.c和yacc.tab.c使用。
file.txt:	被解析的文本示例。
README.txt:	本说明。

使用方法：
1-把lex_yacc_example.rar解压到linux/cygwin下。
2-命令行进入lex_yacc_example目录。
3-敲入make，这时会自动执行以下操作：
(1) 自动调用flex编译.l文件，生成lex.yy.c文件。
(2) 自动调用bison编译.y文件，生成yacc.tab.c和yacc.tab.h文件。
(3) 自动调用g++编译、链接出可执行文件main。
(4) 自动执行main。
运行结果如下所示：
bison -d yacc.y
g++ -c lex.yy.c
g++ -c yacc.tab.c
g++ lex.yy.o yacc.tab.o -o main			
-----begin parsing file.txt
id: abc
id: defghi
(comment)
int: 123
int: 45678
(comment)
op: !
op: @
op: #
op: $
-----the file is end
all id: abc defghi
-----end parsing

参考资料：《Lex和Yacc从入门到精通(6)-解析C-C++包含文件》, http://blog.csdn.net/pandaxcl/article/details/1321552
其它文章和代码请留意我的blog: http://blog.csdn.net/huyansoft


[END]
