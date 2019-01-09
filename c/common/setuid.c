#include <stdio.h>
#include <stdarg.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>

//#define SHELL_NAME "bash"
//#define SHELL_NAME "vim"
#define SHELL_NAME "bash"
//#define SHELL_NAME "/scratch2/zhaozhan/setuid2"
#define NC(x) (x==NULL?"NULL":x)
#define JES_DBG JESDEBUG
#define JES_ERR  JESDEBUG

void showid () {
	JES_DBG("(%d) uid: %d\n", getpid(), getuid());
	JES_DBG("(%d)euid: %d\n", getpid (),geteuid());
}

void JESDEBUG(char *fmt, ...)
{
    char buf[1024 * 2] = { '\0' };
    char *jestrace;
    static int trace_init = -1;
    va_list args;

    if (trace_init == -1) {
        if ((jestrace = getenv("MYDBG")) != NULL && strcmp(jestrace, "DEBUG") == 0) {
            trace_init = 1;
        } else {
            trace_init = 0;
        }
    }
    if (trace_init == 1) {
        va_start(args, fmt);
        vsnprintf(buf, sizeof(buf), fmt, args);
        va_end(args);

        printf("[%08d]:%s\n", getpid(), buf);
    }
}

/* evaluate system() but call waitpid in async mode
The  value returned is -1 on error (e.g.  fork() failed),
and the return status of the command otherwise*/
int jes_system(const char *command, char *err)
{
    //const char *argv[] = { SHELL_NAME, "-i", command, NULL };
    const char *argv[] = {command, "-p", NULL };
    int status = -1;
    JES_DBG("IN command=%s", NC(command));

    pid_t pid = fork();
    /*child process */
    if (pid == (pid_t) 0) {
		seteuid(0);
		showid();
        execvp(SHELL_NAME, (char *const *)argv);
        /*if execvp success, following statements shouldn't be reached */
        JES_ERR("execvp(%s %s %s) failed: %d %s", argv[0], argv[1], argv[2], errno, strerror(errno));
        _exit(-127);
    }

    /* fork error */
    if (pid < (pid_t) 0) {
        sprintf(err, "Failed to fork %d %s", errno, strerror(errno));
        JES_ERR("%s", err);
        return -1;
    }

    /*father process */
    long retry = 1;
    while (1) {
        JES_DBG("call waitpid(%d) with loop, retry(%ld)", pid, retry++);
        pid_t retpid = waitpid(pid, &status, WNOHANG);
        if (retpid == pid) {
            JES_DBG("finish waitpid(%d)", pid);
            break;
        } else if (retpid == -1) {
            sprintf(err, "fail to waitpid (pid=%ld) %d %s", pid, errno, strerror(errno));
            JES_ERR("%s", err);
            return -1;
        } else {
            JES_DBG("process (%ld) not finished, retpid=%d", pid, retpid);
        }
        usleep(1000 * 500);     /* sleep 0.1 second */
    }

    JES_DBG("OUT status=%d", status);
    return status;
}
int main (int argc, char** argv) {
	char* file="/testuid";
	char* file2="/testuid_child_can_be_deleted";
	char errmsg[1024] = { '\0' };
	int ret = 0;
	JES_DBG("start=======================\n");
	showid();
	/*
	FILE* f = fopen(file, "a+");
	if (NULL == f) {
		JES_DBG("open failed(%d), errno=%d, msg=%s\n", ret, errno, NC(strerror(errno)));
	}else {
		JES_DBG("open OK\n");
	}
	//ret = unlink(file);
	if (0 != ret) {
		JES_DBG("unlink failed(%d), errno=%d, msg=%s\n", ret, errno, NC(strerror(errno)));
	}else {
		JES_DBG("unlink OK\n");
	}
	JES_DBG("test file access\n");
	system("touch /testuid");
	*/
	if (argc == 1) {
		char* A[]={ SHELL_NAME, "-p", NULL};
		setuid(0);
		//seteuid(0);
		JES_DBG("after setuid(0)====================\n");
		showid();
		int ret=execvp(SHELL_NAME, A);
		// test what will happen if fork is called
		//jes_system(SHELL_NAME, errmsg); 
		JES_DBG("execvp return %d, errno=%d, msg=%s\n", ret, errno, strerror(errno));
	} else {
		FILE* f = fopen(file2, "a+");
		if (NULL == f) {
			JES_DBG("open failed(%d), errno=%d, msg=%s\n", ret, errno, NC(strerror(errno)));
		}else {
			printf("open OK:%s\n", file2);
		}
		ret = unlink(file2);
		if (0 != ret) {
			JES_DBG("unlink failed(%d), errno=%d, msg=%s\n", ret, errno, NC(strerror(errno)));
		}else {
			printf("unlink OK:%s\n", file2);
		}
	}
}
