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
	int num;
	printf("Enter a integer number:");
	scanf("%d", &num);
	char ch[10]={0};
	sprintf(ch, "%08X", num);
	printf("Convert to hex:%08s\n", ch);
	for (int i=0; i<4; i=i+2) {
		auto a=ch[i];
		ch[i]=ch[8-i-2];
		ch[8-i-2]=a;
		a=ch[i+1];
		ch[i+1]=ch[8-i-1];
		ch[8-i-1]=a;
	}
	char* p=ch;
	printf("Convert to hex:%08s\n", ch);
	auto s=convert(num);
	printf("Convert to hex by string:%08s\n", s.c_str());

	char Hex[10] = {0};
	long int Integer;
	printf("Enter a Hex number:");
	scanf("%s", Hex);
	Integer = strtol(Hex, NULL, 16);
	printf("Convert to decimal:%ld\n", Integer);

}
