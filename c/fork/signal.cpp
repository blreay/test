#include <iostream> 
#include <signal.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
  
using namespace std;
  
int sigchld = 0;
void sigchld_handler_nowait(int signal){
    write(1,"in sigchld_handler_nowait \n", 25);
    sigchld++;
}
void sigchld_handler(int signal){
    write(1,"begin to sleep 5 seconds\n", 25);
	sleep(5);
    sigchld++;
}
  
int main1(){
    signal(SIGCHLD, sigchld_handler_nowait);
    if(fork() & fork()){
        cout << "Me=" << getpid() << endl;
        unsigned int leftover = 1;
        while((leftover = sleep(leftover))); // The sleep is to allow both children time to exit.
        cout << sigchld << endl;
        int status;
        pid_t pid;
        while ( (pid=waitpid(-1,&status,WNOHANG)) != -1 ) {
            if ( pid != 0 ) {
                cout << "Reaped child=" << pid << " with exit status=" << WEXITSTATUS(status) << endl;
            }
        }
    } else {
        pid_t me = getpid();
        cout << "Child=" << me << " of parent=" << getppid() << endl;
        return me % 10;
    }
    return 0;
}
int main(){
	//main1();
	printf("======================================\n");
    signal(SIGCHLD, sigchld_handler);
	pid_t pid;
    if(pid=fork() != 0) {
        cout << "Me=" << getpid() << endl;
        unsigned int leftover = 1;
        while((leftover = sleep(leftover))); // The sleep is to allow both children time to exit.
        cout << sigchld << endl;
        int status;
        pid_t pid2;
    	if(pid2=fork() == 0) {
        	cout << "Child=" << getpid() << " of parent=" << getppid() << endl; 
			sleep(1);
			exit(0);
		}
        while ( (pid=waitpid(-1,&status,WNOHANG)) != -1 ) {
            if ( pid != 0 ) {
                cout << "Reaped child=" << pid << " with exit status=" << WEXITSTATUS(status) << endl;
            }
        }
    } else {
        pid_t me = getpid();
		sleep(1);
        cout << "Child=" << me << " of parent=" << getppid() << endl;
        return me % 10;
    }
    return 0;
}
