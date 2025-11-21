#include "MusicLibrary.h"
#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QDebug>
#include <QFile>
#include <QDataStream>
#include <algorithm>

// Initialize static members
MusicLibrary* MusicLibrary::s_instance = nullptr;
int MusicLibrary::s_totalTracks = 0;
int MusicLibrary::s_totalAlbums = 0;
int MusicLibrary::s_totalArtists = 0;
qint64 MusicLibrary::s_totalDuration = 0;

MusicLibrary::MusicLibrary()
{
    qDebug() << "MusicLibrary singleton created";
}

MusicLibrary::~MusicLibrary()
{
    qDebug() << "MusicLibrary singleton destroyed";
}

MusicLibrary& MusicLibrary::instance()
{
    if (!s_instance) {
        s_instance = new MusicLibrary();
    }
    return *s_instance;
}

void MusicLibrary::addTrack(const Track& track)
{
    QString path = track.path();

    if (m_trackMap.find(path) != m_trackMap.end()) {
        qDebug() << "Track already exists:" << path;
        return;
    }

    m_tracks.push_back(track);
    m_trackMap[path] = track;

    // Update indices
    m_albumMap[track.album()].push_back(track);
    m_artistMap[track.artist()].push_back(track);
    m_artistSet.insert(track.artist());
    m_albumSet.insert(track.album());
    m_genreSet.insert(track.genre());

    updateStatistics();

    emit trackAdded(track);
    emit libraryChanged();
}

void MusicLibrary::removeTrack(const QString& path)
{
    auto it = m_trackMap.find(path);
    if (it == m_trackMap.end()) {
        return;
    }

    // Remove from main list
    m_tracks.erase(
        std::remove_if(m_tracks.begin(), m_tracks.end(),
                       [&path](const Track& t) { return t.path() == path; }),
        m_tracks.end()
        );

    m_trackMap.erase(it);
    rebuildIndices();
    updateStatistics();

    emit trackRemoved(path);
    emit libraryChanged();
}

bool MusicLibrary::hasTrack(const QString& path) const
{
    return m_trackMap.find(path) != m_trackMap.end();
}

Track* MusicLibrary::getTrack(const QString& path)
{
    auto it = m_trackMap.find(path);
    if (it != m_trackMap.end()) {
        return &it->second;
    }
    return nullptr;
}

std::vector<Track> MusicLibrary::getAllTracks() const
{
    return m_tracks;
}

std::vector<Track> MusicLibrary::searchTracks(const QString& query) const
{
    std::vector<Track> results;
    QString lowerQuery = query.toLower();

    for (const auto& track : m_tracks) {
        if (track.title().toLower().contains(lowerQuery) ||
            track.artist().toLower().contains(lowerQuery) ||
            track.album().toLower().contains(lowerQuery) ||
            track.genre().toLower().contains(lowerQuery)) {
            results.push_back(track);
        }
    }

    return results;
}

std::vector<Track> MusicLibrary::getTracksByArtist(const QString& artist) const
{
    auto it = m_artistMap.find(artist);
    if (it != m_artistMap.end()) {
        return it->second;
    }
    return std::vector<Track>();
}

std::vector<Track> MusicLibrary::getTracksByAlbum(const QString& album) const
{
    auto it = m_albumMap.find(album);
    if (it != m_albumMap.end()) {
        return it->second;
    }
    return std::vector<Track>();
}

std::vector<Track> MusicLibrary::getTracksByGenre(const QString& genre) const
{
    std::vector<Track> results;
    for (const auto& track : m_tracks) {
        if (track.genre() == genre) {
            results.push_back(track);
        }
    }
    return results;
}

std::map<QString, std::vector<Track>> MusicLibrary::getAlbumMap() const
{
    return m_albumMap;
}

std::set<QString> MusicLibrary::getAllArtists() const
{
    return m_artistSet;
}

std::set<QString> MusicLibrary::getAllAlbums() const
{
    return m_albumSet;
}

std::set<QString> MusicLibrary::getAllGenres() const
{
    return m_genreSet;
}

void MusicLibrary::addPlaylist(const Playlist& playlist)
{
    m_playlists.push_back(playlist);
    emit libraryChanged();
}

void MusicLibrary::removePlaylist(const QString& name)
{
    m_playlists.erase(
        std::remove_if(m_playlists.begin(), m_playlists.end(),
                       [&name](const Playlist& p) { return p.name() == name; }),
        m_playlists.end()
        );
    emit libraryChanged();
}

Playlist* MusicLibrary::getPlaylist(const QString& name)
{
    for (auto& playlist : m_playlists) {
        if (playlist.name() == name) {
            return &playlist;
        }
    }
    return nullptr;
}

