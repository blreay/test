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
long read_buf_from_txtfile(char *file, long startpos, long readsize, char* buf)
{                                                                                
    FILE *fp = NULL;                                                             
    int str_len = 0;
	char line[1024*4] = { '\0' };
	int pos = -1;
	struct stat statBuf;
	long filesize = 0;
	long ret = 0;
                                                                                 
    if ((access(file, F_OK)) == -1) {
		TMDEBUG(_TSAMNW_DBG_LEVEL,("File %s does not exist: %s", file, strerror(errno)));
        return -1;
    }

	memset(&statBuf, 0x0, sizeof(statBuf));
	if (stat(file, &statBuf) != 0) {  
		TMDEBUG(_TSAMNW_DBG_LEVEL,("stat(%s) failed: %s", file, strerror(errno)));
        return -1;
	}
	filesize = statBuf.st_size;

	if(startpos >= filesize) {
		TMDEBUG(_TSAMNW_DBG_LEVEL,("no data to read, file=%s startpos=%ld, filesize=%ld", file, startpos, filesize));
        return 0;
	}
	
    fp = fopen(file, "r");                                                       
    if (fp == NULL) {                                                            
		TMDEBUG(_TSAMNW_DBG_LEVEL,("Can not open file %s: %s", file, strerror(errno)));
        return -1;                                                               
    }

	size_t rs = fread(buf, 1, readsize, fp);
	if (ferror(fp) != 0 ) {
		/* error occured */
		TMDEBUG(_TSAMNW_DBG_LEVEL,("fread(%s) failed %s", file, strerror(errno)));
        return -1;
	}
	TMDEBUG(_TSAMNW_DBG_LEVEL,("fread return %ld\n", rs));
	TMDEBUG(_TSAMNW_DBG_LEVEL,("fread return str: %s\n", buf));

	*(buf+rs+1) = 0x0;
	long i = rs;
	for(i=rs; i>=0; i--) {
		TMDEBUG(_TSAMNW_DBG_LEVEL,("i=%ld", i));
		if (*(buf+i) == '\n') {
			ret = i+1;	
			*(buf+i+1) = 0x0;
			break;
		}
	}

	TMDEBUG(_TSAMNW_DBG_LEVEL,("str length: %ld\n", strlen(buf)));
	fclose(fp);
    return ret;
}


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
	//int pos = find_oneline_in_txtfile(fn, strtofind);
	char buf[1024*4] = { '\0' };
	long offset = 0;
	long readlen = 100;
	long len = read_buf_from_txtfile(fn, offset, readlen, buf);
	printf("len: %d\n", len);
	printf("buf: %s", buf);
	exit(0); 
}
