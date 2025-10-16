#include <iostream>
#include <cstdint>

int main() {
    // GCC和Clang支持__uint128_t扩展
    __uint128_t big_num = 1;
    
    // 进行128位运算
    big_num = big_num << 64;  // 2^64
    big_num += 0xFFFFFFFFFFFFFFFF;  // 2^64 - 1
    
    std::cout << "128位数值: " << (uint64_t)(big_num >> 64) << " " 
              << (uint64_t)big_num << std::endl;
    
    return 0;
}
