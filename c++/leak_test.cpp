#include <iostream>
#include <vector>
#include <chrono>
#include <thread>

/*
sudo yum install -y google-perftools libgoogle-perftools-dev
sudo yum install -y gperftools gperftools-libs
export CPUPROFILE=/tmp/cpu.prof                  # CPU 分析输出路径
export HEAPCHECK=normal
export HEAPPROFILE=$PWD/heap
export HEAP_PROFILE_INUSE_INTERVAL=1
export PPROF_PATH=/usr/local/bin/pprof
g++ -g -O0 -Wl,-rpath,/usr/local/lib -ltcmalloc_and_profiler leak_test.cpp -o leak_test
/bin/rm -rf heap.00*
./leak_test
pprof --pdf --base=./heap.0001.heap  ./leak_test heap.0078.heap  --nodecount=10000 --nodefraction=0.001 --edgefraction=0.001 > heap.pdf


   */

class LeakClass {
public:
    LeakClass() {
        ptr = new int[1024]; // 分配内存，但未释放
    }

    ~LeakClass() {
        // 故意不 delete[] ptr，制造内存泄漏
        // delete[] ptr;
    }

    void doSomething() {
        std::cout << "Doing something...\n";
    }

private:
    int* ptr;
};

void leakFunction() {
    int* data = new int[10000]; // 未释放
    std::cout << "Memory allocated in leakFunction.\n";
}

int main() {
    // 漏掉的单个 new
    for(int nn=0; nn<10; nn++)  {
    int* single = new int(420);

    // 多次分配，模拟累积泄漏
    std::vector<int*> vec;
    for (int i = 0; i < 10; ++i) {
        vec.push_back(new int(i));
    }
    leakFunction();

    // 创建对象，构造函数内分配内存
    LeakClass obj;
    obj.doSomething();
    std::this_thread::sleep_for(std::chrono::seconds(1));
}

    return 0;
}

