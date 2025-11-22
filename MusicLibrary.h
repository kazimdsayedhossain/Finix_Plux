#ifndef MUSICLIBRARY_H
#define MUSICLIBRARY_H

#include "Track.h"
#include "Playlist.h"
#include <vector>
#include <map>
#include <set>
#include <QString>
#include <QObject>

class MusicLibrary : public QObject {
    Q_OBJECT

    // Add Q_PROPERTY for QML access
    Q_PROPERTY(int trackCount READ trackCount NOTIFY libraryChanged)
    Q_PROPERTY(int albumCount READ albumCount NOTIFY libraryChanged)
    Q_PROPERTY(int artistCount READ artistCount NOTIFY libraryChanged)
    Q_PROPERTY(int genreCount READ genreCount NOTIFY libraryChanged)

public:
    // Singleton instance
    static MusicLibrary& instance();

    // Static members
    static int getTotalTracks() { return s_totalTracks; }
    static int getTotalAlbums() { return s_totalAlbums; }
    static int getTotalArtists() { return s_totalArtists; }
    static qint64 getTotalDuration() { return s_totalDuration; }

    // QML-friendly getters
    int trackCount() const { return static_cast<int>(m_tracks.size()); }
    int albumCount() const { return static_cast<int>(m_albumSet.size()); }
    int artistCount() const { return static_cast<int>(m_artistSet.size()); }
    int genreCount() const { return static_cast<int>(m_genreSet.size()); }

    // Track management (make these Q_INVOKABLE for QML)
    Q_INVOKABLE void addTrack(const Track& track);
    Q_INVOKABLE void removeTrackByPath(const QString& path);
    Q_INVOKABLE bool hasTrack(const QString& path) const;

    // These can't be called from QML directly (return C++ types)
    void removeTrack(const QString& path);
    Track* getTrack(const QString& path);
    std::vector<Track> getAllTracks() const;
    std::vector<Track> searchTracks(const QString& query) const;
    std::vector<Track> getTracksByArtist(const QString& artist) const;
    std::vector<Track> getTracksByAlbum(const QString& album) const;
    std::vector<Track> getTracksByGenre(const QString& genre) const;
    std::map<QString, std::vector<Track>> getAlbumMap() const;
    std::set<QString> getAllArtists() const;
    std::set<QString> getAllAlbums() const;
    std::set<QString> getAllGenres() const;

    // Playlist management
    void addPlaylist(const Playlist& playlist);
    void removePlaylist(const QString& name);
    Playlist* getPlaylist(const QString& name);
    std::vector<Playlist> getAllPlaylists() const;

    // Statistics
    std::vector<Track> getMostPlayed(int count) const;
    std::vector<Track> getRecentlyPlayed(int count) const;
    std::vector<Track> getRecentlyAdded(int count) const;

    // Scan library (make Q_INVOKABLE for QML)
    Q_INVOKABLE void scanDirectory(const QString& directoryPath);
    Q_INVOKABLE void clearLibrary();

    // Save/Load (make Q_INVOKABLE for QML)
    Q_INVOKABLE bool saveToFile(const QString& filePath) const;
    Q_INVOKABLE bool loadFromFile(const QString& filePath);

signals:
    void trackAdded(const Track& track);
    void trackRemoved(const QString& path);
    void libraryChanged();
    void scanProgress(int current, int total);
    void scanStarted();
    void scanCompleted(int totalTracks);

private:
    // Private constructor for singleton
    MusicLibrary();
    ~MusicLibrary();

    // Delete copy constructor and assignment operator
    MusicLibrary(const MusicLibrary&) = delete;
    MusicLibrary& operator=(const MusicLibrary&) = delete;

    // Static members
    static MusicLibrary* s_instance;
    static int s_totalTracks;
    static int s_totalAlbums;
    static int s_totalArtists;
    static qint64 s_totalDuration;

    // STL Containers
    std::vector<Track> m_tracks;
    std::map<QString, Track> m_trackMap;
    std::map<QString, std::vector<Track>> m_albumMap;
    std::map<QString, std::vector<Track>> m_artistMap;
    std::set<QString> m_artistSet;
    std::set<QString> m_albumSet;
    std::set<QString> m_genreSet;
    std::vector<Playlist> m_playlists;

    void updateStatistics();
    void rebuildIndices();
};

#endif // MUSICLIBRARY_H
