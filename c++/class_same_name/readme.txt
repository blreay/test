https://mp.csdn.net/console/editor/html/104743078

C++同名class引发的coredump SIGBUS 问题总结


军规！！！
在同一工程里，绝对不要拷贝class的代码，并且类名保持不变，不同模块也不行，不同目录也不行，总之绝对不要出现同名的类。可灵活使用namespace来进行隔离。



问题点
模块A的代码通过了UT，以及功能测试等所有测试之后，发起PR将代码合入master的时候，碰到了CI始终不能成功的问题。深入分析以后发现是进程crash了，发生了SIGBUS。以下记录了调试的过程。



调试过程
由于本次确实修改了出错地方的代码，所以仔细review了代码，发现修改的代码不太可能有问题，只是追加了一个成员指针变量，然后在析构的时候，如果该指针不是空，就调用delete. 且通过了模块A的所有测试。该执行路径在所有的case里都会覆盖到。

由于发生的是SIGBUS，比较奇怪，如果是内存使用有问题，发生SIGSEGV的可能性比较大。所以又分析了对应的会汇编代码，发现是crash在cmpb指令里,该指令是一个非常普通且常用的指令，参数打印了一下也没有问题，这里只是判断一个成员变量是否为0.

又重新开始思考为什么是SIGBUS,  SIGBUS和SIGSEGV究竟是什么区别。并查了一些资料，总结如下;



一 什么情况会导致SIGSEGV 

 试图对仅仅读映射区域进行写操作 。
 訪问的内存已经被释放，也就是已经不存在或者越界。
官方说法是：
SIGSEGV --- Segment Fault. The possible cases of your encountering this error are: 
（1）buffer overflow --- usually caused by a pointer reference out of range.
（2）stack overflow --- please keep in mind that the default stack size is 8192K.
（3）illegal file access --- file operations are forbidden on our judge system.



二、什么情况会导致SIGBUS:    

硬件故障。不用说，可能性甚微。 
Linux平台上运行malloc()，假设没有足够的RAM。Linux不是让malloc()失败返回。 而是向当前进程分发SIGBUS信号。（可能行为已发生变化，不是很确定）
某些架构上訪问数据时有对齐的要求，比方仅仅能从4字节边界上读取一个4字节的 数据类型。IA-32架构没有硬性要求对齐，虽然未对齐的訪问减少运行效率。另外一些架构，比方SPARC、m68k，要求对齐訪问，否则向当前进程分发SIGBUS信号。 
试图訪问一块无文件内容相应的内存区域，比方超过文件尾的内存区域，或者以前有文件内容相应，如今为还有一进程截断过的内存区域。


三、SIGBUS与SIGSEGV信号一样。能够正常捕获。

SIGBUS的缺省行为是终止当前进程并产生core dump。 



四、SIGBUS与SIGSEGV信号的一般差别例如以下: 

    1.SIGBUS(Bus error)意味着指针所相应的地址是有效地址，但总线不能正常使用该指针。一般是未对齐的数据訪问所致。 

    2.SIGSEGV(Segment fault)意味着指针所相应的地址是无效地址。没有物理内存相应该地址。 





从上述区别来看，如果是无效地址，则SIGSEGV。如果地址有效，但是总线不能使用该地址，则SIGBUG。

排除了硬件故障，内存不足等几个不可能的情况，只剩下：地址有效，但是不能访问。



由于出错的是新改动的一个类，开始怀疑this指针被踩坏了。使用ASAN跑了几次，还是发生这个错误，但是ASAN并没有探测到任何内存越界之类的错误。



然后又开始怀疑是对象被释放后又使用了，虽然这个非常牵强（如果真的是这个原因，现象应该不是这样，而且ASAN会探测到）。不过还是加了log, 把模块A内部，所有用new创建的此类的对象以及释放掉的对象的地址都打印出来，比对了一下，这一比对不当紧，发现了一个非常奇怪的现象：

当前访问的this指针，根本没有被模块A创建过。



万分诧异！！ 难道是别的模块创建的？怀着试试看的心态，简单grep了一下整个工程的代码，赫然发现，在另外一个模块B，居然有一个同名的类， 打开看了一下代码，跟模块A修改之前的一模一样。

至此，基本上找到root cause了.

root cause
模块A修改class1的代码之前，模块B拷贝了一份class1类的实现到自己的代码里，类名字也没有修改。编译和运行都没有问题，因为虽然有同名类，但是两个类的实现一模一样，new出来的对象的内存布局也完全一样。

