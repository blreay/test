#---------------------------------------------------------------------
#		Machines Architecture :
#---------------------------------------------------------------------
CC   =  gcc
GCC   =  g++
#CC   = xlc
CCLINKER   =  $(CC)
GCCLINKER   =  $(GCC)
TARGET=artperl

#OPTFLAGS    =  -xO3
OPTFLAGS    =  -g
#----------------------------------------------------------------------

EXECS       =  run

all: $(TARGET)

.c.o:
	$(CC) $(OPTFLAGS) $(CGFLAG) -c $< 
.cpp.o:
	$(GCC) $(OPTFLAGS) $(CGFLAG) -c $< 
artperl: artperl.o idea.o

clean:
	rm -rf *.o run $(TARGET)

run: clean all
	./fork
