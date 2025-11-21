#include "Track.h"
#include <QFileInfo>
#include <QDebug>
#include <QMediaPlayer>
#include <QMediaMetaData>

// Default constructor
Track::Track()
    : m_year(0)
    , m_duration(0)
    , m_playCount(0)
{
}

// Parameterized constructor
Track::Track(const QString& filePath)
    : m_path(filePath)
    , m_year(0)
    , m_duration(0)
    , m_playCount(0)
{
    extractMetadata();
}

// Copy constructor
Track::Track(const Track& other)
    : m_path(other.m_path)
    , m_title(other.m_title)
    , m_artist(other.m_artist)
    , m_album(other.m_album)
    , m_genre(other.m_genre)
    , m_year(other.m_year)
    , m_duration(other.m_duration)
    , m_albumArt(other.m_albumArt)
    , m_playCount(other.m_playCount)
    , m_lastPlayed(other.m_lastPlayed)
{
    qDebug() << "Track copied:" << m_title;
}

// Destructor
Track::~Track()
{
    qDebug() << "Track destroyed:" << m_title;
}

// Assignment operator
Track& Track::operator=(const Track& other)
{
    if (this != &other) {
        m_path = other.m_path;
        m_title = other.m_title;
        m_artist = other.m_artist;
        m_album = other.m_album;
        m_genre = other.m_genre;
        m_year = other.m_year;
        m_duration = other.m_duration;
        m_albumArt = other.m_albumArt;
        m_playCount = other.m_playCount;
        m_lastPlayed = other.m_lastPlayed;
    }
    return *this;
}

// Equality operator
bool Track::operator==(const Track& other) const
{
    return m_path == other.m_path;
}

// Inequality operator
bool Track::operator!=(const Track& other) const
{
    return !(*this == other);
}

// Less-than operator (for sorting)
bool Track::operator<(const Track& other) const
{
    return m_title < other.m_title;
}

void Track::incrementPlayCount()
{
    m_playCount++;
}

void Track::updateLastPlayed()
{
    m_lastPlayed = QDateTime::currentDateTime();
}

void Track::extractMetadata()
{
    QFileInfo fileInfo(m_path);
    
    if (!fileInfo.exists()) {
        qWarning() << "File does not exist:" << m_path;
        return;
    }
    
    // Set default title from filename
    m_title = fileInfo.completeBaseName();
    
    // You can use TagLib or QMediaPlayer to extract metadata
    // For now, we'll use basic file info
    m_artist = "Unknown Artist";
    m_album = "Unknown Album";
}

// Friend function implementation
QDebug operator<<(QDebug debug, const Track& track)
{
    debug.nospace() << "Track(" 
                    << track.m_title << ", " 
                    << track.m_artist << ", " 
                    << track.m_album << ")";
    return debug.space();
}