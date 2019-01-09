
#include <stdio.h>; 
#include <sys/types.h>; 
#include <regex.h>; 

static char* substr(const char*str, unsigned start, unsigned end) 
{ 
	unsigned n = end - start; 
	static char stbuf[256]; 
	strncpy(stbuf, str + start, n); 
	stbuf[n] = 0; 
	return stbuf; 
} 

int main(int argc, char** argv) 
{ 
	char * pattern; 
	int x, z, lno = 0, cflags = 0; 
	char ebuf[128], lbuf[256]; 
	regex_t reg; 
	regmatch_t pm[10]; 
	const size_t nmatch = 10; 
	pattern = argv[1]; 
	pattern = "([^;]*);([^;]*)(;([^;]*)){0,1}";
	cflags=REG_EXTENDED;
	fprintf(stdout, "pattern:%s\n", pattern);
	z = regcomp(&reg, pattern, cflags); 
	if (z != 0){ 
		regerror(z, &reg, ebuf, sizeof(ebuf)); 
		fprintf(stderr, "%s: pattern '%s' \n", ebuf, pattern); 
		return 1; 
	} 
	while(fgets(lbuf, sizeof(lbuf), stdin)) { 
		++lno; 
		if ((z = strlen(lbuf)) >= 0 && lbuf[z-1] == '\n') 
		  lbuf[z - 1] = 0; 
		z = regexec(&reg, lbuf, nmatch, pm, 0); 
		if (z == REG_NOMATCH)
		  continue; 
		else if (z != 0) { 
			regerror(z, &reg, ebuf, sizeof(ebuf)); 
			fprintf(stderr, "%s: regcom('%s')\n", ebuf, lbuf); 
			return 2; 
		} 
		for (x = 0; x < nmatch && pm[x].rm_so != -1; ++ x) { 
			if (!x) printf("%04d: %s\n", lno, lbuf); 
			printf("  $%d='%s'\n", x, substr(lbuf, pm[x].rm_so, pm[x].rm_eo)); 
		} 
		printf("x=%d\n", x);
		if (3 == x) {
			char str1[256] = { '\0' };
			char str2[256] = { '\0' };
			char str_res[1024] = { '\0' };
			strcpy(str1, substr(lbuf, pm[1].rm_so, pm[1].rm_eo));
			strcpy(str2, substr(lbuf, pm[2].rm_so, pm[2].rm_eo));
			sscanf(str1, str2, str_res);
			printf("str1=%s, str2=%s, Result:%s\n", str1, str2, str_res);
		}
		if (5 == x) {
			//flush();
			char str1[256] = { '\0' };
			char str2[256] = { '\0' };
			char str_res1[256] = { '\0' };
			char str_res2[256] = { '\0' };
			char str_res3[256] = { '\0' };
			char* p0=substr(lbuf, pm[1].rm_so, pm[1].rm_eo);
			char* p1= p0 + strspn(p0, " \t");
			strcpy(str1, p1);
			strcpy(str2, substr(lbuf, pm[2].rm_so, pm[2].rm_eo));
			sscanf(str1, str2, str_res1, str_res2, str_res3);
			printf("str1=%s, str2=%s, Result:%s;%s;%s\n", str1, str2, str_res1, str_res2, str_res3);
			char* p5=substr(lbuf, pm[4].rm_so, pm[4].rm_eo);
			if (strcmp(p5, "2") == 0 ) {
				sscanf(str1, str2, str_res1, str_res2);
				printf("str1=%s, str2=%s, Result:%s;%s[2 params]\n", str1, str2, str_res1, str_res2);
			}
			if (strcmp(p5, "x1") == 0 ) {
				sscanf(str1, str2, str_res1, str_res2);
				printf("str1=%s, str2=%s, Result:%s;%s[%s]\n", str1, str2, str_res1, str_res2, p5);
			}
		}
	} 
	regfree(&reg); 
	return 0; 
} 

