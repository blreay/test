#include <stdio.h>
int main111() {
   printf("test ok\n");
   return 0;
}

int PGMEXIT(short* arglen, char* argstr) {
/*int pgmtest(short argc, char* argv[]) {*/
   printf("test ok\n");
   printf("arglen=%d\n", *arglen);
   printf("argstr=%s\n", argstr);
   /*return 0;*/
   /* test the result of call exit */
	//exit(0);
	return 0;
}
int PGMTEST1() {
   printf("test ok\n");
   return 0;
}
