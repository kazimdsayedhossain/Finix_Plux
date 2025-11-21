#include "Playlist.h"
#include <algorithm>
#include <QFile>
#include <QTextStream>
#include <QDebug>

Playlist::Playlist()
    : m_name("Untitled Playlist")
{
}

Playlist::Playlist(const QString& name)
    : m_name(name)
{
}

Playlist::Playlist(const Playlist& other)
    : m_name(other.m_name)
    , m_tracks(other.m_tracks)
{
    qDebug() << "Playlist copied:" << m_name;
}

Playlist::~Playlist()
{
    qDebug() << "Playlist destroyed:" << m_name;
}

Playlist& Playlist::operator=(const Playlist& other)
{
    if (this != &other) {
        m_name = other.m_name;
        m_tracks = other.m_tracks;
    }
    return *this;
}

Track& Playlist::operator[](int index)
{
    return m_tracks[index];
}

const Track& Playlist::operator[](int index) const
{
    return m_tracks[index];
}

// Merge two playlists
Playlist Playlist::operator+(const Playlist& other) const
{
    Playlist result(*this);
    result.m_tracks.insert(result.m_tracks.end(), 
                          other.m_tracks.begin(), 
                          other.m_tracks.end());
    return result;
}

// Add track to playlist
Playlist& Playlist::operator+=(const Track& track)
{
    addTrack(track);
    return *this;
}

// Merge another playlist
Playlist& Playlist::operator+=(const Playlist& other)
{
    m_tracks.insert(m_tracks.end(), 
                   other.m_tracks.begin(), 
                   other.m_tracks.end());
    return *this;
}

bool Playlist::operator==(const Playlist& other) const
{
    return m_name == other.m_name && m_tracks == other.m_tracks;
}

void Playlist::addTrack(const Track& track)
{
    m_tracks.push_back(track);
}

void Playlist::removeTrack(int index)
{
    if (index >= 0 && index < static_cast<int>(m_tracks.size())) {
        m_tracks.erase(m_tracks.begin() + index);
    }
}

void Playlist::clear()
{
    m_tracks.clear();
}

void Playlist::sortByTitle()
{
    std::sort(m_tracks.begin(), m_tracks.end(), 
              [](const Track& a, const Track& b) {
        return a.title() < b.title();
    });
}

void Playlist::sortByArtist()
{
    std::sort(m_tracks.begin(), m_tracks.end(), 
              [](const Track& a, const Track& b) {
        return a.artist() < b.artist();
    });
}

void Playlist::sortByDuration()
{
    std::sort(m_tracks.begin(), m_tracks.end(), 
              [](const Track& a, const Track& b) {
        return a.duration() < b.duration();
    });
}

std::vector<Track> Playlist::search(const QString& query) const
{
    std::vector<Track> results;
    QString lowerQuery = query.toLower();
    
    for (const auto& track : m_tracks) {
        if (track.title().toLower().contains(lowerQuery) ||
            track.artist().toLower().contains(lowerQuery) ||
            track.album().toLower().contains(lowerQuery)) {
            results.push_back(track);
        }
    }
    
    return results;
}

bool Playlist::saveToM3U(const QString& filePath) const
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Could not open file for writing:" << filePath;
        return false;
    }
    
    QTextStream out(&file);
    out << "#EXTM3U\n";
    
    for (const auto& track : m_tracks) {
        out << "#EXTINF:" << track.duration() / 1000 << "," 
            << track.artist() << " - " << track.title() << "\n";
        out << track.path() << "\n";
    }
    
    file.close();
    return true;
}

bool Playlist::loadFromM3U(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Could not open file for reading:" << filePath;
        return false;
    }
    
    QTextStream in(&file);
    m_tracks.clear();
    
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        
        if (line.startsWith("#EXTINF:")) {
            // Read next line for file path
            if (!in.atEnd()) {
                QString path = in.readLine().trimmed();
                Track track(path);
                m_tracks.push_back(track);
            }
        }
    }
    
    file.close();
    return true;
}