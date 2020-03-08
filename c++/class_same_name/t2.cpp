#include "t.h"
#include "t2.h"

namespace {
class derive : public base {
public:
derive() {std::cout << "derive construct t2" << std::endl;}
// derive();
~derive() {std::cout << "derive destruct t2" << std::endl;}
// ~derive();
};

// derive::~derive() {std::cout << "derive destruct t2" << std::endl;}

/*
 *derive::derive() {
 * std::cout << "derive construct t2" << std::endl;
 *}
 */
}

void t2 () {
derive* d = new derive();
std::cout << sizeof(*d) << std::endl;
func(d);
}
