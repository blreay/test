#include <iostream>
#include <thread>
class Task
{
  public:
    void execute(std::string command) {
      for(int i = 0; i < 5; i++)
      {
        std::cout<<command<<" :: "<<i<<std::endl;
      }
    }
    static void test(std::string command) {
      for(int i = 0; i < 5; i++)
      {
        std::cout<<command<<" :: "<<i<<std::endl;
      }
    }

};
int main() {
  Task * taskPtr = new Task();
  // Create a thread using member function
  std::thread th(&Task::execute, taskPtr, "Sample Task");
  th.join();
  delete taskPtr;

  // Create a thread using static member function
  std::thread th2(&Task::test, "Task");
  th2.join();
  return 0;
}
