#include <chrono>
#include <iostream>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <ctime>
#include <string>
#include <sstream>
#include <iomanip>


// 原文链接：https://blog.csdn.net/alwaysrun/article/details/105895295
// 时间字符串(如：2020-05-02 14:40:31.015)
std::string getTimeString(bool bLocal, bool bIncludeMS) {
  auto tNow = std::chrono::system_clock::now();
  //auto tmNow = std::chrono::system_clock::to_time_t(tNow);
  auto tSeconds = std::chrono::duration_cast<std::chrono::seconds>(tNow.time_since_epoch());
  auto secNow = tSeconds.count();
  auto tMilli = std::chrono::duration_cast<std::chrono::milliseconds>(tNow.time_since_epoch());
  auto ms = tMilli - tSeconds;
  tm tmNow;
  if (bLocal) {
    // gcc compile fail:error: 'localtime_s' was not declared in this scope
    // donot know how to fix it, following cannot work
    //#define __STDC_WANT_LIB_EXT1__ 1
    //#define __STDC_LIB_EXT1__ 1
    //localtime_s(&tmNow, &secNow);
    localtime_r(&secNow, &tmNow);
  }
  else {
    gmtime_r(&secNow, &tmNow);
  }
  std::ostringstream oss;
  oss << std::put_time(&tmNow, "%Y-%m-%d %H:%M:%S");
  if (bIncludeMS) {
    oss << "." << std::setfill('0') << std::setw(3) << ms.count();
  }
  return oss.str();
}

// this is thread safe, the best so far
std::string GetCurrentTimeInUs() {
  static char szBuf[64] = {};
  struct timeval    tv;
  struct timezone   tz;
  static __thread tm tm_start;

  gettimeofday(&tv, &tz);
  // localtime is not thread safe
  // struct tm         *p;
  // p = localtime(&tv.tv_sec);
  auto p = &tm_start;
  localtime_r(&tv.tv_sec, p);
  snprintf(szBuf, sizeof(szBuf) -1 , "%02d-%02d-%02d %02d:%02d:%02d.%06ld", p->tm_year + 1900, p->tm_mon, p->tm_mday, p->tm_hour, p->tm_min, p->tm_sec, tv.tv_usec);
  return szBuf;
}

//////////////////////////////////////////////////////////////////
// show optimize of localtime_r
void printnow(){
  static unsigned long long time=0;
  timeval tm;
  gettimeofday(&tm,NULL);
  if(time !=0)
    printf("cost time = %llu\n",tm.tv_sec*1000000+tm.tv_usec - time);
  time = tm.tv_sec*1000000+tm.tv_usec;
}
void printtm(tm& tm){
  printf("tm_sec:%d,tm_min:%d,tm_hour:%d,tm_day:%d,tm_mon:%d,tm_year:%d,tm_wday:%d,tm_yday:%d,tm_isdst:%d,tm_gmtoff:%d,tm_zone:%s\n",
      tm.tm_sec,tm.tm_min,tm.tm_hour,tm.tm_mday,tm.tm_mon,tm.tm_year,tm.tm_wday,tm.tm_yday,tm.tm_isdst,tm.tm_gmtoff,tm.tm_zone);
}
tm* my_localtime_r(const time_t* tNow,tm* stTM){
  static __thread long t_start = 0;
  static __thread tm tm_start;
#define my_localtime_r_t_oneday 86400                //(24*60*60)
#define my_localtime_r_t_onehour 3600                //(60*60)
  if(t_start == 0||*tNow<t_start||*tNow-t_start>=my_localtime_r_t_oneday){
    localtime_r(tNow,&tm_start);
    tm_start.tm_hour = 0;
    tm_start.tm_min = 0;
    tm_start.tm_sec = 0;
    t_start=mktime(&tm_start);
  }
#define my_localtime_r_off  (*tNow-t_start)
  tm_start.tm_hour = (*tNow-t_start)/(my_localtime_r_t_onehour);
  tm_start.tm_min = ((*tNow-t_start)-my_localtime_r_t_onehour*tm_start.tm_hour)/60;
  tm_start.tm_sec = ((*tNow-t_start)-my_localtime_r_t_onehour*tm_start.tm_hour-60*tm_start.tm_min);
  memcpy(stTM,&tm_start,sizeof(tm));
  return stTM;
}
int localtime_main() {
  time_t m_tNow;
  tm m_stTM;
  tm m_stTM1;
  tm* result;
  tm* result1;
  m_tNow = time(0);
  int count = 100000;

  printnow();
  for(int i=0;i<count;i++){
    result = localtime_r (&m_tNow, &m_stTM);
  }
  printnow();

  for(int i =0;i<count;i++)
  {
    result1 = my_localtime_r( &m_tNow, &m_stTM1);
  }
  printnow();

  printtm(*result);
  printtm(*result1);
}

std::time_t getTimeStamp() {
  std::chrono::time_point<std::chrono::system_clock, std::chrono::milliseconds> tp = std::chrono::time_point_cast<std::chrono::milliseconds>(std::chrono::system_clock::now());
  return tp.time_since_epoch().count();
}

