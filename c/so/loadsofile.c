#include "stdio.h" 
#include "dlfcn.h" 
#define SHARED /* 定义宏,确认共享,以便引用动态函数 */


int load_so_file(char* filename)
{
      void *dp;
      char *error;
      
      printf("BEGIN>>>sample to load so file:%s\n", filename);
      
      dp=dlopen(filename,RTLD_NOW|RTLD_GLOBAL); /* 打开动态链接库 */
      
      if (dp==NULL) /* 若打开失败则退出 */
      {
          fputs(dlerror(),stderr);
		  fputs("\n",stderr);
          return(24);
      }
      
	  void (*getdate) ();
      getdate=dlsym(dp,"libuser_dyn_main1");
      error=dlerror(); /* 检测错误 */
      if (error) /* 若出错则退出 */
      {
          fputs(error,stderr);
		  fputs("\n",stderr);
          return(23);
      }
      
      getdate(); /* 调用此共享函数 */
      puts("END>>>sample to load so file");
      /*dlclose(dp);*/ /* 关闭共享库 */      
      return(5); /* 成功返回 */       
 }
