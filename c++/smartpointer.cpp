#include <iostream>
#include <memory> 
using namespace std; 
class Base {
	friend ostream& operator << (ostream& o, Base& in); 
	public: 	std::string m_str;
		shared_ptr<Base> m_p1;
		Base(std::string in) {
			m_str=in;
		} 
		~Base() {
			cout << "in ~Base()" << this << endl;
		} 
}; 
ostream& operator << (ostream& o, Base& in) {
	cout << "zzy01" << endl;
	cout << "value is:" << in.m_str.c_str();
	return o;
} 
std::shared_ptr<Base> test_shared() {
    shared_ptr<Base> xx(new Base("unique_ptr<Base>"));//函数内的局部返回智能指针是兼容的
    shared_ptr<Base> z=std::make_shared<Base>("aaabbb");
    shared_ptr<Base> y=std::make_shared<Base>("aaabbb"); //be freed in this function
	xx->m_p1 = y;
    //unique_ptr<Base> yy=xx;
    cout << "unique_ptr<Base> test() " << xx.get() <<endl;
    cout << "unique_ptr<Base> test() " << y.get() <<endl;
    cout << "unique_ptr<Base> test() " << z.get() <<endl;
	//delete y.get(); //will lead to coredump
    return xx;
} 
std::unique_ptr<Base> test() {
    unique_ptr<Base> xx(new Base("unique_ptr<Base>"));//函数内的局部返回智能指针是兼容的
    //unique_ptr<Base> yy=xx;
    cout << "unique_ptr<Base> test() " << xx.get() <<endl;
    return xx;
} 
Base* test1() {
    Base* base = new Base("new Baseaa");
    cout << "base = " <<  base <<endl;
    cout << "base = " <<  *base <<endl;
    return base;
} 
char* test2() {
    char xx[] ="x";
    cout << &xx << endl;
    return xx;
} 
int main(int argc,const char * argv[]) {
    unique_ptr<Base> xx4 = test();  //这种调用就可以直接赋值
    cout << "reassign unique_ptr to xx4" <<endl;
	xx4=test();
	//auto x4=xx4;
    cout << "unique_ptr<Base> xx4 " << xx4.get() <<endl;
	auto y4=std::move(xx4);
    //cout << "xx4 = " << *xx4 << endl;  //lead to segment fault
    cout << "after move: xx4 = " << xx4.get() << endl;  //after move, it's value become 0
   
    Base* xx5 = test1();
    cout << "xx5 = " << xx5 << endl;
    cout << "*xx5 = " << *xx5 << endl;
    char* xx6 =test2();
    cout << &xx6 << endl;
    delete xx5; //主动调用delete 智能指针不需要主动调用delete

	auto p1=test_shared(); 
	auto p2=p1;
	cout << "p1 is " << *p1 << " p2 is" << *p2;
}

