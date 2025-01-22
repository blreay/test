#### NOTE: -lxxx must put at the end of g++ command line, why???
## https://cloud.tencent.com/developer/ask/116993
##如果将-ludis86第一个选项在命令行中，连接器将有效地忽略你的库，因为在开始的时候不知道，这将需要ud_init，ud_set_input_file等等
#后来，在处理时example.o会发现这些符号，并将其添加到待处理的符号名单。但是这些符号到最后仍然没有解决，因为-ludis86它已经被处理。
##有时，当两个（或更多）库以循环方式彼此引用时，甚至可能需要-l在同一个库中使用两次选项，以使连接器有两次机会从该库中检索必要的对象文件。

CC=g++
CXXFLAGS= --std=c++14 -fno-elide-constructors -DMY_TEST -g
CXXFLAGS= --std=c++14 -fno-elide-constructors -g -Werror=format=
CXXFLAGS= --std=c++17 -fno-elide-constructors -g
LDFLAGS= -lpthread

#MYCXXFLAGS=-I$$HOME/tmp/jsoncpp_/include
#MYLDFLAGS=-L$$HOME/tmp/jsoncpp_/src/lib_json -ljsoncpp
#yum install jsoncpp && yum install jsoncpp-devel: need :: yum install epel-release

MYCXXFLAGS=-I/usr/include/jsoncpp
MYLDFLAGS=-L$$HOME/tmp/jsoncpp_/src/lib_json -ljsoncpp

#LIBS=jsoncpp

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
	promise \
	lambda \
	cond2 \
	call_private \
	quick_sort \
	lru \
	link_sort \
	link_sort2 \
	random_set \
	shiftarray \
  serial_stack \
  operator \
  ipaddress \

EXE_ADD=test_jsoncpp \

all: ${EXE} ${EXE_ADD}

$(EXE): %: %.o
	@echo Link $@
	$(CC) $(CXXFLAGS) $< -o $@ $(LDFLAGS)
$(EXE_ADD): %: %.cpp
	@echo Link $@
	$(CC) $(CXXFLAGS) $(MYCXXFLAGS) $< -o $@ $(LDFLAGS) $(MYLDFLAGS)

#folloing can work also, do compile and link together
$(EXE3): %: %.cpp
	@echo Link $@
	$(CC) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

## following can be deleted, make will do it automatically, this is just a sample
%.o: %.cpp
	@echo compile
	$(CC) -c $(CXXFLAGS) $< -o $@

## following work also
${EXE2}: $@.cpp
	echo build $@
	$(CC) $(CXXFLAGS) $(CGFLAG) $@.cpp -o $@ $(LDFLAGS)

clean:
	rm -f ${EXE} ${EXE_ADD} *.o
