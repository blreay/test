#include <iostream>
#include <charconv>
#include <string>
#include <cstring>

// 演示了整数/浮点，to_chars/from_chars，进制，多种情况
// 需要devtoolset-11 or above

/*
   是的，GCC 7.3 不支持 std::from_chars。

详细说明： std::from_chars 是 C++17 标准中 <charconv> 头文件的一部分，用于将字符串转换为数字（如 int, float, uint64_t 等），其特点是：

高性能（零拷贝、无异常、无依赖 locale） 无副作用 支持自定义进制
但 GCC 的 libstdc++ 标准库直到 GCC 8.1 才开始实验性支持 <charconv>，而 GCC 7.3 完全不包含这个功能。

GCC 版本与 <charconv> 支持情况：

GCC 版本	<charconv> 支持	std::from_chars 可用？
≤ 7.5	     不支持	 不可用
8.1 ~ 8.5	 实验性支持	 可用（需启用 -std=c++17）
≥ 9.1	     完整支持	 可用
*/

int main() {
    // ========= 整数字符串 -> int ===========
    const char* str = "12345";
    int value = 0;
    auto [ptr, ec] = std::from_chars(str, str+5, value);
    if (ec == std::errc()) {
        std::cout << "Parsed int: " << value << std::endl;
    } else {
        std::cout << "Parsing error!\n";
    }

    // 支持16进制
    const char* hex = "ff";
    int hvalue = 0;
    auto [eptr, hec] = std::from_chars(hex, hex+2, hvalue, 16);
    if(hec == std::errc())
        std::cout << "Parsed hex: " << hvalue << std::endl;

    // ========= int -> 字符串 ===========
    char buf[32];
    int number = 54321;
    auto [ptr2, ec2] = std::to_chars(buf, buf+sizeof(buf), number);
    if(ec2 == std::errc()) {
        std::cout << "int to string: " << std::string(buf, ptr2) << std::endl;
    }

    //16进制输出
    char buf2[32];
    std::to_chars(buf2, buf2+sizeof(buf2), 255, 16);
    std::cout << "255 in hex: " << std::string(buf2) << std::endl;

    // ========= float 双向 ===========
    const char* fstr = "2.71828";
    float fval;
    auto [fptr, fec] = std::from_chars(fstr, fstr+strlen(fstr), fval);
    if(fec == std::errc()) {
        std::cout << "Parsed float: " << fval << std::endl;
    }

    char fbuf[32];
    float pi = 3.14159f;
    auto [fptr2, f2ec] = std::to_chars(fbuf, fbuf+sizeof(fbuf), pi);
    if(f2ec == std::errc()) {
        std::cout << "float to string: " << std::string(fbuf, fptr2) << std::endl;
    }

    // ========= double =========
    const char* dstr = "6.28318";
    double dval;
    auto [dptr, dec] = std::from_chars(dstr, dstr+strlen(dstr), dval);
    if(dec == std::errc()) {
        std::cout << "Parsed double: " << dval << std::endl;
    }

    char dbuf[32];
    double val = 1.23456;
    auto [dptr2, d2ec] = std::to_chars(dbuf, dbuf+sizeof(dbuf), val);
    if(d2ec == std::errc()) {
        std::cout << "double to string: " << std::string(dbuf, dptr2) << std::endl;
    }

    // ========= 错误检测 =========
    const char* bad = "hello";
    int badint;
    auto [bptr, bec] = std::from_chars(bad, bad+5, badint);
    if (bec != std::errc()) {
        std::cout << "Correctly failed to parse 'hello'!" << std::endl;
    }

    return 0;
}

