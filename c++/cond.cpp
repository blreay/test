
#include <iostream>
 
#include <mutex>
#include <condition_variable>
#include <thread>
#include <queue>
 
static bool more = true;
 
bool more_data_to_prepare()
{
	return more;
}
 
struct data_chunk
{
	char m_data = 'q';
	data_chunk(char c) : m_data(c) {
	}
};
 
data_chunk prepare_data()
{
	std::cout << "data_preparation_thread prepare_data"<< std::endl;
	char x = 'q';
	std::cin >> x;
	if (x == 'q')
	{
		more = false;
	}
    return data_chunk(x);
}
 
void process(data_chunk& data)
{
	std::cout << "process data: " << data.m_data << std::endl;
}
 
bool is_last_chunk(data_chunk& data)
{
	if (data.m_data == 'q')
    {
    	return true;
	}
	
	return false;
}
 
std::mutex mut;
std::queue<data_chunk> data_queue;	// 用于线程间通信的队列 
std::condition_variable data_cond;
 
void data_preparation_thread()
{
    while(more_data_to_prepare())
    {
    	std::cout << "data_preparation_thread while" << std::endl;
        data_chunk const data=prepare_data();
        std::lock_guard<std::mutex> lk(mut);
        // 数据准备好后，使用lock_guard来锁定信号量，将数据插入队列之中 
        data_queue.push(data);
        std::cout << "data_preparation_thread notify_one" << std::endl;
        // 通过条件变量通知其它等待的线程 
        data_cond.notify_one();
    }
}
 
void data_processing_thread()
{
    while(true)
    {
    	std::cout << "data_processing_thread while" << std::endl;
    	// 使用unique_lock，因为我们需要在取得数据之后，处理数据之间，解锁mutex 
        std::unique_lock<std::mutex> lk(mut);
        std::cout << "data_processing_thread before wait" << std::endl;
        // 等待条件满足，unique_lock和Lambda函数，判断数据队列是否为空 
        data_cond.wait(lk,[]{return !data_queue.empty();});
        std::cout << "data_processing_thread pass wait" << std::endl;
        data_chunk data=data_queue.front();
        data_queue.pop();
        // 处理数据需要较多时间，所以先解锁mutex 
        lk.unlock();
        std::cout << "data_processing_thread process data" << std::endl;
        process(data);
        if(is_last_chunk(data))
            break;
    }
}
 
int main()
{
	std::cout << "main" << std::endl;
    std::thread t1(data_preparation_thread);
    std::thread t2(data_processing_thread);
    
    t1.join();
    t2.join();
}
