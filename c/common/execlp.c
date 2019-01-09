#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <errno.h>
#include <string.h>
#include <sys/wait.h>
//#include <mcheck.h>

//#define SHELL_NAME "/bin/sh"
#define SHELL_NAME "sh"

void check_error (int err) {
    if (err) {
        printf ("Error : %s\n", strerror (errno));
        exit (1);
    }
}

char* new_thread_execvp (char *param) {
    int err;
    pid_t child, pid;
	//const char *argv[] = { SHELL_NAME, "-c", "echo sh_pid=$$; sleep 2; exec getpid -c -b -d", NULL }; 
	const char *argv[] = { SHELL_NAME, "-c", "echo sh_pid=$$; exec getpid -c -b -d", NULL }; 

    child = fork ();
    check_error (child == -1);

    if (child == 0) {
        //err = execvp ("getpid", "getpid", "-n", (char *) NULL);
		execvp(SHELL_NAME, (char *const *)argv);
        check_error (err == -1);
    }

	printf("execvp: child pid = %d\n", child);
    pid = waitpid (child, NULL, 0);
    check_error (pid == -1);

    return NULL;
}
void *new_thread_execlp (void *param) {
    int err;
    pid_t child, pid;

    child = fork ();
    check_error (child == -1);

    if (child == 0) {
        err = execlp ("getpid", "getpid", "-n", (char *) NULL);
        check_error (err == -1);
    }

	printf("execlp: child pid = %d\n", child);
    pid = waitpid (child, NULL, 0);
    check_error (pid == -1);

    return NULL;
}

int main (int argc, char **argv) {
    int i, err;
    pthread_t thread[50];
    pthread_attr_t attr;

    //mtrace();
    err = pthread_attr_init (&attr);
    check_error (err);

    for (i=0; i<1; i++) {
        err = pthread_create (thread+i, &attr, new_thread_execlp, NULL);
        check_error (err);
    }
	//usleep(1000);
	sleep(1);
	new_thread_execvp(NULL);
    for (i=0; i<0; i++) {
        //err = pthread_create (thread+i, &attr, new_thread_execvp, NULL);
        check_error (err);
    }

    for (i=0; i<1; i++) {
        err = pthread_join (thread[i], NULL);
        check_error (err);
    }

    return 0;
}
