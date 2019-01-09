#---------------------------------------------------------------------
#		Machines Architecture :
#---------------------------------------------------------------------
CC   =  gcc
GCC   =  g++
#CC   = xlc
CCLINKER   =  $(CC)
GCCLINKER   =  $(GCC)
TARGET=fork\
		fork2 \
		signal \
#OPTFLAGS    =  -xO3
OPTFLAGS    =  -g
#----------------------------------------------------------------------

EXECS       =  run

all: $(TARGET)

.c.o:
	$(CC) $(OPTFLAGS) $(CGFLAG) -c $< 
.cpp.o:
	$(GCC) $(OPTFLAGS) $(CGFLAG) -c $< 

fork: fork.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread 
fork2: fork2.o
	$(CCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread 
signal: signal.o
	$(GCCLINKER) $(CGFLAG) -o $@ $< -lm -lpthread 

clean:
	rm -rf *.o run $(TARGET)

run: clean all
	./fork
