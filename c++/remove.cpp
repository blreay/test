#include <algorithm>
#include <vector>
#include <iostream>

int main() {
  std::vector<int> vec = {1, 2, 3, 2, 4, 2, 5};

  // 移除所有等于2的元素
  auto newEnd = std::remove(vec.begin(), vec.end(), 2);

  // 注意：vec 的大小还没有改变，需要调用erase来真正删除元素
  vec.erase(newEnd, vec.end());

  for (int num : vec) {
    std::cout << num << " ";
  }
  std::cout << std::endl;

  {
    std::vector<int> vec = {1, 2, 3, 2, 4, 2, 5};

    // 移除所有等于2的元素
    auto newEnd = std::remove(vec.begin(), vec.begin()+4, 2);

    // 注意：vec 的大小还没有改变，需要调用erase来真正删除元素
    // will erase all items in the end sequence
    // vec.erase(newEnd, vec.end());
    vec.erase(newEnd, vec.begin()+4);

    for (int num : vec) {
      std::cout << num << " ";
    }
    std::cout << std::endl;
  }

  return 0;
}
