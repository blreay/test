#include <stdio.h>
#include <string.h>

/*  The strncpy and stpncpy subroutines copy the number of bytes specified by the Number parameter from the string pointed to by the String2 parameter to the character array pointed */
/*        to by the String1 parameter. If the String2 parameter value is less than the specified number of characters, then the strncpy subroutine pads the String1 parameter with trailing */
/*        null characters to a number of bytes equaling the value of the Number parameter. If the String2 parameter is exactly the specified number of characters or more, then only the */
/*        number of characters specified by the Number parameter are copied and the result is not terminated with a null byte. The strncpy subroutine returns the value of the String1 */
/*        parameter. */

char s[8]="1234567";
char d[10]="123456780";

int main(void){  
	printf("s=<%s>\n", s);
	printf("d=<%s>\n", d);
	strncpy(d, s, 7); /* d will not change, because no NULL is appended, this is evry trcky */
	printf("s=<%s>\n", s);
	printf("d=<%s>\n", d); 
	strncpy(d, s, 8);
	printf("s=<%s>\n", s);
	printf("d=<%s>\n", d); 
	return 0;
}