int main()
{
  // 以下为5分钟表达
  std::chrono::minutes minute1{5}; // 5个1分钟
  std::chrono::duration<int, std::ratio<5*60, 1>> minute2{1}; // 1个5分钟
  std::chrono::duration<double, std::ratio<2*60, 1>> minute3{2.5}; // 2.5个2分钟

  std::cout << "minutes1 duration has " << minute1.count() << " ticks\n"
    << "minutes2 duration has " << minute2.count() << " ticks\n"
    << "minutes3 duration has " << minute3.count() << " ticks\n";

  // 一下为12小时表达
  std::chrono::hours hours1{12}; // 12个1小时
  std::chrono::duration<double, std::ratio<60*60*24, 1>> hours2{0.5}; // 0.5个1天

  std::cout << "hours1 duration has " << hours1.count() << " ticks\n"
    << "hours2 duration has " << hours2.count() << " ticks\n";

  // 使用 std::chrono::duration_cast<T> 将分钟间隔转化成标准秒间隔
  std::cout << "minutes1 duration has " <<
    std::chrono::duration_cast<std::chrono::seconds>(minute1).count() << " seconds\n";

  /////////////////////////////////////////////////////////////////////
  std::chrono::duration<int, std::ratio<60*60*24> > one_day(1);

  // 根据时钟得到现在时间
  std::chrono::system_clock::time_point today = std::chrono::system_clock::now();
  std::time_t time_t_today = std::chrono::system_clock::to_time_t(today);
  std::cout << "now time stamp is " << time_t_today << std::endl;
  std::cout << "now time is " << ctime(&time_t_today) << std::endl;

  // 看看明天的时间
  std::chrono::system_clock::time_point tomorrow = today + one_day;
  std::time_t time_t_tomorrow = std::chrono::system_clock::to_time_t(tomorrow);
  std::cout << "tomorrow time stamp is " << time_t_tomorrow << std::endl;
  std::cout << "tomorrow time is " << ctime(&time_t_tomorrow) << std::endl;

  // 计算下个小时时间
  std::chrono::system_clock::time_point next_hour = today + std::chrono::hours(1);
  std::time_t time_t_next_hour = std::chrono::system_clock::to_time_t(next_hour);
  std::chrono::system_clock::time_point next_hour2 = std::chrono::system_clock::from_time_t(time_t_next_hour);

  std::time_t time_t_next_hour2 = std::chrono::system_clock::to_time_t(next_hour2);
  std::cout << "tomorrow time stamp is " << time_t_next_hour2 << std::endl;
  std::cout << "tomorrow time is " << ctime(&time_t_next_hour2) << std::endl;

  ////////////////////////////////////////////////////////////////////////
  // 先记录程序运行时间
  std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();

  volatile int nDstVal=0, nSrcVal=0;
  // for (int i = 0; i < 1000000000; ++i) {
  for (int i = 0; i < 100000000; ++i) {
    nDstVal = nSrcVal;
  }

  // 做差值计算耗时
  std::chrono::duration<double> duration_cost = std::chrono::duration_cast<std::chrono::duration<double>>(std::chrono::steady_clock::now() - start);
  std::cout << "total cost " << duration_cost.count() << " seconds." << std::endl;
  auto duration_cost2 = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - start);
  std::cout << "total2cost " << duration_cost2.count() << " milli seconds." << std::endl;


  //////////////////////////////////////////////////////////////////////////////
  // 获得epoch 和 now 的时间点
  std::chrono::time_point<std::chrono::system_clock> epoch = std::chrono::time_point<std::chrono::system_clock>{};
  std::chrono::time_point<std::chrono::system_clock> now = std::chrono::system_clock::now();

  // 显示时间点对应的日期和时间
  time_t epoch_time = std::chrono::system_clock::to_time_t(epoch);
  std::cout << "epoch: " << std::ctime(&epoch_time);
  time_t today_time = std::chrono::system_clock::to_time_t(now);
  std::cout << "today: " << std::ctime(&today_time);

  // 显示duration的值
  std::cout << "seconds since epoch: "
    << std::chrono::duration_cast<std::chrono::seconds>(epoch.time_since_epoch()).count()
    << std::endl;

  std::cout << "today, ticks since epoch: "
    << now.time_since_epoch().count()
    << std::endl;

  std::cout << "today, hours since epoch: "
    << std::chrono::duration_cast<std::chrono::hours>(now.time_since_epoch()).count()
    << std::endl;

  // test gettimestamp
  auto tp = getTimeStamp();
  std::cout << "timestamp:" << tp << std::endl;
  //printf("this is what? timestamp: %u\n", tp);

  {
    auto t = std::chrono::system_clock::now();
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::seconds>(t.time_since_epoch()).count());
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::milliseconds>(t.time_since_epoch()).count());
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::microseconds>(t.time_since_epoch()).count());
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::nanoseconds>(t.time_since_epoch()).count());
  }
  {
    auto t = std::chrono::steady_clock::now();
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::milliseconds>(t.time_since_epoch()).count());
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::microseconds>(t.time_since_epoch()).count());
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::nanoseconds>(t.time_since_epoch()).count());
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::milliseconds>(t.time_since_epoch()).count());
    printf("direct time: %ld\n",std::chrono::duration_cast<std::chrono::microseconds>(t.time_since_epoch()).count());
  }

  localtime_main();

  // test getTimeString()
  auto s1 = getTimeString(true, true);
  auto s2 = getTimeString(true, false);
  auto s3 = getTimeString(false, true);
  auto s4 = getTimeString(false, false);
  std::cout  << "getTimeString(true, true)"   << s1 << std::endl
    << "getTimeString(true, false)"  << s2 << std::endl
    << "getTimeString(false, true)"  << s3 << std::endl
    << "getTimeString(false, false)" << s4 << std::endl;

  auto s = GetCurrentTimeInUs();
  std::cout << "current time: " << s <<std::endl;
}
