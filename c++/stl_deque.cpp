#include <iostream>
#include <deque>
#include <vector>

void printDeque(const std::deque<int>& dq) {
    std::cout << "Deque contents: ";
    for (int val : dq) {
        std::cout << val << " ";
    }
    std::cout << std::endl;
}

int main() {
    // 创建一个空的 deque
    std::deque<int> dq;

    // 检查 deque 是否为空
    std::cout << "Is deque empty? " << (dq.empty() ? "Yes" : "No") << std::endl;

    // 在尾部插入元素
    dq.push_back(10);
    dq.push_back(20);
    dq.push_back(30);
    printDeque(dq);

    // 在头部插入元素
    dq.push_front(5);
    dq.push_front(0);
    printDeque(dq);

    // 访问头部和尾部元素
    std::cout << "Front element: " << dq.front() << std::endl;
    std::cout << "Back element: " << dq.back() << std::endl;

    // 移除头部和尾部元素
    dq.pop_front();
    dq.pop_back();
    printDeque(dq);

    // 使用 operator[] 和 at() 访问元素
    std::cout << "Element at index 1: " << dq[1] << std::endl;
    std::cout << "Element at index 2 (using at): " << dq.at(2) << std::endl;

    // 插入元素到指定位置
    dq.insert(dq.begin() + 2, 15);  // 在索引 2 前插入 15
    printDeque(dq);

    // 删除指定位置的元素
    dq.erase(dq.begin() + 1);  // 删除索引 1 的元素
    printDeque(dq);

    // 清空 deque
    dq.clear();
    std::cout << "After clear: ";
    printDeque(dq);
    std::cout << "Is deque empty? " << (dq.empty() ? "Yes" : "No") << std::endl;

    return 0;
}
