#include <chrono>
#include <iostream>
std::time_t getTimeStamp()
{
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
}
