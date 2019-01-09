#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <errno.h>
#include <string.h>
#include <sys/wait.h>
#ifdef linux
#include <mcheck.h>
#endif

void check_error (int err) {
    if (err) {
        printf ("Error : %s\n", strerror (errno));
        exit (1);
    }
}

void *new_thread (void *param) {
    int err;
    pid_t child, pid;

    child = fork ();
    check_error (child == -1);

    if (child == 0) {
        err = execlp ("echo", "echo", "-n", (char *) NULL);
        check_error (err == -1);
    }

    pid = waitpid (child, NULL, 0);
    check_error (pid == -1);

    return NULL;
}

int main (int argc, char **argv) {
    int i, err;
    pthread_t thread[50];
    pthread_attr_t attr;

#ifdef linux
    mtrace();
#endif
    err = pthread_attr_init (&attr);
    check_error (err);

    for (i=0; i<50; i++) {
        err = pthread_create (thread+i, &attr, new_thread, NULL);
        check_error (err);
    }

    for (i=0; i<50; i++) {
        err = pthread_join (thread[i], NULL);
        check_error (err);
    }

    return 0;
}
