����: ���� 2013-4-28
�������һ��lex/yacc������ʾ����������ϸ��ע�ͣ�����ѧϰlex/yacc��������Ĵ��������linux/cygwin������make�Ϳ��Ա����ִ�С��󲿷ֿ���Ѿ�����ˣ���ֻҪ�Լ���չ�Ϳ��Գ�Ϊһ��������֮��ĳ������ڡ�����ԭ���Ŀγ���ƣ����߶����������lex/yacc��Ŀ�Ĵ��롣
��������Сȴ��ʾ��lex/yacc��������Ҫ�ͳ��õ�������
* lex/yacc������ɽṹ���ļ���ʽ��
* �����lex/yacc��ʹ��C++��STL�⣬��extern "C"������Щlex/yacc���ɵġ�Ҫ���ӵ�C��������yylex(), yywrap(), yyerror()��
* �ض���YYSTYPE/yylvalΪ�������͡�
* lex���״̬�Ķ����ʹ�ã���BEGIN���ڳ�ʼ̬������״̬���л���
* lex��������ʽ�Ķ��塢ʶ��ʽ��
* lex����yylval��yacc�������ݡ�
* yacc����%token<>��ʽ����yacc�Ǻš�
* yacc����%type<>��ʽ�������ս�������͡�
* ��yaccǶ���C���붯����ԼǺ�����($1, $2��)���ͷ��ս������($$)����ȷ���÷�����
* ��yyin/yyout�ظ�ֵ���Ըı�yaccĬ�ϵ�����/���Ŀ�ꡣ

�����ӹ����ǣ��Ե�ǰĿ¼�µ�file.txt�ļ������������еı�ʶ�������֡��������ţ���ʾ����Ļ�ϡ�linux���Ի�����Ubuntu 10.04��

�ļ��б�
lex.l:		lex�����ļ���
yacc.y:		yacc�����ļ���
main.h:		lex.l��yacc.y��ͬʹ�õ�ͷ�ļ���
Makefile:	makefile�ļ���
lex.yy.c:	��lex����lex.l�����ɵ�C�ļ���
yacc.tab.c:	��yacc����yacc.y�����ɵ�C�ļ���
yacc.tab.h:	��yacc����yacc.y�����ɵ�Cͷ�ļ����ں�%token��YYSTYPE��yylval�ȶ��壬��lex.yy.c��yacc.tab.cʹ�á�
file.txt:	���������ı�ʾ����
README.txt:	��˵����

ʹ�÷�����
1-��lex_yacc_example.rar��ѹ��linux/cygwin�¡�
2-�����н���lex_yacc_exampleĿ¼��
3-����make����ʱ���Զ�ִ�����²�����
(1) �Զ�����flex����.l�ļ�������lex.yy.c�ļ���
(2) �Զ�����bison����.y�ļ�������yacc.tab.c��yacc.tab.h�ļ���
(3) �Զ�����g++���롢���ӳ���ִ���ļ�main��
(4) �Զ�ִ��main��
���н��������ʾ��
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

�ο����ϣ���Lex��Yacc�����ŵ���ͨ(6)-����C-C++�����ļ���, http://blog.csdn.net/pandaxcl/article/details/1321552
�������ºʹ����������ҵ�blog: http://blog.csdn.net/huyansoft


[END]
