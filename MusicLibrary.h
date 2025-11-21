#ifndef MUSICLIBRARY_H
#define MUSICLIBRARY_H

#include "Track.h"
#include "Playlist.h"
#include <vector>
#include <map>
#include <set>
#include <QString>
#include <QObject>

// Singleton pattern with static members (Concept #7)
class MusicLibrary : public QObject {
    Q_OBJECT

public:
    // Singleton instance (Concept #7 - Static Members)
    static MusicLibrary& instance();

    // Static members (Concept #7)
    static int getTotalTracks() { return s_totalTracks; }
    static int getTotalAlbums() { return s_totalAlbums; }
    static int getTotalArtists() { return s_totalArtists; }
    static qint64 getTotalDuration() { return s_totalDuration; }

    // Track management
    void addTrack(const Track& track);
    void removeTrack(const QString& path);
    bool hasTrack(const QString& path) const;
    Track* getTrack(const QString& path);

    // Search and filter using STL containers (Concept #15)
    std::vector<Track> getAllTracks() const;
    std::vector<Track> searchTracks(const QString& query) const;
    std::vector<Track> getTracksByArtist(const QString& artist) const;
    std::vector<Track> getTracksByAlbum(const QString& album) const;
    std::vector<Track> getTracksByGenre(const QString& genre) const;

    // Album and artist management
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

    // Scan library
    void scanDirectory(const QString& directoryPath);
    void clearLibrary();

    // Save/Load
    bool saveToFile(const QString& filePath) const;
    bool loadFromFile(const QString& filePath);

signals:
    void trackAdded(const Track& track);
    void trackRemoved(const QString& path);
    void libraryChanged();
    void scanProgress(int current, int total);

private:
    // Private constructor for singleton
    MusicLibrary();
    ~MusicLibrary();

    // Delete copy constructor and assignment operator
    MusicLibrary(const MusicLibrary&) = delete;
    MusicLibrary& operator=(const MusicLibrary&) = delete;

    // Static members (Concept #7)
    static MusicLibrary* s_instance;
    static int s_totalTracks;
    static int s_totalAlbums;
    static int s_totalArtists;
    static qint64 s_totalDuration;

    // STL Containers (Concept #15)
    std::vector<Track> m_tracks;
    std::map<QString, Track> m_trackMap;  // path -> track
    std::map<QString, std::vector<Track>> m_albumMap;  // album -> tracks
    std::map<QString, std::vector<Track>> m_artistMap;  // artist -> tracks
    std::set<QString> m_artistSet;
    std::set<QString> m_albumSet;
    std::set<QString> m_genreSet;

    std::vector<Playlist> m_playlists;

    void updateStatistics();
    void rebuildIndices();
};

#endif // MUSICLIBRARY_H
