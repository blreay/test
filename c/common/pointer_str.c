#include "stdio.h"

void main()
{
	int nextpid = 1000;
	int scancount = 2000;
	long QM_SEMTBLSIZE = 9223372036854775807;
	int semidx = 4000;
	int semno = 5000;
	int next = 6000;
	int deadlockeridx = 7000;
	int sempid = 8000;
	printf("hello,world\n");
	//printf("ERROR: The queue space is deadlocked, report code %ld,%ld",(long) fileidx, (long) line);
	printf("additional deadlock diagnostic (%ld/%ld/%ld/%ld/%ld/%ld/%ld/%ld)\n",nextpid,scancount,QM_SEMTBLSIZE,semidx,semno,next,deadlockeridx,sempid);
	char b[20]="/tmp/aa";
	char *a=b;
	if (a) {
		printf("a is not 0");
	} else {
		printf("a is 0");
	}
}


// if (++curr_deadlocker_cnt > max_curr_deadlocker_cnt) {
// /* Consecutive max_curr_deadlocker_cnt iterations with same deadlocker, mark insane... */
// (void) userlog(_MHS_(Q_CAT,2217,MHS_USERLOG,
// "ERROR: The queue space is deadlocked, report code %ld,%ld"),
// (long) fileidx, (long) line);
// (void) userlog(
// "     : additional deadlock diagnostic (%ld/%ld/%ld/%ld/%ld/%ld/%ld/%ld)",
// nextpid,scancount,QM_SEMTBLSIZE,semidx,semno,next,deadlockeridx,sem->pid);

// if (QMPTR != NULL)
// QM_SET_RESTART;
// if (0 != dddbg_locklog_flag) {
// dddbg_dump_locklog(_TCARG);
// dddbg_dump_shmem(_TCARG);
// }
// QM_LONGJMP(QM, 1);
// }

