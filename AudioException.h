#ifndef AUDIOEXCEPTION_H
#define AUDIOEXCEPTION_H

#include <exception>
#include <QString>
#include <string>

// Base exception class (Concept #14)
class AudioException : public std::exception {
public:
    explicit AudioException(const QString& message)
        : m_message(message.toStdString())
    {
    }

    const char* what() const noexcept override {
        return m_message.c_str();
    }

    QString message() const {
        return QString::fromStdString(m_message);
    }

private:
    std::string m_message;
};

// Specific exception types
class FileNotFoundException : public AudioException {
public:
    explicit FileNotFoundException(const QString& filePath)
        : AudioException("File not found: " + filePath)
    {
    }
};

class UnsupportedFormatException : public AudioException {
public:
    explicit UnsupportedFormatException(const QString& format)
        : AudioException("Unsupported audio format: " + format)
    {
    }
};

class DecodeException : public AudioException {
public:
    explicit DecodeException(const QString& reason)
        : AudioException("Failed to decode audio: " + reason)
    {
    }
};

class NetworkException : public AudioException {
public:
    explicit NetworkException(const QString& reason)
        : AudioException("Network error: " + reason)
    {
    }
};

class InvalidOperationException : public AudioException {
public:
    explicit InvalidOperationException(const QString& operation)
        : AudioException("Invalid operation: " + operation)
    {
    }
};

#endif // AUDIOEXCEPTION_H
