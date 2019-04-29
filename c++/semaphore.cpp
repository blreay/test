/*
* author: http://p9as.blogspot.com/2012/06/c11-semaphores.html
* modified by: ilovers
*/
 
#include <mutex>
#include <condition_variable>
 
namespace ilovers{
    class MySemaphore {
    private:
        int count_;
        int wakeups_;
        std::mutex semlk_;
        std::condition_variable semcond_;
    public:
        MySemaphore(int value=1): count_{value}, wakeups_{0} {} 
        void wait(){
            std::unique_lock<std::mutex> lock{semlk_};
            if (--count_ < 0) { // count is not enough ?
                semcond_.wait(lock, [&]()->bool{ return wakeups_ > 0;}); // suspend and wait ...
                --wakeups_;  // ok, me wakeup !
            }
        }
        void signal(){
            std::lock_guard<std::mutex> lock{semlk_};
            if(++count_ <= 0) { // have some thread suspended ?
                ++wakeups_;
                semcond_.notify_one(); // notify one !
            }
        } 
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
    return 0;
}
