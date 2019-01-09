#include "stdio.h" 
#include "dlfcn.h" 
#define SHARED /* �����,ȷ�Ϲ���,�Ա����ö�̬���� */


int load_so_file(char* filename)
{
      void *dp;
      char *error;
      
      printf("BEGIN>>>sample to load so file:%s\n", filename);
      
      dp=dlopen(filename,RTLD_NOW|RTLD_GLOBAL); /* �򿪶�̬���ӿ� */
      
      if (dp==NULL) /* ����ʧ�����˳� */
      {
          fputs(dlerror(),stderr);
		  fputs("\n",stderr);
          return(24);
      }
      
	  void (*getdate) ();
      getdate=dlsym(dp,"libuser_dyn_main1");
      error=dlerror(); /* ������ */
      if (error) /* ���������˳� */
      {
          fputs(error,stderr);
		  fputs("\n",stderr);
          return(23);
      }
      
      getdate(); /* ���ô˹����� */
      puts("END>>>sample to load so file");
      /*dlclose(dp);*/ /* �رչ���� */      
      return(5); /* �ɹ����� */       
 }
