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
CGFLAG= -g -I/usr/include/libxml2 -lxml2
CFLAGS= -g
TARGET=readxml \
		xpath \
		xpath2 \
	

#OPTFLAGS    =  -xO3
#----------------------------------------------------------------------

EXECS       =  run

all: $(TARGET)
readxml: readxml.o
	$(CCLINKER) $(CGFLAG) $(LDFLAG) -o $@ $< -lm -lpthread
xpath: xpath.o
	$(CCLINKER) $(CGFLAG) $(LDFLAG) -o $@ $< -lm -lpthread
xpath2: xpath2.o
	$(CCLINKER) $(CGFLAG) $(LDFLAG) -o $@ $< -lm -lpthread

.c.o:
	$(CC) $(OPTFLAGS) $(CGFLAG) -c $< -lpthread -lbsd

clean:
	rm -rf *.o run $(TARGET) core.*

run: clean all
	echo "##########################"
	./xpath2 infile2.xml "//jsdljcl:dataset" "xsi=http://www.w3.org/2001/XMLSchema-instance jmgr=http://www.ibm.com/xmlns/prod/scheduling/1.0/JobManager jsdl=http://www.ibm.com/xmlns/prod/scheduling/1.0/jsdl jsdljcl=http://www.ibm.com/xmlns/prod/scheduling/1.0/jsdljcl"
	echo "##########################"
	./xpath2 infile3.xml "//jsdljcl:jclDefinition" "xsi=http://www.w3.org/2001/XMLSchema-instance jmgr=http://www.ibm.com/xmlns/prod/scheduling/1.0/JobManager jsdl=http://www.ibm.com/xmlns/prod/scheduling/1.0/jsdl jsdljcl=http://www.ibm.com/xmlns/prod/scheduling/1.0/jsdljcl"
	echo "##########################"
	./xpath2 infile.xml "//jsdlxa:taskString" "xsi=http://www.w3.org/2001/XMLSchema-instance jmgr=http://www.ibm.com/xmlns/prod/scheduling/1.0/JobManager jsdl=http://www.ibm.com/xmlns/prod/scheduling/1.0/jsdl jsdljcl=http://www.ibm.com/xmlns/prod/scheduling/1.0/jsdljcl jsdlxa=http://www.ibm.com/xmlns/prod/scheduling/1.0/jsdlxa"
