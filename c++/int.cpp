#include <stdio.h> 
#include <stdlib.h>
#include <string>

std::string convert(int num) {
	char ch[10]={0};
	sprintf(ch, "%08X", num);
	//printf("Convert to hex:%08s\n", ch);
	for (int i=0; i<4; i=i+2) {
		auto a=ch[i];
		ch[i]=ch[8-i-2];
		ch[8-i-2]=a;
		a=ch[i+1];
		ch[i+1]=ch[8-i-1];
		ch[8-i-1]=a;
	}
	char* p=ch;
	//printf("Convert to hex:%08s\n", ch);
	return "04" + std::string(ch);
}

int main(int argc, char* argv[]) { 
	char str[1024];
	printf("Enter a integer number:");
	scanf("%s", &str);
	auto n=std::atoi(str);
	printf("Convert to decimal:%s\n", str);
	printf("Convert to decimal:%d\n", n);
}
