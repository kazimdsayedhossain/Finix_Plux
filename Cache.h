#ifndef CACHE_H
#define CACHE_H

#include <map>
#include <list>
#include <optional>

// LRU Cache template class (Concept #13)
template<typename KeyType, typename ValueType>
class LRUCache {
public:
    explicit LRUCache(size_t capacity)
        : m_capacity(capacity)
    {
    }

    void put(const KeyType& key, const ValueType& value) {
        auto it = m_cacheMap.find(key);

        if (it != m_cacheMap.end()) {
            // Update existing entry
            m_cacheList.erase(it->second);
            m_cacheMap.erase(it);
        } else if (m_cacheList.size() >= m_capacity) {
            // Remove least recently used
            auto last = m_cacheList.back();
            m_cacheMap.erase(last.first);
            m_cacheList.pop_back();
        }

        // Add new entry
        m_cacheList.emplace_front(key, value);
        m_cacheMap[key] = m_cacheList.begin();
    }

    std::optional<ValueType> get(const KeyType& key) {
        auto it = m_cacheMap.find(key);

        if (it == m_cacheMap.end()) {
            return std::nullopt;
        }

        // Move to front (most recently used)
        auto listIt = it->second;
        m_cacheList.splice(m_cacheList.begin(), m_cacheList, listIt);

        return listIt->second;
    }

    bool contains(const KeyType& key) const {
        return m_cacheMap.find(key) != m_cacheMap.end();
    }

    void remove(const KeyType& key) {
        auto it = m_cacheMap.find(key);
        if (it != m_cacheMap.end()) {
            m_cacheList.erase(it->second);
            m_cacheMap.erase(it);
        }
    }

    void clear() {
        m_cacheList.clear();
        m_cacheMap.clear();
    }

    size_t size() const {
        return m_cacheList.size();
    }

    size_t capacity() const {
        return m_capacity;
    }

private:
    size_t m_capacity;
    std::list<std::pair<KeyType, ValueType>> m_cacheList;
    std::map<KeyType, typename std::list<std::pair<KeyType, ValueType>>::iterator> m_cacheMap;
};

#endif // CACHE_H
