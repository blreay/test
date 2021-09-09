
#include <iostream>
 
#include <mutex>
#include <condition_variable>
#include <thread>
#include <sstream>
#include <string>
#include <queue>
#include <list>
#include <stdio.h>
 
using namespace std;

class Test;
std::shared_ptr<Test> p;

class Test{
public:
    int a;
    int b;
    void call() {
			a=5;
			//cout << "this=" << this;
			cout << "set" << endl;
            //p.reset(this);
     }
};

	Test b;

#ifdef MY_TEST
#define LOG(fmt, args...) printf(fmt, ##args)
#else
#define LOG(fmt, args...)
#endif

int main()
{
	std::cout << "main" << std::endl;
	std::list<int> a;
	//std::vector<uint8_t> va={1,2,0,8,9};
	std::vector<uint8_t> va={33,33};
	//uint16_t b=5;
	uint8_t ta=33;
	cout << "ta=" << ta << endl;
	int vb=5;
	va.push_back('a');
	//va.push_back((uint8_t)33);
	va.push_back(33);

	std::stringstream ss;
	for(auto i: va){
		cout << "i=\"" << std::to_string(i) << "\"" << endl;
		printf("i=%d\n", i);
		ss << std::to_string(i) << "'" << i << "'" <<  ",";
	}
	cout<<"va="<<va.size() << "value=" << ss.str()<<endl;

	a.push_front(1);
	a.push_front(2);
	a.push_front(3);
	a.push_front(4);
	a.push_front(5);

	int nn=10;
	LOG("test log %d\n", nn);
	for(auto it=a.begin(); it !=a.end(); ++it) {
		if (*it == 5) {
			//it=a.insert(it, 8); //lead to dead lock
			a.insert(it, 8); //lead to dead lock
		}
		cout << *it << " ";
	}
	cout << endl;
	for(auto it=a.begin(); it !=a.end(); ++it) {
		cout << *it << " ";
	}
	cout << endl;
	b.call();
	//p.reset(&b);
	//p=std::make_shared<Test>();
//	p->call();
	//p.reset();
	if (nn==10);
	int nnn=atoi(getenv("A")==nullptr?"75":getenv("A"));
	cout << "nnn=" << nnn;
	//cout << "p=" << p->call();
    
}
