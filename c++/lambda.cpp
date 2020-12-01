#include <iostream>
#include <vector>
#include <numeric>
#include <string>
#include <functional>
#include <thread>
#include <future>
#include <chrono>
using namespace std;
void example1()
{
    auto add = [](int x, int y)
    {
        return x + y;
    };
    int x = 2, y = 3;
    int z1 = add(x, y);                  // 调用Lambda
    int(*f)(int, int) = add;             // Lambda转换成函数指针
    int z2 = f(x, y);                    // 调用函数
    cout << z1 << ", " << z2 << endl;
}

int main() {
  example1();
  return 0;
}
