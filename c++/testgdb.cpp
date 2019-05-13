// This file is use to test gdb feature

// make sure /tmp/1 doesn't, begin command line
// gdb -x run_until_segfault.gdb ./testgdb
// after a while ,touch /tmp/1, the gdb will stop there
 
#include <mutex>
#include <vector>
#include <stdio.h>
#include <string.h>
#include <semaphore.h>
#include <condition_variable>
#define MY_USE_SEM_CONDVAR
 
namespace ilovers{
class MySemaphore {
#ifdef MY_USE_SEM_CONDVAR
private:
	int count_;
	int wakeups_;
	std::mutex semlk_;
	std::condition_variable semcond_;
public:
	MySemaphore(int value=1): count_{value}, wakeups_{0} {}
	int wait(){
		std::unique_lock<std::mutex> lock{semlk_};
		if (--count_ < 0) { // count is not enough ?
			semcond_.wait(lock, [&]()->bool{ return wakeups_ > 0;}); // suspend and wait ...
			--wakeups_;  // ok, me wakeup !
		}
		return 0;
	}
	int signal(){
		std::lock_guard<std::mutex> lock{semlk_};
		if(++count_ <= 0) { // have some thread suspended ?
			++wakeups_;
			semcond_.notify_one(); // notify one !
		}
		return 0;
	}
#else
private:
	sem_t sem_;
public:
	MySemaphore(int value=0) {
		sem_init(&sem_, 0, value);
	}
	int wait(){
		sem_wait(&sem_);
		return 0;
	}
	int signal(){
		sem_post(&sem_);
		return 0;
	}
#endif
};
};

#include <iostream>
#include <thread>
//#include "ilovers/semaphore"
 
std::mutex m;
ilovers::MySemaphore ba(0), cb(0), dc(0);
 
void a() {
    ba.wait();  // b --> a
    std::lock_guard<std::mutex> lock{m};
    std::cout << "thread a" << '\n';
}
void b() {
    cb.wait();  // c --> b
    std::lock_guard<std::mutex> lock{m};
    std::cout << "thread b" << '\n';
    ba.signal();  // b --> a
}
void c() {
    dc.wait();  // d --> c
    std::lock_guard<std::mutex> lock{m};
    std::cout << "thread c" << '\n';
    cb.signal();  // c --> b
}
void d() {
    std::lock_guard<std::mutex> lock{m};
    std::cout << "thread d" << '\n';
    dc.signal();  // d --> c
}
 
int main() { 
    std::thread th1{a}, th2{b}, th3{c}, th4{d}; 
	int a[100];
	std::vector<int> va(100);
    th1.join();
    th2.join();
    th3.join();
    th4.join(); 
    std::cout << "thread main" << std::endl; 
	uint32_t n;
	n=(1|2|4);
    std::cout << "n=" << n << std::endl; 
	if (n & 1) std::cout << "1" << std::endl; 
	if (n & 4) std::cout << "4" << std::endl; 
	if (n & 8) std::cout << "8" << std::endl; 
	char* p = nullptr;
	n=4;
	a[20]=999;
	va[20]=888;
	va[21]=111;
	char* pp=new(char);

	std::string msg=R"(
// make sure /tmp/1 doesn't exit, begin command line
// gdb -x run_until_segfault.gdb ./testgdb
// after a while ,touch /tmp/1, the gdb will stop there
)";
	std::cout << msg << std::endl;
	// make sure /tmp/1 doesn't exit, begin command line
	// gdb -x run_until_segfault.gdb ./testgdb
	// after a while ,touch /tmp/1, the gdb will stop there
	int ret=system("ls /tmp/1");
	if (ret == 0) strcpy(p, "aaa");
    return 0;
}
