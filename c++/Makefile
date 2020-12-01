CC=g++
CXXFLAGS= --std=c++14 -fno-elide-constructors -DMY_TEST -g
CXXFLAGS= --std=c++14 -fno-elide-constructors -g -lpthread -Werror=format=
CXXFLAGS= --std=c++14 -fno-elide-constructors -g -lpthread

EXE=smartpointer \
	move \
	mutex \
	array \
	cond \
	list \
	rawstring \
	semaphore \
	testgdb \
	hex \
	exectime \
	weak_ptr \
	shared_ptr \
	unique_ptr \
	int \
	stream \
	core \
	func_overwrite \
	cas \
	time \
	thread \
	promiss \
	lambda \

all: ${EXE} 

clean:
	rm -f ${EXE} *.o
