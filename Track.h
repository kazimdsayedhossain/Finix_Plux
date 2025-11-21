// ===== Track.h - Complete Implementation =====

#ifndef TRACK_H
#define TRACK_H

#include <QString>
#include <QImage>
#include <QDateTime>
#include <QDebug>

/**
 * @brief Track class represents a single audio track with metadata
 *
 * Demonstrates OOP Concepts:
 * - Concept #1: Class definition with encapsulation
 * - Concept #2: Multiple constructors (default, parameterized, copy)
 * - Concept #3: Destructor for cleanup
 * - Concept #4: Access specifiers (public/private)
 * - Concept #5: Operator overloading (=, ==, !=, <)
 * - Concept #6: Friend functions for stream output
 * - Concept #8: Composition (contains QString, QImage, QDateTime)
 */
class Track {
public:
    // ==================== Constructors (Concept #2) ====================

    /**
     * @brief Default constructor - creates empty track
     */
    Track();

    /**
     * @brief Parameterized constructor - loads track from file path
     * @param filePath Path to audio file
     */
    explicit Track(const QString& filePath);

    /**
     * @brief Copy constructor - creates deep copy of track
     * @param other Track to copy from
     */
    Track(const Track& other);

    // ==================== Destructor (Concept #3) ====================

    /**
     * @brief Destructor - cleans up resources
     */
    ~Track();

    // ==================== Operator Overloading (Concept #5) ====================

    /**
     * @brief Assignment operator - assigns one track to another
     * @param other Track to assign from
     * @return Reference to this track
     */
    Track& operator=(const Track& other);

    /**
     * @brief Equality operator - compares tracks by path
     * @param other Track to compare with
     * @return true if tracks have same path
     */
    bool operator==(const Track& other) const;

    /**
     * @brief Inequality operator
     * @param other Track to compare with
     * @return true if tracks have different paths
     */
    bool operator!=(const Track& other) const;

    /**
     * @brief Less-than operator for sorting by title
     * @param other Track to compare with
     * @return true if this track's title comes before other's
     */
    bool operator<(const Track& other) const;

    // ==================== Getters (Concept #4) ====================

    QString path() const { return m_path; }
    QString title() const { return m_title; }
    QString artist() const { return m_artist; }
    QString album() const { return m_album; }
    QString genre() const { return m_genre; }
    QString albumArtist() const { return m_albumArtist; }
    QString composer() const { return m_composer; }
    QString comment() const { return m_comment; }

    int year() const { return m_year; }
    int trackNumber() const { return m_trackNumber; }
    int bitrate() const { return m_bitrate; }
    int sampleRate() const { return m_sampleRate; }
    int channels() const { return m_channels; }

    qint64 duration() const { return m_duration; }
    qint64 fileSize() const { return m_fileSize; }

    QImage albumArt() const { return m_albumArt; }
    QString albumArtPath() const { return m_albumArtPath; }

    int playCount() const { return m_playCount; }
    QDateTime lastPlayed() const { return m_lastPlayed; }
    QDateTime dateAdded() const { return m_dateAdded; }
    QDateTime dateModified() const { return m_dateModified; }

    bool isValid() const { return m_isValid; }
    bool hasAlbumArt() const { return !m_albumArt.isNull(); }

    // ==================== Setters (Concept #4) ====================

    void setPath(const QString& path) { m_path = path; }
    void setTitle(const QString& title) { m_title = title; }
    void setArtist(const QString& artist) { m_artist = artist; }
    void setAlbum(const QString& album) { m_album = album; }
    void setGenre(const QString& genre) { m_genre = genre; }
    void setAlbumArtist(const QString& albumArtist) { m_albumArtist = albumArtist; }
    void setComposer(const QString& composer) { m_composer = composer; }
    void setComment(const QString& comment) { m_comment = comment; }

    void setYear(int year) { m_year = year; }
    void setTrackNumber(int trackNumber) { m_trackNumber = trackNumber; }
    void setBitrate(int bitrate) { m_bitrate = bitrate; }
    void setSampleRate(int sampleRate) { m_sampleRate = sampleRate; }
    void setChannels(int channels) { m_channels = channels; }

