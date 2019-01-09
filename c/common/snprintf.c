#include <stdlib.h>
#include <limits.h>
#include <stdio.h>
#include <errno.h>

int main(int argc, char *argv[])
{
	int base;
	char *endptr, *str;
	long val;
	char buf[256] = "AAA";

	//if (argc < 2) {
	if (argc < 0) {
		fprintf(stderr, "Usage: %s str [base]\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	//str = argv[1];
	//base = (argc > 2) ? atoi(argv[2]) : 10;
	str="123";
	base=10;

	errno = 0;    /* To distinguish success/failure after call */
	val = strtol(str, &endptr, base);

	/* Check for various possible errors */

	if ((errno == ERANGE && (val == LONG_MAX || val == LONG_MIN))
			|| (errno != 0 && val == 0)) {
		perror("strtol");
		exit(EXIT_FAILURE);
	}

	if (endptr == str) {
		fprintf(stderr, "No digits were found\n");
		exit(EXIT_FAILURE);
	}

	/* If we got here, strtol() successfully parsed a number */

	printf("strtol() returned %ld\n", val);

	if (*endptr != '\0')        /* Not necessarily an error... */
		printf("Further characters after number: %s\n", endptr);
	
	/* NOTICE: following statement can't append BBB to AAA */
	printf("buf=%s\n", buf);
	printf("[wrong useage of snprintf]after use snprintf to append BBB to buf\n", buf);
	snprintf(buf, 240, "%s%s", buf, "BBB");
	printf("buf=%s\n", buf);
	printf("[conclusion]don't use same char* in src and dst of snprintf\n", buf);

	exit(EXIT_SUCCESS);
}

