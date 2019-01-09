#include <stdio.h>
#include <time.h>

int main(void)
{
	time_t t;
	time(&t);
	printf("Today's date and time in ctime: %s", ctime(&t));
	printf("Today's date and time in asctime: %s", asctime(&t));

	time_t nowtime;
	struct tm *timeinfo;
	time( &nowtime );
	timeinfo = localtime( &nowtime );
	int year, month, day;
	year = timeinfo->tm_year + 1900;
	month = timeinfo->tm_mon + 1;
	day = timeinfo->tm_mday;
	printf("%04d%02d%02d_%02d%02d%02d\n", timeinfo->tm_year + 1900,  timeinfo->tm_mon + 1, timeinfo->tm_mday, timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
	return 0;
}
