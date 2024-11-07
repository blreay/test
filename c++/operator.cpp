#include <iostream>
#include <array>
#include <cstddef>  // 包含 std::byte 的头文件

// 假设 u256 是一个大整数类型
class u256 {
public:
    u256() : value(0) {}
    u256(unsigned long long v) : value(v) {}

    u256& operator=(unsigned long long v) {
        value = v;
        return *this;
    }

    u256 operator<<(unsigned int shift) const {
        return u256(value << shift);
    }

    u256 operator|(std::byte byte) const {
        return u256(value | static_cast<unsigned long long>(static_cast<unsigned char>(byte)));
    }

    friend std::ostream& operator<<(std::ostream& os, const u256& val) {
        os << val.value;
        return os;
    }

private:
    unsigned long long value;
};

const unsigned N = 4;

class MyClass {
public:
    MyClass(const std::array<std::byte, N>& data) : data_(data) {}

    operator u256() const {
        u256 ret = 0;
        for (unsigned i = 0; i < N; ++i) {
            ret = (u256)(ret << 8) | (std::byte)data_[i];
        }
        return ret;
    }

private:
    std::array<std::byte, N> data_;
};

int main() {
    std::array<std::byte, N> data = {std::byte{0x12}, std::byte{0x34}, std::byte{0x56}, std::byte{0x78}};
    MyClass obj(data);

    u256 result = obj;
    std::cout << "Result: " << result << std::endl;

    return 0;
}

