#include <iostream>
#include <cstring>
//#include <cstdlib>
#include <vector>
#include <memory> 
using namespace std; 
class Str{
    public:
        char *str;
        Str(char value[]) {
            cout<<"普通构造函数..."<<endl;
            str = NULL;
            int len = strlen(value);
            str = (char *)malloc(len + 1);
            memset(str,0,len + 1);
            strcpy(str,value);
        }
        Str(const Str &s) {
            cout<<"拷贝构造函数..."<<endl;
            str = NULL;
            int len = strlen(s.str);
            str = (char *)malloc(len + 1);
            memset(str,0,len + 1);
            strcpy(str,s.str);
        }
        Str(Str &&s) noexcept {
            cout<<"移动构造函数..."<<endl;
            str = NULL;
            str = s.str;
            s.str = NULL;
        }
        ~Str() {
            cout<<"析构函数"<<endl;
            if(str != NULL) {
                free(str);
                str = NULL;
            }
        }
};

class Test
{
public:
	Test(const string& s = "hello world") :str(new string(s)) { cout << "默认构造函数" << endl; };
	Test(const Test& t);
	Test& operator=(const Test& t);
	Test(Test&& t)noexcept;
	//Test(Test&& t);
	Test& operator=(Test&& t)noexcept;
	~Test();
public:
	string * str;
};
Test::Test(const Test& t)
{
	str = new string(*(t.str));
	cout << "拷贝构造函数" << endl;
}
Test& Test::operator=(const Test& t)
{
	cout << "拷贝赋值运算符" << endl;
	return *this;
}
Test::Test(Test&& t)noexcept
//Test::Test(Test&& t)
{
	str = t.str;
	t.str = nullptr;
	cout << "移动构造函数" << endl;
}
Test& Test::operator=(Test&& t)noexcept
{
	cout << "移动赋值运算符" << endl;
	return *this;
}
Test::~Test()
{
	cout << "析构函数" << endl;
}


std::unique_ptr<Str> test(char* s) {
	cout << "in test()" <<endl;
	auto p=std::make_unique<Str>(const_cast<char*>("aaa"));
	cout << "return p" <<endl;
	return p;
}

int main() {
	std::unique_ptr<Str> p1(new Str("abc"));
	auto p2(new Str("aaa"));
	auto p3=std::make_unique<Str>((char*)"aaa");
	auto p4=std::make_unique<Str>(const_cast<char*>("aaa"));
	//auto p5=p4; //error
	auto p5=std::move(p4); //error
	cout << "call test() which return unique_ptr" <<endl;
	auto p06=test("aaa");
	//auto p16=p06;
	cout << "end call for test()" << p06->str<<endl;
    char value[] = "I love zzz";
    Str s(value);
    vector<Str> vs;
	//auto p6=move(s);
    vs.push_back(std::move(s));
	cout << "begin push_back again" <<endl;
    //vs.push_back(s); //lead to segment fault
	cout << "begin output" <<endl;
    cout<<vs[0].str<<endl;
    if(s.str != NULL)
        cout<<s.str<<endl;
	cout << "===============================" <<endl;
	vector<Test> vec(1);
	Test t("what");
	vec.push_back(std::move(t));
    return 0;
}
