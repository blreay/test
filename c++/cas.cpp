#include <thread>
#include <vector>
#include <iostream>
#include <atomic>
std::atomic<bool> lock(false); 
void f(int n) {
   for (int cnt = 0; cnt < 100; ++cnt) {
      while(std::atomic_exchange_explicit(&lock, true, std::memory_order_acquire))
         ; 
      std::cout << "Output from thread " << n << '\n';
      std::atomic_store_explicit(&lock, false, std::memory_order_release);
   }
}

int main1 () {
   std::vector<std::thread> v;
   for (int n = 0; n < 10; ++n) {
      v.emplace_back(f, n);
   }
   for (auto& t : v) {
      t.join();
   }
}

///////////////////////////////////////////////////////
std::atomic<int>  ai;
int  tst_val= 0;
int  new_val= 5;
bool exchanged= false;

void valsout()
{
    std::cout << "ai= " << ai
	      << "  tst_val= " << tst_val
	      << "  new_val= " << new_val
	      << "  exchanged= " << std::boolalpha << exchanged
	      << "\n";
}

int main()
{
    ai= 1;
    valsout();

    // tst_val != ai   ==>  tst_val is modified
    exchanged= ai.compare_exchange_strong( tst_val, new_val );
    valsout();

    // tst_val == ai   ==>  ai is modified
    exchanged= ai.compare_exchange_strong( tst_val, new_val );
    valsout();
}