但是当模块A修改了class1的实现，增加了一个成员变量之后，情况就变化了。两个同名类的内存布局不一样了。那个模块在程序运行时，使用了其拷贝过来的,老的类声明创建了对象（老的内存格局），但是在执行析构函数的时候，却调用到了模块A修改过的，新的析构函数，这个新的析构函数要访问那个新加的成员指针。由于老的内存布局里没有这个新的指针，所以该地址不能被总线正确访问，触发了SIGBUS。



这也可以解释为什么同样的代码，在模块A的UT以及功能测试时，都没有发生问题。一旦和别的模块集成之后，就发生问题了。



修复方案也很明显： 把该类修改为公共类，所有模块共用。



进一步思考
编译器会如何处理代码里的同名类呢？

为什么编译和连接的时候可以通过？

同名类，代码实现不同的情况下，进程运行时到底是怎么调用类的成员函数的？



一位大拿给出了一些资料和说明：

https://github.com/cplusplus/draft/blob/master/papers/n4296.pdf  （p38）









情况很复杂，讲解的也比较全面。但是其实只要记住一条就万事大吉： 不要拷贝且出现同名的类，否则天坑必现。



但是还是想知道运行期，到底发生了什么事，所以做了一些实验，基本结论如下。

存在同名类的情况下，所有成员函数都需要是inline的，或者最少一个类的所有成员函数都是inline的，否则gcc会编译失败，提示符号冲突。写在类声明里的函数，会自动转化成inline. 本次发生问题的类刚好都是inline的。
全部都是inline的情况下，如果执行非虚函数，那么会执行本单元内的那个类的实现。这个很容易理解，因为是inline函数，所以编译期间就全部替换成相应的指令了，执行期间其实根本没有函数执行的过程。
全部都是inline的情况下，如果执行虚函数（比如析构函数），执行哪个类里定义的，取决于编译时传给g++的源代码的顺序，哪个类的文件在前面，就会调用哪个类的析构函数。推断是因为：虚函数的执行依赖于运行期的虚函数表，编译器在前面的编译单元内，已经找到了一个对应的函数的地址，那么就忽略了之后的源码文件里的同名符号。


下面是做试验的代码以及运行结果。运行test.sh就可以看到效果。

======== main.cpp =================================================================
#include "t1.h"
#include "t2.h"
#include <iostream>

int main() {
std::cout << "call t1()" << std::endl;
t1();
std::cout << "call t2()" << std::endl;
t2();
return 0;
}

======== t.cpp =================================================================
#include "t.h"
void func(base* b) {delete b;}

======== t.h =================================================================
#ifndef T_H
#define T_H

#include <iostream>

class base {
public:
base() {std::cout << "base construct!" << std::endl;}
virtual ~base() {std::cout <<"base desctuct!" << std::endl;}
};

void func(base* b); 
#endif

======== t1.cpp =================================================================
#include "t.h"
#include "t1.h"

class derive : public base {
public:
derive() {std::cout << "derive construct t1" << std::endl;}
derive(int _i ):i(_i) {std::cout << "derive construct t1" << std::endl;}
~derive() {std::cout << "derive destruct t1" << std::endl;}
int i;
};

void t1 () {
derive* d = new derive(3);
std::cout << sizeof(*d) << "  d->i " << d->i << std::endl;
func(d);
}

======== t1.h =================================================================
#ifndef T1_H
#define T1_H
#include "t.h"
#include <iostream>

void t1();

#endif

======== t2.cpp =================================================================
#include "t.h"
#include "t2.h"

class derive : public base {
public:
derive() {std::cout << "derive construct t2" << std::endl;}
~derive() {std::cout << "derive destruct t2" << std::endl;}
};

void t2 () {
derive* d = new derive();
std::cout << sizeof(*d) << std::endl;
func(d);
}

======== t2.h =================================================================
#ifndef T2_h
#define T2_h
#include <iostream>

void t2();

#endif

======== test.sh =================================================================
#!/bin/bash

echo "============= order: t1.cpp t2.cpp ========"
g++ main.cpp t.cpp t1.cpp t2.cpp -o inline12
./inline12

echo "============= order: t2.cpp t1.cpp ========"
g++ main.cpp t.cpp t2.cpp t1.cpp -o inline21
./inline21

运行test.sh, 结果如下：


