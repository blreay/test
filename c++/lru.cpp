#include <list>
#include <unordered_map>
#include <cassert>

template<typename K, typename V>
class LRUCache {
public:
    LRUCache(size_t capacity) : _capacity(capacity) {}

    void put(const K& key, const V& value) {
        // 如果键已存在，更新值并更新最近使用的顺序
        auto it = _cache.find(key);
        if (it != _cache.end()) {
            it->second.second = value;
            _access_order.erase(it->second.first);
            _access_order.push_front(key);
            it->second.first = _access_order.begin();
            return;
        }
        
        // 如果已达到容量限制，则移除最久未使用的元素
        if (_cache.size() == _capacity) {
            const K& old_key = _access_order.back();
            _cache.erase(old_key);
            _access_order.pop_back();
        }
        
        // 添加新元素到缓存并记录其在访问顺序列表中的位置
        _access_order.push_front(key);
        _cache[key] = { _access_order.begin(), value };
    }

    V get(const K& key) {
        auto it = _cache.find(key);
        // 如果键不存在，返回 V 的默认值
        if (it == _cache.end()) {
            return V();
        }
        
        // 如果键存在，更新访问顺序记录
        _access_order.erase(it->second.first);
        _access_order.push_front(key);
        it->second.first = _access_order.begin();
        
        return it->second.second;
    }

private:
    size_t _capacity;
    std::list<K> _access_order; // 双向链表维护键的最近访问顺序
    std::unordered_map<K, std::pair<typename std::list<K>::iterator, V>> _cache; // 哈希表存储键值对和键在访问顺序链表中的位置
};

int main() {
    LRUCache<int, int> cache(3);
    cache.put(1, 1);
    cache.put(2, 2);
    cache.put(3, 3);
    assert(cache.get(1) == 1); // 返回 1
    cache.put(4, 4); // 移除键 2
    assert(cache.get(2) == 0); // 键 2 不存在
    LRUCache<string, int> cache1(3);
    cache1.put("aaa", 2);
    cache1.put("bbb", 3);
    cache1.put("ccc", 4);
    return 0;
}
