#include <stdio.h>

int main() {
   printf("test in\n");
   int b=mycal_int(10,3);
   printf("result is %d \n", b);
   float c=mycal(5.0*3.1);
   printf("result for float is %f \n", c);
   //cblopedbentry();

   //user_conn("scott/tiger001@zzy001");
   //libuser_dyn_main2();
   int a=0;
   //a = user_all("SELECT GDG_BASE_NAME, GDG_MAX_GEN, GDG_CUR_GEN FROM gdg_define");
   printf("call user_all return: %d\n", a);

	// call function exported in cobol program
   int d=cblopedbentry("scott/tiger001@zzy001");
   printf("call cblopedbentry return: %d\n", d);
   return 0;

}

