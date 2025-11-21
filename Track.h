#ifndef TRACK_H
#define TRACK_H

#include <QString>
#include <QImage>
#include <QDateTime>

class Track {
public:
    // Constructors (Concept #2)
    Track();
    Track(const QString& filePath);
    Track(const Track& other);  // Copy constructor

    // Destructor (Concept #3)
    ~Track();

    // Assignment operator (Concept #5 - Operator Overloading)
    Track& operator=(const Track& other);

    // Comparison operators (Concept #5)
    bool operator==(const Track& other) const;
    bool operator!=(const Track& other) const;
    bool operator<(const Track& other) const;  // For sorting

    // Getters
    QString path() const { return m_path; }
    QString title() const { return m_title; }
    QString artist() const { return m_artist; }
    QString album() const { return m_album; }
    QString genre() const { return m_genre; }
    int year() const { return m_year; }
    qint64 duration() const { return m_duration; }
    QImage albumArt() const { return m_albumArt; }
    int playCount() const { return m_playCount; }
    QDateTime lastPlayed() const { return m_lastPlayed; }

    // Setters
    void setTitle(const QString& title) { m_title = title; }
    void setArtist(const QString& artist) { m_artist = artist; }
    void setAlbum(const QString& album) { m_album = album; }
    void setGenre(const QString& genre) { m_genre = genre; }
    void setYear(int year) { m_year = year; }
    void setDuration(qint64 duration) { m_duration = duration; }
    void setAlbumArt(const QImage& art) { m_albumArt = art; }

    // Methods
    void incrementPlayCount();
    void updateLastPlayed();
    bool loadMetadata();

    // Friend function (Concept #6)
    friend QDebug operator<<(QDebug debug, const Track& track);

private:
    QString m_path;
    QString m_title;
    QString m_artist;
    QString m_album;
    QString m_genre;
    int m_year;
    qint64 m_duration;  // in milliseconds
    QImage m_albumArt;
    int m_playCount;
    QDateTime m_lastPlayed;

    void extractMetadata();
};

#endif // TRACK_H
