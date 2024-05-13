#include <iostream>
#include <unordered_map>
#include <vector>
#include <cstdlib>
#include <ctime>

class RandomSet {
public:
    // 插入一个元素。如果元素已经存在，返回 false。
    bool insert(int val) {
        auto it = indexMap.find(val);
        if (it != indexMap.end()) {
            // 元素已存在
            return false;
        }
        // 将新元素的索引映射到数组的当前 "末尾"
        indexMap[val] = values.size();
        values.push_back(val);
        return true;
    }

    // 删除一个元素。如果元素不存在，返回 false。
    bool remove(int val) {
        auto it = indexMap.find(val);
        if (it == indexMap.end()) {
            // 元素不存在
            return false;
        }
        // 将数组末尾的元素移动到要删除元素的位置
        int lastElement = values.back();
        values[it->second] = lastElement;
        indexMap[lastElement] = it->second;
        // 删除原来数组末尾的元素
        values.pop_back();
        indexMap.erase(val);
        return true;
    }

    // 获取随机元素
    int getRandom() {
        if (values.empty()) {
            throw std::out_of_range("No elements in RandomSet.");
        }
        int randomIndex = rand() % values.size();
        return values[randomIndex];
    }

private:
    std::vector<int> values;  // 数组存储元素
    std::unordered_map<int, int> indexMap;  // 映射元素到它们在数组中的索引
};

int main() {
    // 初始化随机种子
    srand(static_cast<unsigned int>(time(nullptr)));

    RandomSet randomSet;

    // 添加一些元素
    for (auto i=0; i<=100; i++) {
      randomSet.insert(i);
    }
    //randomSet.insert(2);
    //randomSet.insert(3);

    // 移除一个元素
    randomSet.remove(1);

    // 获取一个随机元素
    std::cout << "A random element: " << randomSet.getRandom() << std::endl;

    return 0;
}

