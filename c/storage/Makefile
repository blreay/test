#---------------------------------------------------------------------
#		Machines Architecture :
#---------------------------------------------------------------------
UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	# do something Linux-y
	CC=gcc
endif
ifeq ($(UNAME), SunOS)
# do something Solaris-y
	CC=gcc
endif
ifeq ($(UNAME), AIX)
# do something Solaris-y
	LDFLAG=-lbsd
endif

CC   =  gcc
#CC   = xlc
CCLINKER   =  $(CC)
CGFLAG= -g
CFLAGS= -g  -std=c99
TARGET=set_thread_stack_size \
	test1 \
	pthread \
	fileclear \
	time \
	strtol \
	microsecond \
	thread_exit_handler \
	thread_exit_handler_detatch \
	filelock \
	lockf \
	flock \
	log \
	clock_gettime \
	mmap \
	fgets \
	snprintf \
	findstr \
	readtxt \
	findbig \
	stdin \
	getpid \
	execlp \
	setuid \
	mysudo \
	block \
	

#OPTFLAGS    =  -xO3
#----------------------------------------------------------------------

EXECS       =  run

all: $(TARGET)

set_thread_stack_size: set_thread_stack_size.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread

thread_exit_handler: thread_exit_handler.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
thread_exit_handler_detatch: thread_exit_handler_detatch.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread

test1: test1.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
log: log.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
microsecond: microsecond.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
fileclear: fileclear.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
filelock: filelock.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread

pthread: pthread.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread

time: time.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread

clock_gettime: clock_gettime.o
	#$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread -L/usr/lib64 -Wl,-Bstatic -lrt
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread -lrt

strtol: strtol.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
mmap: mmap.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
fgets: fgets.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread

findstr: findstr.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
readtxt: readtxt.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
findbig: findbig.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread -lstdc++
stdin: stdin.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
execlp: execlp.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread
flock: flock.o
	$(CCLINKER) $(CGFLAG) $(LDFLAG) -o $@ $< -lm -lpthread
.c.o:
	$(CC) $(OPTFLAGS) $(CGFLAG) -c $< -lpthread -lbsd

clean:
	rm -rf *.o run $(TARGET) core.*

run: clean all
	./set_thread_stack_size

runjcl: stdin
	./runjcl.sh

