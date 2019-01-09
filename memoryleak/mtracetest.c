#include <stdlib.h>
#include <mcheck.h>
 
  void f(void)
  {
     int* x = malloc(10 * sizeof(int));
     //x[10] = 0;        // problem 1: heap block overrun
  }                    // problem 2: memory leak -- x not freed
 
  void f2(void)
  {
     int* x = malloc(20 * sizeof(int));
     //x[10] = 0;        // problem 1: heap block overrun
  }                    // problem 2: memory leak -- x not freed

  int main(void)
  {
	int i=0;
	char mpath[1024] = { '\0' };
	char *rootpath = "/nfs/users/zhaozhan/test/memoryleak";
	sprintf(mpath, "MALLOC_TRACE=%s/mtrace.log.%d", rootpath, i++);
	putenv(mpath);
	mtrace(); /* Starts the recording of memory allocations and releases */
    f();
	muntrace();

	sprintf(mpath, "MALLOC_TRACE=%s/mtrace.log.%d", rootpath, i++);
	putenv(mpath);
	mtrace(); /* Starts the recording of memory allocations and releases */
    f2();
	muntrace();

    return 0;
  }
 
