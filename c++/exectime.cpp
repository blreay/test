#include <iostream>

typedef unsigned long long myu64;
#define MY_DECLARE_ARGS(val, low, high)    unsigned low, high
#define MY_EAX_EDX_RET(val, low, high)     "=a" (low), "=d" (high)
#define MY_EAX_EDX_VAL(val, low, high)     ((low) | ((myu64)(high) << 32))
class ExecTime {
public:
    std::string m_msg;
    unsigned long long begin_time;
    unsigned long long end_time;
        ExecTime(std::string msg) {
                m_msg=msg;
                begin_time= __native_read_tsc();
        };
        ~ExecTime() {
                end_time= __native_read_tsc();
                std::cout << "## EXEC TIME(ms) ## " << m_msg << ":  " << (end_time - begin_time)/26/100000.0 << std::endl;
        };
        static inline unsigned long long __native_read_tsc(void) {
                 MY_DECLARE_ARGS(val, low, high);
                 asm volatile("rdtsc" : MY_EAX_EDX_RET(val, low, high));
                 return MY_EAX_EDX_VAL(val, low, high);
        }
};

int main () {
    ExecTime t("main run time");
}
