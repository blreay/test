#---------------------------------------------------------------------
#		Machines Architecture :
#---------------------------------------------------------------------
CC   =  gcc
GCC   =  g++
#CC   = xlc
CCLINKER   =  $(CC)
GCCLINKER   =  $(GCC)
TARGET= insert \

#OPTFLAGS    =  -xO3
OPTFLAGS    =  -g
#----------------------------------------------------------------------
CFLAGS=-L$(BDB_HOME)/lib -I $(BDB_HOME)/include

EXECS       =  run

all: $(TARGET)

.c.o:
	$(CC) $(OPTFLAGS) $(CFLAGS) -c $< 
.cpp.o:
	$(GCC) $(OPTFLAGS) $(CFLAGS) -c $< 

insert: insert.o
	$(CCLINKER) $(CFLAGS) -o $@ $< -lm -lpthread  -ldb_sql

clean:
	/bin/rm -rf *.o $(TARGET) test.db*

run: clean all
	./fork
