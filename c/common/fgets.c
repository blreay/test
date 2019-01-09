
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
//#include <file.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
int main( int argc, char *argv[] )
{
	if ( argc == 0 ) {
		printf("usage: \n maplogread 50000.txt\n");
		return 0;
	}

	char *memory = NULL;
	int file_length = 0;
	char *start_address = 0;
	int line_num = 0;
	int offset = 0;
	int time_start = time(NULL);
	FILE *fp = fopen(argv[1], "r" );
	if ( fp > 0 ) { 
		char a;
		char str1[2048];
		struct stat sb;
		while(1) {
			scanf("%c", &a);
			line_num=0;
			if (stat(argv[1], &sb) == -1) {
				perror("stat");
				exit(-1);
			}

			file_length = sb.st_size;
			printf("file_length=%ld\n", file_length);
        	if (fgets(str1, 2048, fp) == NULL) {                               
				printf("file end\n");
			} else {
				printf("read buff:::%s", str1);
				printf("total costed time %d sec\n", time(NULL) - time_start);
			}
		}
	}
	return 0;
}

