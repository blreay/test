/*
C ECHO client example using sockets
*/
#include <stdio.h> //printf
#include <string.h>    //strlen
#include <sys/socket.h>    //socket
#include <netdb.h>
#include <errno.h>
#include <arpa/inet.h> //inet_addr

int main(int argc , char *argv[]) {
	int sock;
	struct sockaddr_in server;
	char message[1000] , server_reply[2048];

	/*
	int rexec(char **ahost, int inport, char *user,
	char *passwd, char *cmd, int *fd2p);

	*/
	int ret = 0;
	char hostname[1024]="bej301713.cn.oracle.com";
	int inport = htons(512);
	char* user = "artbatch";	
	//char* user = NULL;
	/* following is error usage: "" will be treated as username */
	//char* user = "";  

	char* passwd = "welcome1";
	//char* passwd = NULL;
	/* following is error usage: "" will be treated as password */
	//char* passwd = "";
	char* cmd = "cat /etc/passwd";
	int* fd2p = NULL;
	char ** p = &hostname;
	fprintf(stderr, "begin call rexec()\n");
	sock = rexec(&p, inport, user, passwd, cmd, fd2p);
	if (sock < 0 ) {
		fprintf(stderr, "rexec failed. Error(%d): %s\n", errno, strerror(errno));
		return 1;
	}

	fprintf(stderr, "==================================="); 
	fflush(stdout);
	//keep communicating with server
	while(1) {
		//Receive a reply from the server
		ret = recv(sock , server_reply , 2000 , 0);
		if( ret < 0) {
			fprintf(stderr, "recv failed");
			break;
		} else if (ret == 0) {
			fprintf(stderr, "finished");
			break;
		} else {
			if (fwrite(server_reply, 1, ret, stdout) <= 0) {
				perror("rexec failed. Error");
			}
			fflush(stdout);
		} 
	}
	fprintf(stderr, "==================================="); 
	fflush(stdout);

	close(sock);
	return 0;
}
