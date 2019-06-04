#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/wait.h>  
#include <stdio.h>  

pid_t child,child2;
int status=0;  
struct  timeval start; 
struct  timeval end; 
unsigned  long diff; 

int main(void) {
	pid_t pid=fork();
	if(pid==0) {
		int j ;
		for(j=0;j<3;j++) {
			printf("child: %d\n",j);
			sleep(1);
		}
        gettimeofday(&start,NULL); 
        printf("exit   : %ld.%ld %ld\n", start.tv_sec,  start.tv_usec, EINTR);
        exit(2);
	} else if (pid>0) {
		int i;
        child2 = pid;
/*
		for(i=0;i<10;i++) {
			printf("parent: %d\n",i);
			sleep(1);
		}
*/
	} else {
		fprintf(stderr,"can't fork ,error %d\n",errno);
		exit(1);
	}

	//while (((child = waitpid(-1,&status,0)) == -1)&(errno == EINTR));  
	//while (((child = waitpid(pid,&status, WNOHANG)) == -1)&(errno == EINTR));

    while (1) {
	    child = waitpid(pid, &status, 0);
        gettimeofday(&start,NULL); 
        printf("waitpid: %ld.%ld %ld\n", start.tv_sec,  start.tv_usec, EINTR);

        if (child == -1) { 
    /* 		printf("Wait Error.%s\n", strerror(errno));   */
            printf("Wait Error %d (%s)\n", errno, "error");
        } else if (!status)  {
            printf("Child %ld terminated normally return status is zero\n",  child);  
        } else if (WIFEXITED(status))  {
            printf("Child %ld terminated normally return status is %d\n",  child, WEXITSTATUS(status));  
        } else if (WIFSIGNALED(status)){  
            printf("Child %ld terminated due to signal %d znot caught\n",  child, WTERMSIG(status));  
        }
        // getchar();
        printf("This is the end !");
        break;
    }
	return (EXIT_SUCCESS);  
}
