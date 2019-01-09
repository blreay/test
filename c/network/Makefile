# compiler
CC=gcc
CFLAGS=-Wall -g -DDEBUG -lpthread

# solaris
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
ifeq ($(uname_S),SunOS)
	CC=cc
	CFLAGS=-lnsl -lsocket -lresolv -D_PLATFORM_SOLARIS
endif
ifeq ($(uname_S),AIX)
	CC=xlc
	CFLAGS=-lnsl -D_PLATFORM_AIX -lpthread
endif

# targets
DEPS=siftp.o service.o
TARGETS=siftp siftpd sirexec socket_client socket_server socket_simplesvr tcpsvr

all: $(TARGETS)

siftpd: $(DEPS) server.o
	$(CC) $(CFLAGS) -o $@ $^

siftp: $(DEPS) client.o
	$(CC) $(CFLAGS) -o $@ $^

sirexec: $(DEPS) sirexec.o
	$(CC) $(CFLAGS) -o $@ $^

socket_client: $(DEPS) socket_client.o
	$(CC) $(CFLAGS) -o $@ $^
socket_server: $(DEPS) socket_server.o
	$(CC) $(CFLAGS) -o $@ $^
socket_simplesvr: $(DEPS) socket_simplesvr.o
	$(CC) $(CFLAGS) -o $@ $^
tcpsvr: $(DEPS) tcpsvr.o
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f *.o $(TARGETS) core.*

