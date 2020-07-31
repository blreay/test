#include "iostream"

using namespace std;
class CBase{
	public:
			virtual void xfn(int i){
					cout << "Base::xfn(int i)" << endl; //1
			}
			void yfn(float f){
					cout << "Base::yfn(float)" << endl; //2
			}
			void zfn(){
					cout << "Base::zfn()" << endl;  //3
			}
};
class CDerived : public CBase{
	public:
			void xfn(int i){
				cout << "Derived::xfn(int i)" << endl;  //4
			}
			void yfn(int c){
				cout << "Derived:yfn(int c)" << endl;  //5
			}
			void zfn(){
				cout << "Derived:zfn()" << endl;  //6
			}
};
int main(){
		CDerived d;
		CBase *pb = &d;
		CDerived *pd = &d;
		pb->xfn(5);  //覆盖
		pd->xfn(5);  //直接调用
 
		pb->yfn(3.14f); //直接调用
		pd->yfn(3.14f);  //隐藏
 
		pb->zfn();  //直接调用
		pd->zfn();  //隐藏
    return 0;
}

