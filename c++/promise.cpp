#include <iostream>
#include <vector>
#include <numeric>
#include <string>
#include <functional>
#include <thread>
#include <chrono>
#include <future>
#include <exception>
#include <stdexcept>
#include <utility>
 
int main_accumulate()
{
    std::vector<int> v{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}; 
    int sum = std::accumulate(v.begin(), v.end(), 0); 
    int product = std::accumulate(v.begin(), v.end(), 1, std::multiplies<int>()); 
    auto dash_fold = [](std::string a, int b) {
                         return std::move(a) + '-' + std::to_string(b);
                     }; 
    std::string s = std::accumulate(std::next(v.begin()), v.end(),
                                    std::to_string(v[0]), // start with first element
                                    dash_fold);
 
    // Right fold using reverse iterators
    std::string rs = std::accumulate(std::next(v.rbegin()), v.rend(),
                                     std::to_string(v.back()), // start with last element
                                     dash_fold);
 
    std::cout << "sum: " << sum << '\n'
              << "product: " << product << '\n'
              << "dash-separated string: " << s << '\n'
              << "dash-separated string (right-folded): " << rs << '\n';
}

void accumulate(std::vector<int>::iterator first,
                std::vector<int>::iterator last,
                std::promise<int> accumulate_promise)
{
    int sum = std::accumulate(first, last, 0);
    accumulate_promise.set_value(sum);  // Notify future
}

void do_work(std::promise<void> barrier) {
    std::this_thread::sleep_for(std::chrono::seconds(1));
    barrier.set_value();
}
int main_promiss() {
    // Demonstrate using promise<int> to transmit a result between threads.
    std::vector<int> numbers = { 1, 2, 3, 4, 5, 6 };
    std::promise<int> accumulate_promise;
    std::future<int> accumulate_future = accumulate_promise.get_future();
    std::thread work_thread(accumulate, numbers.begin(), numbers.end(),
                            std::move(accumulate_promise));

    // future::get() will wait until the future has a valid result and retrieves it.
    // Calling wait() before get() is not needed
    //accumulate_future.wait();  // wait for result
    std::cout << "result=" << accumulate_future.get() << '\n';
    work_thread.join();  // wait for thread completion

    // Demonstrate using promise<void> to signal state between threads.
    std::promise<void> barrier;
    std::future<void> barrier_future = barrier.get_future();
    std::thread new_work_thread(do_work, std::move(barrier));
    barrier_future.wait();
    new_work_thread.join();
}

void doThings(std::promise<std::string>& p){
    //read a char
    try{
        std::cout << "read a char : ";
        char c = std::cin.get();
        //if 'x' throw runtime_error
        if (c == 'x'){
            throw std::runtime_error(std::string(" char ") + c +" read");
        }
        std::string s= std::string(" char ") + c +" processed";
        std::this_thread::sleep_for(std::chrono::milliseconds(1000*3));
        p.set_value(std::move(s));
    }catch(...){
        p.set_exception(std::current_exception()); //some exception
    }
}
int main_test2(int argc,char *argv[]) {
    try {
        std::promise<std::string> p;
        std::thread t(doThings,std::ref(p));
        t.detach();
        //get future
        std::future<std::string> fs = p.get_future();
        std::cout << "result is : " <<fs.get() <<std::endl;
        std::cout << "result is : " <<fs.get() <<std::endl; // lead to exception
    }
    catch (std::exception const& e){
        std::cerr << "Exception : " <<e.what() << std::endl;
    }
    catch(...){
        std::cerr << "Exception " << std::endl;
    }
    return 0;
}
// https://en.cppreference.com/w/cpp/thread/promise
int main() {
    // verify std::promiss
    main_promiss();
    // verify std::accumulate
    main_accumulate();

    main_test2(0, nullptr);
}
