// #define _GNU_SOURCE

       // #include <stdio.h>
       // #include <time.h>
       // #include <stdlib.h>
       // #include <unistd.h>
       // #include <sys/resource.h>

       // int
       // main(int argc, char *argv[])
       // {
           // struct rlimit64 old, new;
           // struct rlimit64 *newp;
           // pid_t pid;

           // if (!(argc == 2 || argc == 4)) {
               // fprintf(stderr, "Usage: %s <pid> [<new-soft-limit> "
                       // "<new-hard-limit>]\n", argv[0]);
               // exit(EXIT_FAILURE);
           // }

           // pid = atoi(argv[1]);        /* PID of target process */

           // newp = NULL;
           // if (argc == 4) {
               // new.rlim_cur = atoi(argv[2]);
               // new.rlim_max = atoi(argv[3]);
               // newp = &new;
           // }

           // /* Set CPU time limit of target prcess; retrieve and display
              // previous limit */

           // if (prlimit(pid, RLIMIT_CPU, newp, &old) == -1)
               // errExit("prlimit-1");
           // printf("Previous limits: soft=%lld; hard=%lld\n",
                   // (long long) old.rlim_cur, (long long) old.rlim_max);

           // /* Retrieve and display new CPU time limit */

           // if (prlimit(pid, RLIMIT_CPU, NULL, &old) == -1)
               // errExit("prlimit-2");
           // printf("New limits: soft=%lld; hard=%lld\n",
                   // (long long) old.rlim_cur, (long long) old.rlim_max);

           // exit(EXIT_FAILURE);
       // }
	   
#include<sys/time.h>
#include<sys/resource.h>
#include<unistd.h>
#include <stdio.h> 

int main()
{
  struct rlimit limit;
 char p = '1';
 if(getrlimit(RLIMIT_CORE, &limit))
 {
  printf("set limit failed\n");
 }
 printf("p = %c\n limit.rlim_cur=%d\n; limit.rlim_max=%d\n ",p, limit.rlim_cur, limit.rlim_max);
 // limit.rlim_cur = RLIM_INFINITY;
 // limit.rlim_max = RLIM_INFINITY;
 limit.rlim_cur = 2;
 limit.rlim_max = 3;
 if(setrlimit(RLIMIT_CORE, &limit))
 {
  printf("set limit failed\n");
 }
 if(getrlimit(RLIMIT_CORE, &limit))
 {
  printf("set limit failed\n");
 }
 printf("p = %c\n limit.rlim_cur=%d\n; limit.rlim_max=%d\n ",p, limit.rlim_cur, limit.rlim_max);
} 