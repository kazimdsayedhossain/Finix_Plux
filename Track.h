#ifndef TRACK_H
#define TRACK_H

#include <QString>
#include <QDateTime>

class Track
{
public:
    // Constructors
    Track();
    explicit Track(const QString& path);
    Track(const QString& path, const QString& title, const QString& artist);

    // Destructor
    ~Track();

    // Static utility functions
    static bool isValidAudioFile(const QString& path);
    static QStringList getSupportedFormats();
    static QString formatDuration(qint64 milliseconds);

    // Getters
    QString path() const { return m_path; }
    QString title() const { return m_title; }
    QString artist() const { return m_artist; }
    QString album() const { return m_album; }
    QString genre() const { return m_genre; }
    int year() const { return m_year; }
    qint64 duration() const { return m_duration; }
    int playCount() const { return m_playCount; }
    QDateTime lastPlayed() const { return m_lastPlayed; }

    // Setters
    void setTitle(const QString& title) { m_title = title; }
    void setArtist(const QString& artist) { m_artist = artist; }
    void setAlbum(const QString& album) { m_album = album; }
    void setGenre(const QString& genre) { m_genre = genre; }
    void setYear(int year) { m_year = year; }
    void setDuration(qint64 durationMs) { m_duration = durationMs; }

    // Methods
    void incrementPlayCount();
    void updateLastPlayed();

private:
    QString m_path;
    QString m_title;
    QString m_artist;
    QString m_album;
    QString m_genre;
    int m_year = 0;
    qint64 m_duration = 0;
    int m_playCount = 0;
    QDateTime m_lastPlayed;

    void loadMetadata();
};

#endif // TRACK_H
