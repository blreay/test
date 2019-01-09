#include <limits.h>
#include <stdlib.h>
#include <pthread.h>
/*#include <errors.h>*/
#ifndef PTHREAD_STACK_MIN
#define PTHREAD_STACK_MIN 10
#endif

static char* ary[] = {
"aaa",
"bbb",
"QQ.exe",
"ccc",
NULL
};

int err_abort(int ret, char* msg) {
   printf("%s:%d", msg, ret);
   _Exit(1);
}

void *thread_routine (void *arg) { 
    printf ("The thread is here\n"); 
    char p[1024*1024*15];         
	int i=1024*1024*15;  
	while(i--){ 
		  p[i] = 3;
	}  
    printf( "Get 15M Memory!!!\n" );

    char p2[ 1024 * 1020 + 256 ];
    memset( p2, 0, sizeof( char ) * ( 1024 * 1020 + 256 ) );
    printf( "Get More Memory!!!\n" );
    return NULL;
 }  

int main (int argc, char *argv[]) { 
    pthread_t thread_id; 
    pthread_attr_t thread_attr;
    size_t stack_size;
    int status;
	int i=0;

	printf("sizeof(ary)=%d\n", sizeof(ary));
	i=0;
	while (ary[i] != NULL) {
		printf("ary[%d]=%s\n", i, ary[i]);
		i++;
	}
  
    status = pthread_attr_init (&thread_attr);
     if (status != 0) 
        err_abort (status, "Create attr");
  
    status = pthread_attr_setdetachstate (&thread_attr, PTHREAD_CREATE_DETACHED);  
    if (status != 0) 
        err_abort (status, "Set detach");
 
    status = pthread_attr_getstacksize (&thread_attr, &stack_size);
     if (status != 0) 
        err_abort (status, "Get stack size");
 
    printf ("Default stack size is %u; minimum is %u\n",  stack_size, PTHREAD_STACK_MIN);
  
    status = pthread_attr_setstacksize ( &thread_attr, 17*1024*1024);
     if (status != 0) 
        err_abort (status, "Set stack size");
          
    status = pthread_attr_getstacksize (&thread_attr, &stack_size);
if (status != 0) 
        err_abort (status, "Get stack size");
 
    printf ("Default stack size is %u; minimum is %u\n", stack_size, PTHREAD_STACK_MIN);        
    i = 5; 
      while(i--) { 
               status = pthread_create (&thread_id, &thread_attr, thread_routine, NULL);
                if (status != 0) 
                       err_abort (status, "Create thread");
         }  
    //getchar(); 
    printf ("Main exiting\n");
     pthread_exit (NULL);
     return 0;
 }
