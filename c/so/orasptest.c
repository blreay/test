#include <stdio.h>
int main111() {
   printf("test ok\n");
   return 0;
}

int PGMTEST(short* arglen, char* argstr) {
/*int pgmtest(short argc, char* argv[]) {*/
   printf("test ok\n");
   printf("arglen=%d\n", *arglen);
   printf("argstr=%s\n", argstr);
   return 0;
}
int PGMTEST1() {
   printf("test ok\n");
   return 0;
}
int mycal_int(int a, int b) {
   printf("test ok in int\n");
   return a*b;
}
float mycal(float a, float b) {
   //printf("test ok\n");
   return a*b;
}
