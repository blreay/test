CC=g++
CXXFLAGS= --std=c++14 -fno-elide-constructors -DMY_TEST -g
CXXFLAGS= --std=c++14 -fno-elide-constructors -g -lpthread

EXE=smartpointer \
	move \
	mutex \
	cond \
	list \
	rawstring \
	semaphore \

all: ${EXE} 

clean:
	rm -f ${EXE} *.o
