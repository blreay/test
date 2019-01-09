#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
//#include <file.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define TMDEBUG(a,b) printf b

int find_oneline_in_txtfile(char *file, char *strfind)                       
{                                                                                
    FILE *fp = NULL;                                                             
    int str_len = 0;
	char line[1024*4] = { '\0' };
	int pos = -1;
                                                                                 
    if ((access(file, F_OK)) == -1) {                                            
		TMDEBUG(_TSAMNW_DBG_LEVEL,("File %s does not exist: %s", file, strerror(errno)));
        return -1;                                                               
    }                                                                            
                                                                                 
    fp = fopen(file, "r");                                                       
    if (fp == NULL) {                                                            
		TMDEBUG(_TSAMNW_DBG_LEVEL,("Can not open file %s: %s", file, strerror(errno)));
        return -1;                                                               
    }                                                                            
                                                                                 
	while (fgets(line, sizeof(line) - 1, fp)) {       		
		TMDEBUG(_TSAMNW_DBG_LEVEL,("read one line: %s", line));
		if (*(line+strlen(line)-1) == '\n' ) {
			TMDEBUG(_TSAMNW_DBG_LEVEL,("remove return key\n"));
			*(line+strlen(line)-1) = '\0';
		}
		if (0 == strcmp(line, strfind)) {
			TMDEBUG(_TSAMNW_DBG_LEVEL,("found string"));
			pos = ftell(fp);
			break;
		}
		if (feof(fp) != 0) {             
			 TMDEBUG(_TSAMNW_DBG_LEVEL,("read end"));
		     break;                       
		}
    }
	
	fclose(fp);
    return pos;
}
int main( int argc, char *argv[] )
{
	if ( argc == 0 ) {
		printf("usage: \n maplogread 50000.txt\n");
		return 0;
	}
	char *fn = argv[1];
	char *strtofind = argv[2];
	int pos = find_oneline_in_txtfile(fn, strtofind);
	printf("Pos: %d\n", pos);
	exit(0); 
}
