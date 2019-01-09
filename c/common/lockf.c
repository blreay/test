#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

    int fd[8000];

void write_lock(char *path, int i)
{
    int error;

    fd[i] = open(path, O_CREAT | O_RDWR, 0664);
    if (fd[i] < 0) {
        perror("open");
        exit(EXIT_FAILURE);
    }

     printf("%s\n", path);
    // if len is zero, lock all bytes
	while (1) {
    error = lockf(fd[i], F_TLOCK, 0);
    if (error == 0) {
        printf("%#x: lock succeeds!\n", getpid());
	break;
	}
    else {
        printf("lockf error(%d) %s\n", errno, strerror(errno));
	sleep(1);
		continue;
	}
	}

    //sleep(1);
    //lockf(fd, F_ULOCK, 0);
    //close(fd);
}

int main(int argc, char** argv, char** env)
{
    pid_t pid;
	int i=0;
	//char* fnbase="/home/zhaozhan/tmp/1";
	//char* fnbase="/scratch/zhaozhan/tmp/1";
	char* fnbase="/mnt/nfs/0";
	char fn[1024]={'0'};

    setlinebuf(stdout);
	for (i=0; i<=atoi(argv[1]); i++) {
	sprintf(fn, "%s%d", fnbase, i);
    //pid = fork();
    //if (pid == 0) {
        //write_lock(fn);
	//	return 0;
    //} else {
        write_lock(fn, i);
    //}
	}
	sleep(600);
    return 0;
}
