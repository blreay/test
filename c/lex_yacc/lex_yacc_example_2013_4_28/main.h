//lex.l��yacc.y��ͬʹ�õ�ͷ�ļ�
#ifndef MAIN_HPP
#define MAIN_HPP

#include <iostream>//ʹ��C++��
#include <string>
#include <stdio.h>//printf��FILEҪ�õ�

using namespace std;

/*��lexÿʶ���һ���Ǻź���ͨ������yylval��yacc�������ݵġ�Ĭ�������yylval��int���ͣ�Ҳ����ֻ�ܴ����������ݡ�
yylval����YYSTYPE�궨��ģ�ֻҪ�ض���YYSTYPE�꣬��������ָ��yylval������(�ɲμ�yacc�Զ����ɵ�ͷ�ļ�yacc.tab.h)��
�����ǵ��������ʶ�����ʶ����Ҫ��yacc���������ʶ������yylval��������Ͳ�̫����(Ҫ��ǿ��ת�������ͣ�yacc����ת����char*)��
�����YYSTYPE�ض���Ϊstruct Type���ɴ�Ŷ�����Ϣ*/
struct Type//ͨ��������ÿ����Ա��ÿ��ֻ��ʹ������һ����һ���Ƕ����union�Խ�ʡ�ռ�(����������string�ȸ���������ɲ�����)
{
	string m_sId;
	int m_nInt;
	char m_cOp;
};

#define YYSTYPE Type//��YYSTYPE(��yylval����)�ض���Ϊstruct Type���ͣ�����lex������yacc���ظ����������

#endif