std::vector<Playlist> MusicLibrary::getAllPlaylists() const
{
    return m_playlists;
}

std::vector<Track> MusicLibrary::getMostPlayed(int count) const
{
    std::vector<Track> sorted = m_tracks;
    std::sort(sorted.begin(), sorted.end(),
              [](const Track& a, const Track& b) {
                  return a.playCount() > b.playCount();
              });

    if (sorted.size() > static_cast<size_t>(count)) {
        sorted.resize(count);
    }

    return sorted;
}

std::vector<Track> MusicLibrary::getRecentlyPlayed(int count) const
{
    std::vector<Track> sorted = m_tracks;
    std::sort(sorted.begin(), sorted.end(),
              [](const Track& a, const Track& b) {
                  return a.lastPlayed() > b.lastPlayed();
              });

    if (sorted.size() > static_cast<size_t>(count)) {
        sorted.resize(count);
    }

    return sorted;
}

std::vector<Track> MusicLibrary::getRecentlyAdded(int count) const
{
    std::vector<Track> result;
    int start = std::max(0, static_cast<int>(m_tracks.size()) - count);

    for (size_t i = start; i < m_tracks.size(); ++i) {
        result.push_back(m_tracks[i]);
    }

    return result;
}

void MusicLibrary::scanDirectory(const QString& directoryPath)
{
    QStringList audioExtensions = {"*.mp3", "*.flac", "*.ogg", "*.wav", "*.m4a", "*.aac"};

    QDir dir(directoryPath);
    if (!dir.exists()) {
        qWarning() << "Directory does not exist:" << directoryPath;
        return;
    }

    QDirIterator it(directoryPath, audioExtensions, QDir::Files, QDirIterator::Subdirectories);

    int count = 0;
    int total = 0;

    // Count total files first
    QDirIterator countIt(directoryPath, audioExtensions, QDir::Files, QDirIterator::Subdirectories);
    while (countIt.hasNext()) {
        countIt.next();
        total++;
    }

    // Now scan
    while (it.hasNext()) {
        QString filePath = it.next();

        if (!hasTrack(filePath)) {
            Track track(filePath);
            addTrack(track);
        }

        count++;
        emit scanProgress(count, total);
    }

    qDebug() << "Scanned" << count << "audio files";
}

void MusicLibrary::clearLibrary()
{
    m_tracks.clear();
    m_trackMap.clear();
    m_albumMap.clear();
    m_artistMap.clear();
    m_artistSet.clear();
    m_albumSet.clear();
    m_genreSet.clear();

    updateStatistics();
    emit libraryChanged();
}

void MusicLibrary::updateStatistics()
{
    s_totalTracks = static_cast<int>(m_tracks.size());
    s_totalAlbums = static_cast<int>(m_albumSet.size());
    s_totalArtists = static_cast<int>(m_artistSet.size());

    s_totalDuration = 0;
    for (const auto& track : m_tracks) {
        s_totalDuration += track.duration();
    }
}

void MusicLibrary::rebuildIndices()
{
    m_albumMap.clear();
    m_artistMap.clear();
    m_artistSet.clear();
    m_albumSet.clear();
    m_genreSet.clear();

    for (const auto& track : m_tracks) {
        m_albumMap[track.album()].push_back(track);
        m_artistMap[track.artist()].push_back(track);
        m_artistSet.insert(track.artist());
        m_albumSet.insert(track.album());
        m_genreSet.insert(track.genre());
    }
}

bool MusicLibrary::saveToFile(const QString& filePath) const
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Cannot save library to" << filePath;
        return false;
    }

    QDataStream out(&file);
    out << static_cast<quint32>(m_tracks.size());

    for (const auto& track : m_tracks) {
        out << track.path()
        << track.title()
        << track.artist()
        << track.album()
        << track.genre()
        << track.year()
        << track.duration()
        << track.playCount();
    }

    file.close();
    return true;
}

bool MusicLibrary::loadFromFile(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Cannot load library from" << filePath;
        return false;
    }

    clearLibrary();

    QDataStream in(&file);
    quint32 trackCount;
    in >> trackCount;

    for (quint32 i = 0; i < trackCount; ++i) {
        Track track;
        QString path, title, artist, album, genre;
        int year, playCount;
        qint64 duration;

        in >> path >> title >> artist >> album >> genre >> year >> duration >> playCount;

        track = Track(path);
        track.setTitle(title);
        track.setArtist(artist);
        track.setAlbum(album);
        track.setGenre(genre);
        track.setYear(year);
        track.setDuration(duration);

        addTrack(track);
    }

    file.close();
    return true;
}
