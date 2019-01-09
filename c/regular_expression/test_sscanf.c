#include <stdio.h>

int main()
{
      const char* s = "iios/12DDWDFF@122";
      const char* s1 = "/home/zhaozhan/test/12";
      const char* s2 = "/ho-m,e/zhaozhan/test/1-2";
      char buf[20];

      sscanf( s, "%*[^/]/%[^@]", buf );
      printf( "%s\n", buf );

	  memset(buf, 0x0, sizeof(buf));
      sscanf( s1, "%*[/a-zA-Z0-9.]%1c", buf );
      printf( "%s\n%d\n", buf, strlen(buf) );

	  memset(buf, 0x0, sizeof(buf));
      sscanf( s2, "%*[/a-zA-Z0-9.]%1c", buf );
      printf( "%s\n%d\n", buf, strlen(buf) );

      return 0;
}
