#include "t.h"
#include "t1.h"

namespace {
class derive : public base {
public:
derive() {std::cout << "derive construct t1" << std::endl;}
// derive();
derive(int _i ):i(_i) {std::cout << "derive construct t1" << std::endl;}
~derive() {std::cout << "derive destruct t1" << std::endl;}
// ~derive();
int i;
};

//derive::~derive() {std::cout << "derive destruct t1" << std::endl;}

/*
 *derive::derive() {
 * std::cout << "derive construct t1" << std::endl;
 *}
 */
}

void t1 () {
derive* d = new derive(3);
std::cout << sizeof(*d) << "  d->i " << d->i << std::endl;
func(d);
}
