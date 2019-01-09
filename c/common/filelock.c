#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <fcntl.h>
#include <stdlib.h>
#include <signal.h>
#include <errno.h>

#define ARTJES2_JOBID_LEN 8
#define JES2_MAX_FILE 1024
#define JES_DBG printf
#define JES_ERR printf
#define JES_WARN printf
#define JES_DUMP printf

#define NC(x) ((x) == NULL ? "NULL" : (x))

int isdelayexec = 1;
char* jesroot = "/home/zhaozhan/tmp";
int g_nfd = -1;

int read_file_content(const char *file_name, char **file_content, int write_err)
{
    int file_size = 0;
    int file_ds = open(file_name, O_RDONLY);

    if (file_ds == -1) {
        JES_DUMP("cannot open %s:%s", NC(file_name), strerror(errno));
        return -1;
    }

    file_size = read_fd_content(file_ds, file_content, write_err);
    close(file_ds);

    return file_size;
}

int read_fd_content(int file_ds, char **file_content, int write_err)
{
    int file_size = 0;
    struct stat file_stat;

    if (fstat(file_ds, &file_stat) == -1) {
        JES_ERR("cannot get the stat of file: %s", strerror(errno));
        close(file_ds);
        return -1;
    }

    file_size = file_stat.st_size;

    *file_content = NULL;
    *file_content = malloc(file_size + 1);
    if (*file_content == NULL) {
        JES_ERR("cannot malloc size %d", file_size + 1);
        close(file_ds);
        return -1;
    }

    (*file_content)[file_size] = '\0';
    if (read(file_ds, *file_content, file_size) != file_size) {
        JES_ERR("read the file error: %s", strerror(errno));
        close(file_ds);
        free(*file_content);
        *file_content = NULL;
        return -1;
    }

    return file_size;
}


static int isdelay(char *jobname, char *jobid, int *fd)
{
    char filename[JES2_MAX_FILE + 1] = { '\0' };
    int waiting = 0;
    int nfd = -1;
    int ret = 0;

    if (!isdelayexec) {
        return 0;
    }

    JES_DBG("Enter jobid=%s jobname=%s fd=%p", jobid, jobname, fd);
    sprintf(filename, "%s/runningjobs/%s", jesroot, jobname);

/*      nfd = open(filename, O_RDWR | O_CREAT | O_EXCL, 00666);  */
     nfd = open(filename, O_RDWR | O_CREAT, 00666); 
    if (nfd == -1) {
        JES_ERR("Can't open runnjing job lock file %s: %d %s", filename, errno, strerror(errno));
        return 1;
    }
    JES_DBG("lock running job file or waitting lock: %s jobid=%s FD=%d", filename, jobid, nfd);

    struct flock fl = { F_WRLCK, SEEK_SET, 0, 0, 0 };
    fl.l_pid = getpid();

    /* get file lock */
    if (fcntl(nfd, waiting ? F_SETLKW : F_SETLK, &fl) == -1) {
        if (!waiting && (errno == EACCES || errno == EAGAIN)) {
            JES_DBG("Failed to get file lock(nowait) %s FD=%d jobid=%s %d: %s", filename, nfd, jobid, errno, strerror(errno));
        } else {
            JES_DBG("Failed to get file lock %s FD=%d jobid=%s %d: %s", filename, nfd, jobid,  errno, strerror(errno));
        }
        close(nfd);
        return 1;
    }
    write(nfd, jobid, ARTJES2_JOBID_LEN);

    *fd = nfd;
    JES_DBG("Enter jobid=%s jobname=%s *fd=%d", jobid, jobname, *fd);
    return 0;
}

/* static int unlock2_runningjob(char* jobname) */
static int deleterunningjob(char *jobname, char *jobid)
{
    char filename[JES2_MAX_FILE + 1] = { '\0' };
    int nfd = -1;
/*     JES2_JOBPARM *job = NULL; */

    if (jobname == NULL || jobid == NULL) {
        return;
    }
    if (!isdelayexec) {
        return;
    }

    JES_DBG("Enter jobid=%s jobname=%s", jobid, jobname);
    sprintf(filename, "%s/runningjobs/%s", jesroot, jobname);

	nfd=g_nfd;

    JES_DBG("close fd: %d", nfd);
    if ((nfd != -1)) {
		if (close(nfd) == -1) {
			JES_ERR("Failed to close job %d: %s", nfd, strerror(errno));
		} 
		/*     pthread_mutex_unlock(&g_runningjob_locker); */ 
		int ret = unlink(filename);
		if (0 != ret) {
			JES_ERR("Failed to delete file(%s) for reschedule: %d, %s", filename, errno, strerror(errno));
		}
	} else {
    	JES_DBG("duplicate running job lock released: id=%s %s", jobid, jobname);
	}

    JES_DBG("Exit jobid=%s jobname=%s", jobid, jobname);
    return 0;
}


int main(int argc, char** argv) {
	printf("argc=%d argv=%p\n", argc, argv);
	if (argc == 2) {
		jesroot=argv[1];
	}
	printf("begin jesroot=%s\n", jesroot);
	isdelay("jobname111", "000", &g_nfd);
	JES_DBG("\n");
	isdelay("jobname111", "000", &g_nfd);
	JES_DBG("\n");
	deleterunningjob("jobname111", "000");
	JES_DBG("\n");
}
