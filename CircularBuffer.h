#ifndef CIRCULARBUFFER_H
#define CIRCULARBUFFER_H

#include <vector>
#include <stdexcept>

// Class template (Concept #13)
template<typename T>
class CircularBuffer {
public:
    explicit CircularBuffer(size_t capacity)
        : m_buffer(capacity)
        , m_capacity(capacity)
        , m_size(0)
        , m_head(0)
        , m_tail(0)
    {
    }

    void push(const T& item) {
        m_buffer[m_head] = item;
        m_head = (m_head + 1) % m_capacity;

        if (m_size < m_capacity) {
            m_size++;
        } else {
            m_tail = (m_tail + 1) % m_capacity;
        }
    }

    T pop() {
        if (isEmpty()) {
            throw std::out_of_range("Buffer is empty");
        }

        T item = m_buffer[m_tail];
        m_tail = (m_tail + 1) % m_capacity;
        m_size--;

        return item;
    }

    const T& peek() const {
        if (isEmpty()) {
            throw std::out_of_range("Buffer is empty");
        }
        return m_buffer[m_tail];
    }

    T& operator[](size_t index) {
        if (index >= m_size) {
            throw std::out_of_range("Index out of range");
        }
        return m_buffer[(m_tail + index) % m_capacity];
    }

    const T& operator[](size_t index) const {
        if (index >= m_size) {
            throw std::out_of_range("Index out of range");
        }
        return m_buffer[(m_tail + index) % m_capacity];
    }

    bool isEmpty() const { return m_size == 0; }
    bool isFull() const { return m_size == m_capacity; }
    size_t size() const { return m_size; }
    size_t capacity() const { return m_capacity; }

    void clear() {
        m_size = 0;
        m_head = 0;
        m_tail = 0;
    }

    std::vector<T> toVector() const {
        std::vector<T> result;
        result.reserve(m_size);

        for (size_t i = 0; i < m_size; ++i) {
            result.push_back(m_buffer[(m_tail + i) % m_capacity]);
        }

        return result;
    }

private:
    std::vector<T> m_buffer;
    size_t m_capacity;
    size_t m_size;
    size_t m_head;
    size_t m_tail;
};

#endif // CIRCULARBUFFER_H
