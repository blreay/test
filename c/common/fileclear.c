#include <limits.h>
#include <stdlib.h>
#include <pthread.h>
/*#include <errors.h>*/
#ifndef PTHREAD_STACK_MIN
#define PTHREAD_STACK_MIN 10
#endif

int main (int argc, char *argv[]) { 
	int ret = truncate(argv[1], 0);
	printf("ret=%d\n", ret);
     return 0;
 }
