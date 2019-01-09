#include <pthread.h>
#include <semaphore.h>
#include <limits.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

long g_stacksize=0;
#ifndef PTHREAD_STACK_MIN
#define PTHREAD_STACK_MIN 10
#endif

unsigned int getStackSize(pthread_t task)
{
    unsigned int err,size;
    pthread_attr_t attr;
    void *stack_base = NULL;
    memset(&attr,0,sizeof(attr));
    if(0 == task)
    {
        return -1;
    }
    err = pthread_attr_init(&attr);
    if(err !=0)
    {
        return -1;
    }
/*
    pthread_getattr_np((pthread_t)task, &attr);
    if( 0 == pthread_attr_getstack(&attr,(void*)&stack_base,&size) )
    {
        err = 0;
    }
    else
    {
        err = -1;
    }
*/
    pthread_attr_destroy(&attr);
    return size;
}
void thread_function1()
{
    size_t stacksize;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_getstacksize (&attr, &stacksize);
    printf("IN THREAD stack size = %lu KB (setsize: %ld)\n", stacksize / 1024, g_stacksize);
}

void  testsize(int stacksize, int ifset)
{
    int err,size;
    pthread_t pt1=0;
    pthread_attr_t      attr1;
    memset(&attr1, 0, sizeof(attr1));
    err=pthread_attr_init(&attr1);
    //printf("pthread_attr_init 1 err=%d\n",err);
    int pagesize=getpagesize();
    //printf("pagesize=%d\n",pagesize);
    //printf("getpagesize()=%d\n",getpagesize());
    //printf("stacksize-stacksize  pagesize+pagesize=%ld\n",(stacksize-(stacksize%pagesize)+pagesize));
        if (ifset) {
                        err=pthread_attr_setstacksize(&attr1,stacksize);
			g_stacksize=stacksize;
                        err=pthread_create(&pt1,&attr1,thread_function1, NULL);
        } else {
                        err=pthread_create(&pt1,NULL,thread_function1, NULL);
        }
    //printf("pthread_attr_setstacksize stacksize=%ld err=%d\n",stacksize,err);
    //printf("pthread_create 1 err=%d\n",err);
	/*
    size=getStackSize(pt1);
    if(stacksize==size)
    {
        printf("input stacksize== really size==%d\n",stacksize);
    }else
    {
        printf("input stacksize==%d,!=reallly size==%d\n",stacksize,size);
    }
*/

    pthread_join(pt1,NULL);
}
int main(int argc, char *argv[])
{
    int size=65530;
    printf("PTHREAD_STACK_MIN=%d\n",PTHREAD_STACK_MIN);
    printf("Test default stack size:\n");
    testsize(size, 0);

    printf("Test specified stack size\n");
    while(size<72660)
    {
        testsize(size*10, 1);
        size++;
    }
    return 0;
}