    void setDuration(qint64 duration) { m_duration = duration; }
    void setFileSize(qint64 fileSize) { m_fileSize = fileSize; }

    void setAlbumArt(const QImage& art);
    void setAlbumArtPath(const QString& path) { m_albumArtPath = path; }

    void setPlayCount(int count) { m_playCount = count; }
    void setLastPlayed(const QDateTime& dateTime) { m_lastPlayed = dateTime; }
    void setDateAdded(const QDateTime& dateTime) { m_dateAdded = dateTime; }
    void setDateModified(const QDateTime& dateTime) { m_dateModified = dateTime; }

    // ==================== Public Methods ====================

    /**
     * @brief Increment play count and update last played time
     */
    void incrementPlayCount();

    /**
     * @brief Update last played timestamp to current time
     */
    void updateLastPlayed();

    /**
     * @brief Load metadata from audio file using Qt's QMediaPlayer
     * @return true if metadata loaded successfully
     */
    bool loadMetadata();

    /**
     * @brief Reload metadata from file
     * @return true if successful
     */
    bool reloadMetadata();

    /**
     * @brief Extract album art from audio file
     * @return true if album art found and extracted
     */
    bool extractAlbumArt();

    /**
     * @brief Save album art to cache directory
     * @param cachePath Directory to save album art
     * @return Path to saved album art file, empty string on failure
     */
    QString saveAlbumArt(const QString& cachePath);

    /**
     * @brief Get file extension (mp3, flac, etc.)
     * @return File extension in lowercase
     */
    QString fileExtension() const;

    /**
     * @brief Get formatted duration as string (mm:ss)
     * @return Duration string
     */
    QString formattedDuration() const;

    /**
     * @brief Get formatted file size as string (KB, MB, GB)
     * @return File size string
     */
    QString formattedFileSize() const;

    /**
     * @brief Check if file exists on disk
     * @return true if file exists
     */
    bool fileExists() const;

    /**
     * @brief Get file info as debug string
     * @return Debug information string
     */
    QString debugInfo() const;

    // ==================== Friend Functions (Concept #6) ====================

    /**
     * @brief Stream output operator for debugging
     * @param debug QDebug stream
     * @param track Track to output
     * @return QDebug reference
     */
    friend QDebug operator<<(QDebug debug, const Track& track);

private:
    // ==================== Private Methods ====================

    /**
     * @brief Extract basic metadata from file (filename, size, dates)
     */
    void extractBasicMetadata();

    /**
     * @brief Extract detailed metadata using QMediaPlayer
     */
    void extractDetailedMetadata();

    /**
     * @brief Sanitize metadata string (trim, remove nulls)
     * @param str String to sanitize
     * @return Sanitized string
     */
    QString sanitizeString(const QString& str) const;

    // ==================== Member Variables (Concept #4 - Encapsulation) ====================

    // File information
    QString m_path;                    // Full path to audio file
    QString m_title;                   // Track title
    QString m_artist;                  // Primary artist
    QString m_album;                   // Album name
    QString m_genre;                   // Genre
    QString m_albumArtist;             // Album artist (may differ from track artist)
    QString m_composer;                // Composer
    QString m_comment;                 // Comments/notes

    // Numeric metadata
    int m_year;                        // Release year
    int m_trackNumber;                 // Track number on album
    int m_bitrate;                     // Bitrate in kbps
    int m_sampleRate;                  // Sample rate in Hz
    int m_channels;                    // Number of audio channels

    // Duration and size
    qint64 m_duration;                 // Duration in milliseconds
    qint64 m_fileSize;                 // File size in bytes

    // Album art
    QImage m_albumArt;                 // Album art image
    QString m_albumArtPath;            // Path to cached album art

    // Playback statistics
    int m_playCount;                   // Number of times played
    QDateTime m_lastPlayed;            // Last played timestamp
    QDateTime m_dateAdded;             // When added to library
    QDateTime m_dateModified;          // File last modified date

    // Validation
    bool m_isValid;                    // Whether track is valid and loadable
};

#endif // TRACK_H
