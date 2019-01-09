#include <sys/time.h>
#include <time.h>
#include <stdio.h> 

struct timespec *diff(struct timespec *start, struct timespec *end);
struct timespec t1;

int main()
{
	struct timespec time1, time2;
	int i;
	int temp = 0;
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1);
	for (i = 0; i< 242000000; i++)
	  temp+=temp;
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time2);
	printf("sec: %d, nsec: %f\n",diff(&time1,&time2)->tv_sec,    diff(&time1,&time2)->tv_nsec);
	//cout<<diff(time1,time2).tv_sec<<":"<<diff(time1,time2).tv_nsec<<endl;
	return 0;
}

struct timespec *diff(struct timespec *start, struct timespec *end)
{
	struct timespec *temp = &t1;
	if ((end->tv_nsec-start->tv_nsec)<0) {
		temp->tv_sec = end->tv_sec-start->tv_sec-1;
		temp->tv_nsec = 1000000000+end->tv_nsec-start->tv_nsec;
	} else {
		temp->tv_sec = end->tv_sec-start->tv_sec;
		temp->tv_nsec = end->tv_nsec-start->tv_nsec;
	}
	return temp;
}
