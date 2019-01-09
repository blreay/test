#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>

#define MAX_OUTBUF_SIZE (1024 * 1024 * 16)

/****************************************************************
This function is used to submit one job by calling artjesadmin
*****************************************************************/
int execute_cmd(char* cmd, char** output) {
    char * strFuncName = "execute_cmd";
    FILE *fstream = NULL;
    char *buff=NULL;
    int  ret = 0;
    int  cmdret = 0;

	if (NULL == cmd) {
        LOGERR("[%s] cmd is NULL(0x%08x)", strFuncName, cmd);
		return -1;
	} 
    DBGLOG("[%s] IN cmd=[%s] output=0x%08x", strFuncName, cmd, output);
	buff = malloc(MAX_OUTBUF_SIZE);
	
    if (NULL == (fstream=popen(cmd,"r"))) {
        LOGERR("[%s] Execute command(%s) failed: %s", strFuncName, cmd, strerror(errno));
    	LOGERR("[%s] cmd OUT buff=%s", strFuncName, buff);
        return -1;
    }

	if (0 != fread(buff, 1, 2048 - 1, fstream)) {
    	pclose(fstream);
		fstream = NULL;
    } else {
        LOGERR("Execute command(%s) result is abnormal:NULL", cmd);
        pclose(fstream);
        return -1;
    } 
    //LOGERR("[%s] output buff: %s", strFuncName, buff);

	strcpy(*output, buff);
	free(buff); 
	return 0;
}

int TSTCPGM() { 
		char cmd[1024] = { '\0' };
		char* output=NULL;
	    output = malloc(MAX_OUTBUF_SIZE);
		pid_t pid=0;
        printf("reda printf!\n");

		pid=getpid();
		sprintf(cmd, "bash -c \"echo $$;lsof -p %d\"", pid);
		execute_cmd(cmd, &output); 
        printf("****************************************\n");
		printf("%s\n", output);
        printf("****************************************\n");
		scanf("%s", output);
		//fsync(1);
		//fsync(2); 
		sleep(20);
		free(output);
        return 0;
}

#ifdef _MAIN_ENTRY_
int main() {
	TSTCPGM();
	TSTCPGM(2);
}
#endif
