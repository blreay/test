#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

/*
[chenndao@localhost log]$ ./maplogread 3000000.txt
Finished, total lines is 3000000 
total costed time 0 sec
[chenndao@localhost log]$ ./maplogread 3000000.txt
Finished, total lines is 3000000 
total costed time 1 secs
*/

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
	int fd = open( argv[1], O_RDONLY );
	if ( fd > 0 ) { 
		char a;
		struct stat sb;
		while(1) {
			scanf("%c", &a);
			line_num=0;
			if (stat(argv[1], &sb) == -1) {
				perror("stat");
				exit(-1);
			}

			//file_length = lseek(fd, 1, SEEK_END);
			file_length = sb.st_size;
			printf("file_length=%ld\n", file_length);
			if (offset == file_length){
				printf("no change, do nothing \n");	
				continue;
			}
			file_length=1024*1024*1024*1;
			int fd = open( argv[1], O_RDONLY );
			memory = mmap( start_address, file_length-offset, PROT_READ, MAP_SHARED, fd, offset+offset % 512 );
			if (-1 == memory) {
				//printf("mmap error, ERRNO=%ld, msg=%s", errno, strerror(errno));
				printf("mmap error %d offset=%d fd=%d\n", errno, offset, fd);
				exit(-1);
			}
			int i=0;
			for ( ; i<file_length-offset; i++ ) {
				printf("%c", memory[i]);
				if ( memory[i] == '\n' ) {
					++line_num;
				}
			}
			munmap( memory, file_length );
			offset+=file_length;
			printf("Finished, total lines is %d i=%d\n", line_num, i);
			printf("total costed time %d sec\n", time(NULL) - time_start);
		}
			close( fd );
	}
	return 0;
}

