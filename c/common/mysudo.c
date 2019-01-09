#include <stdio.h>
#include <stdarg.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

//#define SHELL_NAME "bash"
//#define SHELL_NAME "vim"
#define SHELL_NAME "bash"
//#define SHELL_NAME "/scratch2/zhaozhan/setuid2"
#define NC(x) (x==NULL?"NULL":x)
#define JES_DBG JESDEBUG
#define JES_ERR  JESERR
int testroot() {
	int ret = 0;
	char* file2="/testuid_child_can_be_deleted";
	// create file in /
	FILE* f = fopen(file2, "a+");
	if (NULL == f) {
		printf("open failed(%d), errno=%d, msg=%s", ret, errno, NC(strerror(errno)));
		return 1;
	}else {
		printf("open OK:%s", file2);
	}
	fclose(f);

	// delete this file
	ret = unlink(file2);
	if (0 != ret) {
		printf("unlink failed(%d), errno=%d, msg=%s", ret, errno, NC(strerror(errno)));
		return 1;
	}else {
		printf("unlink OK:%s", file2);
	}
	return 0;
}
void showid () {
	JES_DBG("(%d) uid: %d", getpid(), getuid());
	JES_DBG("(%d)euid: %d", getpid (),geteuid());
}

void JESERR(char *fmt, ...) {
    char buf[1024 * 2] = { '\0' };
    va_list args; 
	va_start(args, fmt);
	vsnprintf(buf, sizeof(buf), fmt, args);
	va_end(args); 
	fprintf(stderr, "[%08d]:%s\n", getpid(), buf);
}
void JESDEBUG(char *fmt, ...) {
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
int dumpargv(int argc, char** argv) {
	JES_DBG("=========argv[%p][%d]========B======", argv, argc);
	int i=0;
	for(i=0; i<=argc; i++) {
		JES_DBG("argv[%d]=%s", i, NC(argv[i]));
	}
	JES_DBG("=========argv[%p][%d]========E======", argv, argc);
}
int main (int argc, char** argv) {
	char* BASH_ARGV[]={ SHELL_NAME, "-p", NULL};
	char** pargv = BASH_ARGV;
	char errmsg[1024] = { '\0' };
	int ret = 0;
	dumpargv(argc, argv);
	JES_DBG("start=======================");
	showid();
	if (argc == 1) {
		JES_DBG("launch bash");
		pargv = (char**)BASH_ARGV; 
		dumpargv(2, pargv);
	} else {
		JES_DBG("launch specified program");
		pargv = argv+1;
		dumpargv(argc-1, pargv);
	}

	setuid(0);
	setgid(0);
	if (0 != getuid()) {
		JES_ERR("setuid(0) failed, check SETUID bit");
		return 1;
	}
	//setenv("HOME", "/root", 1);
	JES_ERR("HOME is \033[44;31;1m %s\033[0m, suggest to change it with: \033[44;31;1m export HOME=/root\033[0m", getenv("HOME"));
	ret = execvp(pargv[0], pargv);
	//ret = jes_system(SHELL_NAME, errmsg); 
	JES_ERR("execvp return %d, errno=%d, msg=%s", ret, errno, strerror(errno));
}
