#include <stdio.h>
#include <string.h>
#include <iostream>
#include <thread>

// this cpp test how to call private function outside the class

using namespace std;
 
template<typename Tag>
struct result {
  typedef typename Tag::type type;
  static type ptr;
};

template<typename Tag>
typename result<Tag>::type result<Tag>::ptr;

template<typename Tag, typename Tag::type p>
struct rob : result<Tag> {
  struct filler {
    filler() { result<Tag>::ptr = p; }
  };
  static filler filler_obj;
};

template<typename Tag, typename Tag::type p>
typename rob<Tag, p>::filler rob<Tag, p>::filler_obj;

// a sample class
struct A {
private:
  void f() {
    std::cout << "proof!" << std::endl;
  }
};

struct Af { typedef void(A::*type)(); };
template class rob<Af, &A::f>;
 
int main() { 
   A a;
  (a.*result<Af>::ptr)();
    return 0;
}
