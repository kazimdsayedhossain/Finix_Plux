#ifndef PLAYLIST_H
#define PLAYLIST_H

#include "Track.h"
#include <vector>
#include <QString>

class Playlist {
public:
    // Constructors
    Playlist();
    Playlist(const QString& name);
    Playlist(const Playlist& other);  // Copy constructor

    // Destructor
    ~Playlist();

    // Assignment operator
    Playlist& operator=(const Playlist& other);

    // Operator overloading (Concept #5)
    Track& operator[](int index);  // Access by index
    const Track& operator[](int index) const;

    Playlist operator+(const Playlist& other) const;  // Merge playlists
    Playlist& operator+=(const Track& track);  // Add track
    Playlist& operator+=(const Playlist& other);  // Merge in place

    bool operator==(const Playlist& other) const;

    // Methods
    void addTrack(const Track& track);
    void removeTrack(int index);
    void clear();
    int size() const { return static_cast<int>(m_tracks.size()); }
    bool isEmpty() const { return m_tracks.empty(); }

    QString name() const { return m_name; }
    void setName(const QString& name) { m_name = name; }

    std::vector<Track>& tracks() { return m_tracks; }
    const std::vector<Track>& tracks() const { return m_tracks; }

    // Sorting
    void sortByTitle();
    void sortByArtist();
    void sortByDuration();

    // Searching
    std::vector<Track> search(const QString& query) const;

    // Import/Export
    bool saveToM3U(const QString& filePath) const;
    bool loadFromM3U(const QString& filePath);

private:
    QString m_name;
    std::vector<Track> m_tracks;  // STL Container (Concept #15)
};

#endif // PLAYLIST_H
