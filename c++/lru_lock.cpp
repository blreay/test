#include <iostream>
#include <stdexcept>
#include <list>
#include <mutex>
#include <utility>
#include <thread>
#include <unordered_map>
#include <cstddef>

template <typename key_t, typename value_t>
class lru_cache {
  public:
    typedef typename std::pair<key_t, value_t> key_value_pair_t;
    typedef typename std::list<key_value_pair_t>::iterator list_iterator_t;

    explicit lru_cache(uint32_t max_size) : _max_size(max_size) {}

    uint32_t size() const {
        return items_map_.size();
    }

    bool exists(const key_t& key) {
        std::unique_lock<std::mutex> lock(mtx_);
        return items_map_.find(key) != items_map_.end();
    }

    void clear() {
        std::unique_lock<std::mutex> lock(mtx_);
        cache_.clear();
        items_map_.clear();
    }

    bool erase(const key_t& key) {
        std::unique_lock<std::mutex> lock(mtx_);

        auto it = items_map_.find(key);
        if (it == items_map_.end()) {
            return false;  // not exist, erase failed
        }
        cache_.erase(it->second);
        items_map_.erase(it);
        return true;
    }

    bool pop(key_t& key, value_t& value) {
        std::unique_lock<std::mutex> lock(mtx_);
        if (cache_.empty()) {
            return false;
        }

        auto last = cache_.end();
        last--;
        key = last->first;
        value = last->second;

        items_map_.erase(key);
        cache_.pop_back();
        return true;
    }

    bool get(const key_t& key, value_t& value) {
        std::unique_lock<std::mutex> lock(mtx_);

        auto it = items_map_.find(key);
        if (it == items_map_.end()) {
            return false;
        } else {
            if (it->second != cache_.begin()) {
                cache_.splice(cache_.begin(), cache_, it->second);
            }
            value = it->second->second;
            return true;
        }
    }

    void put(const key_t& key, const value_t& value) {
        std::unique_lock<std::mutex> lock(mtx_);

        auto it = items_map_.find(key);
        cache_.push_front(key_value_pair_t(key, value));
        if (it != items_map_.end()) {
            cache_.erase(it->second);
            items_map_.erase(it);
        }
        items_map_[key] = cache_.begin();

        if (items_map_.size() > _max_size) {
            auto last = cache_.end();
            last--;
            items_map_.erase(last->first);
            cache_.pop_back();
        }
    }

    bool get_last(key_t& key, value_t& value) {
        std::unique_lock<std::mutex> lock(mtx_);
        if (cache_.size()) {
            auto last = cache_.end();
            last--;
            key = last->first;
            value = last->second;
            return true;
        }
        return false;
    }


  private:
    std::list<key_value_pair_t> cache_;
    std::unordered_map<key_t, list_iterator_t> items_map_;
    uint32_t _max_size;
    std::mutex mtx_;
};

int main() {
    lru_cache<uint32_t, std::string> cache(3);

    cache.put(uint32_t(1), "test1");
    cache.put(uint32_t(2), "test2");
    cache.put(uint32_t(3), "test3");
    if (cache.exists(uint32_t(1))) std::cout << "01 OK" << std::endl;

    cache.put(uint32_t(4), "test4");
    if (!cache.exists(uint32_t(1)))  std::cout << "02 OK" << std::endl;

    std::string v;
    std::cout << cache.get(uint32_t(2), v) << ":" << v << std::endl;

    cache.put(uint32_t(5), "test5");
    if (!cache.exists(uint32_t(3)))  std::cout << "03 OK ->" << cache.size() << std::endl;

    cache.get(uint32_t(2), v);
    if (v == "test2") std::cout << "04 OK" << std::endl;
    cache.get(uint32_t(4), v);
    if (v == "test4") std::cout << "05 OK" << std::endl;

    // get last element
    uint32_t last_key;
    std::string last_value;
    cache.get_last(last_key, last_value);
    if (last_key == uint32_t(5)) std::cout << "06 OK" << std::endl;
    if (last_value == "test5") std::cout << "07 OK" << std::endl;
    cache.pop(last_key, last_value);
    std::cout << last_key << ":" << last_value << "->" << cache.size() << std::endl;;
    cache.pop(last_key, last_value);
    std::cout << last_key << ":" << last_value << std::endl;;
    if (last_key == uint32_t(2)) std::cout << "10 OK" << std::endl;
    if (last_value == "test2") std::cout << "11 OK" << std::endl;
}

