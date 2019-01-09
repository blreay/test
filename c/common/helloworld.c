#include <stdio.h>
#include <string.h>

int main(void){  
	printf("Hello World!/n");  
	int a=1;
	char b[256];
	printf(a==0?"OK/n":"Hello World!/n");  
	printf(a==1?"OK/n":"Hello World!/n");  
	strcpy(b, b==1?"\nzzyok":"\nzzyng");
	printf(b);
	return 0;
}
