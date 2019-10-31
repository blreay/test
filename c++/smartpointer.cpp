#include <iostream>
#include <memory> 
using namespace std; 
class Base {
	friend ostream& operator << (ostream& o, Base& in); 
	public: 	std::string m_str;
		shared_ptr<Base> m_p1;
		Base(std::string in) {
			m_str=in;
			cout << "in Base()" << this << endl;
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

/*
#include <memory>
#include <iostream>
#include <malloc.h>
#include <map>
*/

void* operator new(std::size_t count){
	void* p=malloc(count);
    std::cout << "allocating " << count << " bytes:" << p << std::endl;
    return p;
} 
void operator delete(void* ptr) noexcept {
    std::cout << "global op delete called:" << ptr << std::endl;
    std::free(ptr);
} 
struct MyLargeType {
    ~MyLargeType() { std::cout << "destructor MyLargeType\n"; } 
private:
    int arr[100]; // wow... so huge!!!
};
/*
####### BEGIN: test_memfree_with_weakptr
make_shared:
allocating 416 bytes:0x2415ee0
destructor MyLargeType
explicit new:
allocating 400 bytes:0x2416090
allocating 24 bytes:0x2415c20
destructor MyLargeType
global op delete called:0x2416090
global op delete called:0x2415c20
global op delete called:0x2415ee0
####### END: test_memfree_with_weakptr 
*/
int test_memfree_with_weakptr_inner() {
    std::weak_ptr<MyLargeType> pw,pw2;
    {
		// both object and block can not be freed here
        std::cout << "make_shared: \n";
        auto p = std::make_shared<MyLargeType>();
        pw = p;        
    }
    {
		// object can be freed, but the block will not
        std::cout << "explicit new: \n";
        std::shared_ptr<MyLargeType> p(new MyLargeType());
        pw2 = p;
    }
	return 0;
};
/*
As long as std::weak_ptrs refer to a control block (i.e., the weak count is greater than zero), that control block must continue to exist. And as long as a control block exists, the memory containing it must remain allocated. The memory allocated by a std::shared_ptr make function, then, can’t be deallocated until the last std::shared_ptr and the last std::weak_ptr referring to it have been destroyed.
*/
int test_memfree_with_weakptr() {
	std::cout << "####### BEGIN: " << __FUNCTION__ << std::endl;
	test_memfree_with_weakptr_inner();
	std::cout << "####### END: " << __FUNCTION__ << std::endl;
	return 0;
};

int main(int argc,const char * argv[]) {
    std::unique_ptr<Base> xx4 = test();  //这种调用就可以直接赋值
    cout << "test auto" << argc << ":" << argv << endl;
	auto p0=test();
    cout << "test auto with set new pointer, p0 will be free" <<endl;
	p0=test();
    cout << "reassign unique_ptr to xx4" <<endl;
	xx4=test();
	std::unique_ptr<Base> p11(new Base("123"));
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

    shared_ptr<Base> y=std::make_shared<Base>("aaabbb"); //be freed in this function
	auto aaa=y;
	y.reset();
	// y.reset();
	if (y == nullptr) {
		std::cout << "testok###########################################" << aaa.use_count() << "y:" << y.use_count() << std::endl;
	}
    shared_ptr<Base> x=nullptr;
	x.reset();
	x.reset();
	cout << "begin to test nullptr" << endl;
    shared_ptr<Base> z=std::make_shared<Base>("ccccccc"); //be freed in this function
	auto z2 = z;
	z = nullptr;
	cout << "end test nullptr:" << z.get() << endl;
	cout << "begin to test reset" << endl;
    shared_ptr<Base> z1=std::make_shared<Base>("ccccccc"); //be freed in this function
	cout << "before reset:" << z1.get() << endl;
	z1.reset();
	cout << "end test reset:" << z1.get() << endl;

	// https://dev.to/fenbf/how-a-weakptr-might-prevent-full-memory-cleanup-of-managed-object-i0i
	test_memfree_with_weakptr();
}

