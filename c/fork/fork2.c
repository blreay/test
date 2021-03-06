#include <sys/wait.h>  
#include <stdio.h>  
#include <stdlib.h>  
#include <errno.h>  
#include <math.h>  

int main(void) {  
	pid_t child,child2;  

    struct  timeval start; 
    struct  timeval end; 
unsigned  long diff; 
gettimeofday(&end,NULL); 
diff = 1000000 * (end.tv_sec-start.tv_sec)+ end.tv_usec-start.tv_usec; 
printf("thedifference is %ld\n",diff);


	int status;  
	printf("This will demostrate how to get child status\n");  
	if ((child = fork()) == -1) {  
		printf("Fork Error .%s\n", strerror(errno));  
		exit(1);  
	} else if (child == 0) {  
		/* in child process */
		child2 = fork();  
		if(child2 == 0) { 
			/* in child 2 process */
			printf("I am the child2:%ld\n",getpid());  
		}
		int i;  
		printf("I am the child.%ld\n", getpid());  
		for (i = 0; i < 1000000; i++) sin(i);  
		//aa i = 5;  
		i = 5;  
		printf("I exit with %d\n", i);  
        gettimeofday(&start,NULL); 
	    printf("exit: %ld.%ld\n", start.tv_sec,  start.tv_usec);
		exit(i);  
	}  

	while (((child = waitpid(getpid(),&status,0)) == -1)&(errno == EINTR));  
    gettimeofday(&start,NULL); 
    printf("waitpid: %ld.%ld\n", start.tv_sec,  start.tv_usec);

	if (child == -1) { 
/* 		printf("Wait Error.%s\n", strerror(errno));   */
		printf("Wait Error %d (%s)\n", errno, strerror(errno));
	} else if (!status)  {
		printf("Child %ld terminated normally return status is zero\n",  child);  
	} else if (WIFEXITED(status))  {
		printf("Child %ld terminated normally return status is %d\n",  child, WEXITSTATUS(status));  
	} else if (WIFSIGNALED(status)){  
		printf("Child %ld terminated due to signal %d znot caught\n",  child, WTERMSIG(status));  
	}
	// getchar();
	return (EXIT_SUCCESS);  
}  
