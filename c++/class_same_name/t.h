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
