#include <iostream>

int shift(int a[], int n, int i) {
  int tmp = a[0];
  int working = 0;
  int dst = 0;
  int tmp2 = 0;
  for(int m=0; m<n; m++) {
    //find pos
    dst= (working - i + n) % n;
    //swap(a, m, dst) ;
    tmp2=a[dst];
    a[dst]=tmp;
    //tmp=a[dst]
    tmp=tmp2;
    //a[m]=tmp
    working=dst;
  }
}

int main(int argc, char** argv) {
  int a[] = {1,2,3,4,5};
  shift(a, 5, 3);
  for(int i=0; i<sizeof(a)/sizeof(int); i++) {
    std::cout << a[i] << " ";
  }
}
