
#include <iostream>
 
#include <mutex>
#include <condition_variable>
#include <thread>
#include <queue>
#include <list>
 
using namespace std;

int main()
{
	std::cout << "main" << std::endl;
	std::list<int> a;

	a.push_front(1);
	a.push_front(2);
	a.push_front(3);
	a.push_front(4);
	a.push_front(5);

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
    
}
