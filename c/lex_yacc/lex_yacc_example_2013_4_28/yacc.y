%{
/*��yacc�������ļ���yacc.tab.c��yacc.tab.h
yacc�ļ���3����ɣ���2��%%�а���3�θ�����
��1���������Σ�������
1-C���벿�֣�includeͷ�ļ������������͵���������Щ������ԭ���������ɵ�.c�ļ��С�
2-�Ǻ���������%token
3-������������%type
��2���ǹ���Σ���yacc�ļ������壬����ÿ������ʽ�����ƥ��ģ��Լ�ƥ���Ҫִ�е�C���붯����
��3����C��������Σ���yyerror()�Ķ��壬��ЩC�����ԭ���������ɵ�.c�ļ��С��ö����ݿ���Ϊ��*/

//��1�Σ�������
#include "main.h"	//lex��yaccҪ���õ�ͷ�ļ������������һЩͷ�ļ����ض�����YYSTYPE

extern "C"			//Ϊ���ܹ���C++�����������C�����������ÿһ����Ҫʹ�õ�C��������������������extern "C"{}�����棬����C++����ʱ���ܳɹ��������ǡ�extern "C"������C++����������C�������͡�
{					//lex.l��Ҳ�����Ƶ����extern "C"�����԰����Ǻϲ���һ�Σ��ŵ���ͬ��ͷ�ļ�main.h��
	void yyerror(const char *s);
	extern int yylex(void);//�ú�������lex.yy.c�ﶨ��ģ�yyparse()��Ҫ���øú�����Ϊ���ܱ�������ӣ�������extern��������
}

%}

/*lex��Ҫreturn�ļǺŵ�����
��token���һ��<member>������Ǻţ�ּ�����ڼ���д��ʽ��
�ٶ�ĳ������ʽ�е�1���ս���ǼǺ�OPERATOR��������OPERATOR���Եķ�ʽ��
1-����Ǻ�OPERATOR������ͨ��ʽ����ģ���%token OPERATOR�����ڶ�����Ҫд$1.m_cOp����ָ��ʹ��YYSTYPE���ĸ���Ա
2-��%token<m_cOp>OPERATOR��ʽ�����ֻ��Ҫд$1��yacc���Զ��滻Ϊ$1.m_cOp
������<>����Ǻź󣬷��ս����file, tokenlist��������%type<member>������(����ᱨ��)����ָ�����ǵ����Զ�ӦYYSTYPE���ĸ���Ա����ʱ�Ը÷��ս�������ã���$$�����Զ��滻Ϊ$$.member*/
%token<m_nInt>INTEGER
%token<m_sId>IDENTIFIER
%token<m_cOp>OPERATOR
%type<m_sId>file
%type<m_sId>tokenlist

%%

file:								//�ļ����ɼǺ������
	tokenlist						//�������ʾ�Ǻ����е�ID
	{
		cout<<"all id:"<<$1<<endl;	//$1�Ƿ��ս��tokenlist�����ԣ����ڸ��ս������%type<m_sId>����ģ���Լ��������YYSTYPE��m_sId���ԣ�$1�൱��$1.m_sId����ֵ�Ѿ����²����ʽ�и�ֵ(tokenlist IDENTIFIER)
	};
tokenlist:							//�Ǻ���������Ϊ�գ��������������֡���ʶ�����������������
	{
	}
	| tokenlist INTEGER
	{
		cout<<"int: "<<$2<<endl;	//$2�ǼǺ�INTEGER�����ԣ����ڸüǺ�����%token<m_nInt>����ģ���Լ��������YYSTYPE��m_nInt���ԣ�$2�ᱻ�滻Ϊyylval.m_nInt������lex�︳ֵ
	}
	| tokenlist IDENTIFIER
	{
		$$+=" " + $2;				//$$�Ƿ��ս��tokenlist�����ԣ����ڸ��ս������%type<m_sId>����ģ���Լ��������YYSTYPE��m_sId���ԣ�$$�൱��$$.m_sId�������ʶ�𵽵ı�ʶ����������tokenlist�����У����ϲ����ʽ������ó�Ϊ��
		cout<<"id: "<<$2<<endl;		//$2�ǼǺ�IDENTIFIER�����ԣ����ڸüǺ�����%token<m_sId>����ģ���Լ��������YYSTYPE��m_sId���ԣ�$2�ᱻ�滻Ϊyylval.m_sId������lex�︳ֵ
	}
	| tokenlist OPERATOR
	{
		cout<<"op: "<<$2<<endl;		//$2�ǼǺ�OPERATOR�����ԣ����ڸüǺ�����%token<m_cOp>����ģ���Լ��������YYSTYPE��m_cOp���ԣ�$2�ᱻ�滻Ϊyylval.m_cOp������lex�︳ֵ
	};

%%

void yyerror(const char *s)			//��yacc�����﷨����ʱ����ص�yyerror���������ҰѴ�����Ϣ���ڲ���s��
{
	cerr<<s<<endl;					//ֱ�����������Ϣ
}

int main()							//�������������������Ҳ���Էŵ�����.c, .cpp�ļ���
{
	const char* sFile="file.txt";	//��Ҫ��ȡ���ı��ļ�
	FILE* fp=fopen(sFile, "r");
	if(fp==NULL)
	{
		printf("cannot open %s\n", sFile);
		return -1;
	}
	extern FILE* yyin;				//yyin��yyout����FILE*����
	yyin=fp;						//yacc���yyin��ȡ���룬yyinĬ���Ǳ�׼���룬�����Ϊ�����ļ���yaccĬ����yyout��������޸�yyout�ı����Ŀ��

	printf("-----begin parsing %s\n", sFile);
	yyparse();						//ʹyacc��ʼ��ȡ����ͽ������������lex��yylex()��ȡ�Ǻ�
	puts("-----end parsing");

	fclose(fp);

	return 0;
}
