#include<fstream>
#include<iostream>
#include<sstream>
using namespace std;

int test2() {
	cout << __FUNCTION__<<endl;
	fstream fin("1.in",ios::in|ios::binary);
	if(!fin.is_open()) {
		cout << "源文件打开失败" << endl;
		return 0;
	};
	std::stringstream f;
	f<<fin.rdbuf();
	fin.close();
	cout << f.str();
	return 0;
} 
int test1() {
	cout << __FUNCTION__<<endl;
	fstream fin("1.in",ios::in|ios::binary);
	if(!fin.is_open()) {
		cout << "源文件打开失败" << endl;
		return 0;
	}
	fstream fout("2.out",ios::out|ios::binary);
	if(! fin.is_open()) {
		cout << "目标文件打开失败!" << endl;
		return 0;
	}
	fout<<fin.rdbuf();
	fin.close();
	fout.close();
	return 0;
} 

int main () {
	test1();
	test2();
	return 0;
}
