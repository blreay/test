#include <pthread.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#define handle_error_en(en, msg) \
	do { errno = en; perror(msg); exit(EXIT_FAILURE); } while (0)

#define userlog printf
#define JESTRACE printf
#define JES_THREAD_STK_SIZE (1024*1024*8)

pthread_t thread_id;                 
pthread_attr_t g_thread_attr;        

static int done = 0;
static int cleanup_pop_arg = 1;
static int cnt = 0;

static void
cleanup_handler(void *arg)
{
	printf("Called clean-up handler\n");
	cnt = 0;
}

static void *
thread_start(void *arg)
{
	time_t start, curr; 
	printf("New thread started\n"); 
	pthread_cleanup_push(cleanup_handler, NULL); 
	curr = start = time(NULL); 
	while (!done) {
		//pthread_testcancel();           /* A cancellation point */
		if (curr < time(NULL)) {
			curr = time(NULL);
			printf("cnt = %d\n", cnt);  /* A cancellation point */
			cnt++;
		}
	}

	pthread_cleanup_pop(cleanup_pop_arg);
	return NULL;
}

int set_thread_attr(pthread_attr_t * attr, size_t stk_size)                                        
{                                                                                                  
    char *strFuncName = "set_thread_attr";                                                         
    int ret = 0;                                                                                   
                                                                                                   
    JESTRACE("[%s]attr=0x%08x, stk_size=%d", strFuncName, attr, stk_size);                         
    if (NULL == attr) {                                                                            
        return 1;                                                                                  
    }                                                                                              
    ret = pthread_attr_init(attr);                                                                 
    if (0 != ret) {                                                                                
        userlog("[%s]ERROR:Failed to call pthread_attr_init: %s", strFuncName, strerror(errno));   
        return 2;                                                                                  
    }                                                                                              
    ret = pthread_attr_setstacksize(attr, stk_size);                                               
    if (0 != ret) {                                                                                
        userlog("[%s]ERROR:Failed to set stack size: %s", strFuncName, strerror(errno));           
        return 3;                                                                                  
    }                                                                                              

    /* set "detatch" attribute, so that it can clean itself, and server shutdown don't need to join this thread */    
    ret = pthread_attr_setdetachstate(&g_thread_attr, PTHREAD_CREATE_DETACHED);                                             
    if (0 != ret) {                                                                                
        userlog("[%s]ERROR:Failed to set PTHREAD_CREATE_DETACHED %s", strFuncName, strerror(errno));           
        return 3;                                                                                  
    }                                                                                              
                                                                                                                      
    return 0;                                                                                      
}                                                                                                  

int main(int argc, char *argv[])
{
	pthread_t thr;
	int s;
	void *res;
	int ret = 0;


	if (argc > 1) {
		if (argc > 2){
		  cleanup_pop_arg = atoi(argv[2]);
			userlog("cleanup_pop_arg=%d\n", cleanup_pop_arg);
		}

	} else {
/* 		printf("Canceling thread\n"); */
/* 		s = pthread_cancel(thr); */
/* 		if (s != 0) */
/* 		  handle_error_en(s, "pthread_cancel"); */
	}

    ret = set_thread_attr(&g_thread_attr, JES_THREAD_STK_SIZE);                                           
    if (ret != 0) {                                                                                       
        userlog("ERROR:Failed to set thread stack size(%ld):%s", JES_THREAD_STK_SIZE, strerror(errno));   
        return -1;                                                                                        
    }                                                                                                     

	s = pthread_create(&thr, &g_thread_attr, thread_start, NULL);
	if (s != 0)
	  handle_error_en(s, "pthread_create");


	sleep(3);           /* Allow new thread to run a while */
/* 	s = pthread_join(thr, &res); */
/* 	if (s != 0) */
/* 	  handle_error_en(s, "pthread_join"); */
/*  */
/* 	if (res == PTHREAD_CANCELED) */
/* 	  printf("Thread was canceled; cnt = %d\n", cnt); */
/* 	else */
/* 	  printf("Thread terminated normally; cnt = %d\n", cnt); */
/* 	exit(EXIT_SUCCESS); */
	//done = 1;
	userlog("exit from main()");
}
