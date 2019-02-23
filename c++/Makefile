CC=g++
CXXFLAGS= --std=c++14 -fno-elide-constructors -DMY_TEST -g
CXXFLAGS= --std=c++14 -fno-elide-constructors -g -lpthread

EXE=smartpointer \
	teststorage \
	move \
	mutex \
	cond \
	list \

all: ${EXE} 

clean:
	rm -f ${EXE} *.o
