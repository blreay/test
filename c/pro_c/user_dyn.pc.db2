#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sqlca.h>

int user_dyn(char* sqlstr) {
	printf("### ENTER user_dyn ###\n");
		char sql_stmt[1024] = { 0 };
		/*strcpy(sql_stmt, "SELECT GDG_BASE_NAME, GDG_MAX_GEN, GDG_CUR_GEN FROM gdg_define");*/
		strcpy(sql_stmt, sqlstr);

        EXEC SQL BEGIN DECLARE SECTION;
                char gdg_name[256];
                char gdg_gen_max[256];
                char gdg_gen_cur[256];
                char username1[51]="";
                /*EXEC SQL VAR username1 IS STRING(51);*/
        EXEC SQL END DECLARE SECTION;

		EXEC SQL INCLUDE SQLCA;
		EXEC SQL PREPARE select_stmt FROM :sql_stmt; 
		EXEC SQL DECLARE c1 CURSOR FOR select_stmt; 
		EXEC SQL OPEN c1; 
		/*EXEC SQL WHENEVER NOT FOUND DO BREAK; */
		int itemcount=0;
		while(itemcount <=10) 
		{ 
			EXEC SQL FETCH c1 INTO :gdg_name, :gdg_gen_max, :gdg_gen_cur; 
			/*if( sqlca.sqlcode == 1403) break;*/
			printf("The name is: %s,    The max gen is: %s,    The current gen is :%s\n", gdg_name, gdg_gen_max, gdg_gen_cur);
			itemcount++;
		  } 
		EXEC SQL CLOSE c1; 	
	printf("### EXIT user_dyn ###\n");
}

int libuser_dyn_main1()
{
	printf("in libuser_dyn, in main1\n");
}

int main()
{
	printf("in libuser_dyn,in main\n");
}

int libuser_dyn_main2()
{
	/*user_main("SELECT GDG_BASE_NAME, GDG_MAX_GEN, GDG_CUR_GEN FROM gdg_define");*/
	user_dyn("SELECT GDG_BASE_NAME, GDG_MAX_GEN, GDG_CUR_GEN FROM gdg_define");
	printf("hello,world,in main2\n");
}

int libuser_dyn()
{
	printf("hello,world,in libuser_dyn\n");
}
