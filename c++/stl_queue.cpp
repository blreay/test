#include <iostream>
#include <queue>      // 使用默认的 std::deque 作为底层容器
#include <vector>     // 可选：使用 std::vector 作为底层容器
#include <list>       // 可选：使用 std::list 作为底层容器

// 使用 std::list 作为底层容器的 queue
using MyQueue = std::queue<int, std::list<int>>;

void printQueue(const MyQueue& q) {
    MyQueue temp = q;  // 复制队列以避免修改原队列
    std::cout << "Queue contents: ";
    while (!temp.empty()) {
        std::cout << temp.front() << " ";
        temp.pop();
    }
    std::cout << std::endl;
}

int main() {
    // 创建一个空队列
    MyQueue q;

    // 检查队列是否为空
    std::cout << "Is queue empty? " << (q.empty() ? "Yes" : "No") << std::endl;

    // 插入元素
    q.push(10);
    q.push(20);
    q.push(30);
    std::cout << "After push(10), push(20), push(30): ";
    printQueue(q);

    // 访问队列头部和尾部元素
    std::cout << "Front element: " << q.front() << std::endl;
    std::cout << "Back element: " << q.back() << std::endl;

    // 移除头部元素
    q.pop();
    std::cout << "After pop(): ";
    printQueue(q);

    // 检查队列大小
    std::cout << "Queue size: " << q.size() << std::endl;

    // 清空队列（需要手动实现）
    while (!q.empty()) {
        q.pop();
    }
    std::cout << "After clearing: ";
    printQueue(q);
    std::cout << "Is queue empty? " << (q.empty() ? "Yes" : "No") << std::endl;

    return 0;
}
