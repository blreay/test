#include <iostream>       // std::cout
#include <memory>       // std::cout
#include <vector>       // std::cout
#include <thread>         // std::thread
#include <mutex>          // std::mutex

using namespace std;
volatile int counter(0); // non-atomic counter
std::mutex mtx;           // locks access to counter
std::mutex outmtx;           // locks access to counter

void test_raii() {
    for (int i=0; i<1000; ++i) {
		std::lock_guard<std::mutex> lck(mtx);
		++counter;
		cout << this_thread::get_id() << ":" << counter << endl;
    }
}
void my10k_increases() {
    for (int i=0; i<10000; ++i) {
		mtx.lock();
		++counter;
		mtx.unlock();
    }
}
void attempt_10k_increases() {
    for (int i=0; i<10000; ++i) {
        if (mtx.try_lock()) {   // only increase if currently not locked:
            ++counter;
            mtx.unlock();
        } else {
			outmtx.lock();
			cout << "X(" << this_thread::get_id() << ") " << endl;
			outmtx.unlock();
			mtx.lock();
            ++counter;
            mtx.unlock();
		}
    }
}

int main (int argc, const char* argv[]) {
	//mtx = new std::mutex;
	std::mutex* p;
	std::vector<std::mutex*> vec;
	long max=10;
	std::mutex** ma=new std::mutex*[max];
	for (int i=0; i<max; i++) {
		cout << i << endl;
		//vec[i]=new std::mutex();
		//p=new std::mutex();
		ma[i]=new std::mutex();
	}
	cout << "create mutex vector OK" << endl;
    std::thread threads[10];
    for (int i=0; i<10; ++i) {
		//auto f=attempt_10k_increases;
		auto f=test_raii;
        //threads[i] = std::thread(f);
        threads[i] = std::thread(f);
	}

    for (auto& th : threads) th.join();
    std::cout << counter << " successful increases of the counter.\n";

    return 0;
}
