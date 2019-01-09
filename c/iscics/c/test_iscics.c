/* This souce code is used to test iscics() API implemented in runb */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/* this main will not be called */
int main(int argc, char *argv[])
{
    printf("enter main use object file\n");
	return 0;
}

/* ENTRY function */
test_iscics(int argc, char *argv[])
{
	char *strFuncName = "test_iscics";
	printf("[%s] Enter\n", strFuncName);
	if ( iscics() ) {
		printf("[%s] In CICS mode\n", strFuncName);
	} else {
		printf("[%s] In NONE-CICS mode\n", strFuncName);
	}
	printf("[%s] Exit\n", strFuncName);
	return 0;
}

