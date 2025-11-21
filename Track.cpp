// ===== Track.cpp - Complete Implementation =====

#include "Track.h"
#include <QFileInfo>
#include <QDir>
#include <QMediaPlayer>
#include <QMediaMetaData>
#include <QAudioOutput>
#include <QCoreApplication>
#include <QEventLoop>
#include <QTimer>
#include <QBuffer>
#include <QCryptographicHash>

// ==================== Constructors ====================

Track::Track()
    : m_year(0)
    , m_trackNumber(0)
    , m_bitrate(0)
    , m_sampleRate(0)
    , m_channels(0)
    , m_duration(0)
    , m_fileSize(0)
    , m_playCount(0)
    , m_isValid(false)
{
    m_dateAdded = QDateTime::currentDateTime();
    qDebug() << "Track: Default constructor called";
}

Track::Track(const QString& filePath)
    : m_path(filePath)
    , m_year(0)
    , m_trackNumber(0)
    , m_bitrate(0)
    , m_sampleRate(0)
    , m_channels(0)
    , m_duration(0)
    , m_fileSize(0)
    , m_playCount(0)
    , m_isValid(false)
{
    m_dateAdded = QDateTime::currentDateTime();

    // Validate file exists
    if (!fileExists()) {
        qWarning() << "Track: File does not exist:" << filePath;
        return;
    }

    // Extract all metadata
    extractBasicMetadata();
    extractDetailedMetadata();

    m_isValid = true;

    qDebug() << "Track: Loaded" << m_title << "by" << m_artist;
}

Track::Track(const Track& other)
    : m_path(other.m_path)
    , m_title(other.m_title)
    , m_artist(other.m_artist)
    , m_album(other.m_album)
    , m_genre(other.m_genre)
    , m_albumArtist(other.m_albumArtist)
    , m_composer(other.m_composer)
    , m_comment(other.m_comment)
    , m_year(other.m_year)
    , m_trackNumber(other.m_trackNumber)
    , m_bitrate(other.m_bitrate)
    , m_sampleRate(other.m_sampleRate)
    , m_channels(other.m_channels)
    , m_duration(other.m_duration)
    , m_fileSize(other.m_fileSize)
    , m_albumArt(other.m_albumArt)
    , m_albumArtPath(other.m_albumArtPath)
    , m_playCount(other.m_playCount)
    , m_lastPlayed(other.m_lastPlayed)
    , m_dateAdded(other.m_dateAdded)
    , m_dateModified(other.m_dateModified)
    , m_isValid(other.m_isValid)
{
    qDebug() << "Track: Copy constructor called for" << m_title;
}

Track::~Track()
{
    // Cleanup if needed
    // QImage and QString have automatic memory management
    qDebug() << "Track: Destructor called for" << m_title;
}

// ==================== Operator Overloading ====================

Track& Track::operator=(const Track& other)
{
    if (this != &other) {
        m_path = other.m_path;
        m_title = other.m_title;
        m_artist = other.m_artist;
        m_album = other.m_album;
        m_genre = other.m_genre;
        m_albumArtist = other.m_albumArtist;
        m_composer = other.m_composer;
        m_comment = other.m_comment;
        m_year = other.m_year;
        m_trackNumber = other.m_trackNumber;
        m_bitrate = other.m_bitrate;
        m_sampleRate = other.m_sampleRate;
        m_channels = other.m_channels;
        m_duration = other.m_duration;
        m_fileSize = other.m_fileSize;
        m_albumArt = other.m_albumArt;
        m_albumArtPath = other.m_albumArtPath;
        m_playCount = other.m_playCount;
        m_lastPlayed = other.m_lastPlayed;
        m_dateAdded = other.m_dateAdded;
        m_dateModified = other.m_dateModified;
        m_isValid = other.m_isValid;

        qDebug() << "Track: Assignment operator called";
    }
    return *this;
}

bool Track::operator==(const Track& other) const
{
    return m_path == other.m_path;
}

bool Track::operator!=(const Track& other) const
{
    return !(*this == other);
}

bool Track::operator<(const Track& other) const
{
    return m_title.toLower() < other.m_title.toLower();
}

// ==================== Setters ====================

void Track::setAlbumArt(const QImage& art)
{
    m_albumArt = art;
    qDebug() << "Track: Album art set for" << m_title << "- Size:" << art.size();
}

// ==================== Public Methods ====================

void Track::incrementPlayCount()
{
    m_playCount++;
    qDebug() << "Track: Play count incremented to" << m_playCount << "for" << m_title;
}

void Track::updateLastPlayed()
{
    m_lastPlayed = QDateTime::currentDateTime();
    qDebug() << "Track: Last played updated for" << m_title;
}

bool Track::loadMetadata()
{
    if (!fileExists()) {
        qWarning() << "Track: Cannot load metadata - file does not exist:" << m_path;
        return false;
    }

    extractBasicMetadata();
    extractDetailedMetadata();

    m_isValid = true;
    return true;
}

bool Track::reloadMetadata()
{
    qDebug() << "Track: Reloading metadata for" << m_path;
    return loadMetadata();
}

bool Track::extractAlbumArt()
{
    if (!fileExists()) {
        return false;
    }

    // Album art is extracted in extractDetailedMetadata()
    // This method can be used to force re-extraction
    qDebug() << "Track: Extracting album art for" << m_title;

    QMediaPlayer player;
    QAudioOutput audioOutput;
    player.setAudioOutput(&audioOutput);
    player.setSource(QUrl::fromLocalFile(m_path));

    // Wait for metadata to load
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    timer.setInterval(3000); // 3 second timeout

    bool metadataLoaded = false;

    QObject::connect(&player, &QMediaPlayer::metaDataChanged, [&]() {
        metadataLoaded = true;
        loop.quit();
    });

    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    timer.start();
    loop.exec();

    if (!metadataLoaded) {
        qWarning() << "Track: Timeout extracting album art for" << m_title;
        return false;
    }

    // Try to get thumbnail/cover art
    QVariant coverArt = player.metaData().value(QMediaMetaData::ThumbnailImage);
    if (!coverArt.isNull() && coverArt.canConvert<QImage>()) {
        m_albumArt = coverArt.value<QImage>();
        qDebug() << "Track: Album art extracted for" << m_title;
        return true;
    }

    // Try alternative key
    coverArt = player.metaData().value(QMediaMetaData::CoverArtImage);
    if (!coverArt.isNull() && coverArt.canConvert<QImage>()) {
        m_albumArt = coverArt.value<QImage>();
        qDebug() << "Track: Album art extracted (alt) for" << m_title;
        return true;
    }

    qDebug() << "Track: No album art found for" << m_title;
    return false;
}

QString Track::saveAlbumArt(const QString& cachePath)
{
    if (m_albumArt.isNull()) {
        qWarning() << "Track: No album art to save for" << m_title;
        return QString();
    }

    // Create cache directory if it doesn't exist
    QDir cacheDir(cachePath);
    if (!cacheDir.exists()) {
        cacheDir.mkpath(".");
    }

    // Generate unique filename using MD5 hash of path
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(m_path.toUtf8());
    QString filename = QString(hash.result().toHex()) + ".jpg";
    QString fullPath = cacheDir.filePath(filename);

    // Save image
    if (m_albumArt.save(fullPath, "JPG", 90)) {
        m_albumArtPath = fullPath;
        qDebug() << "Track: Album art saved to" << fullPath;
        return fullPath;
    }

    qWarning() << "Track: Failed to save album art for" << m_title;
    return QString();
}

QString Track::fileExtension() const
{
    QFileInfo fileInfo(m_path);
    return fileInfo.suffix().toLower();
}

QString Track::formattedDuration() const
{
    if (m_duration <= 0) {
        return "0:00";
    }

    qint64 totalSeconds = m_duration / 1000;
    qint64 hours = totalSeconds / 3600;
    qint64 minutes = (totalSeconds % 3600) / 60;
    qint64 seconds = totalSeconds % 60;

    if (hours > 0) {
        return QString("%1:%2:%3")
        .arg(hours)
            .arg(minutes, 2, 10, QChar('0'))
            .arg(seconds, 2, 10, QChar('0'));
    } else {
        return QString("%1:%2")
        .arg(minutes)
            .arg(seconds, 2, 10, QChar('0'));
    }
}

QString Track::formattedFileSize() const
{
    if (m_fileSize == 0) {
        return "0 B";
    }

    double size = m_fileSize;
    QStringList units = {"B", "KB", "MB", "GB", "TB"};
    int unitIndex = 0;

    while (size >= 1024.0 && unitIndex < units.size() - 1) {
        size /= 1024.0;
        unitIndex++;
    }

    return QString("%1 %2").arg(size, 0, 'f', 2).arg(units[unitIndex]);
}

bool Track::fileExists() const
{
    QFileInfo fileInfo(m_path);
    return fileInfo.exists() && fileInfo.isFile();
}

QString Track::debugInfo() const
{
    QString info;
    info += "Track Debug Information:\n";
    info += "========================\n";
    info += QString("Path: %1\n").arg(m_path);
    info += QString("Title: %1\n").arg(m_title);
    info += QString("Artist: %1\n").arg(m_artist);
    info += QString("Album: %1\n").arg(m_album);
    info += QString("Genre: %1\n").arg(m_genre);
    info += QString("Year: %1\n").arg(m_year);
    info += QString("Track #: %1\n").arg(m_trackNumber);
    info += QString("Duration: %1 (%2)\n").arg(m_duration).arg(formattedDuration());
    info += QString("File Size: %1 (%2)\n").arg(m_fileSize).arg(formattedFileSize());
    info += QString("Bitrate: %1 kbps\n").arg(m_bitrate);
    info += QString("Sample Rate: %1 Hz\n").arg(m_sampleRate);
    info += QString("Channels: %1\n").arg(m_channels);
    info += QString("Play Count: %1\n").arg(m_playCount);
    info += QString("Has Album Art: %1\n").arg(hasAlbumArt() ? "Yes" : "No");
    info += QString("Valid: %1\n").arg(m_isValid ? "Yes" : "No");
    return info;
}

// ==================== Private Methods ====================

void Track::extractBasicMetadata()
{
    QFileInfo fileInfo(m_path);

    if (!fileInfo.exists()) {
        qWarning() << "Track: File does not exist:" << m_path;
        return;
    }

    // Get file size
    m_fileSize = fileInfo.size();

    // Get modification date
    m_dateModified = fileInfo.lastModified();

    // Set default title from filename
    m_title = fileInfo.completeBaseName();

    // Try to parse filename for artist - title format
    QString baseName = fileInfo.completeBaseName();
    if (baseName.contains(" - ")) {
        QStringList parts = baseName.split(" - ");
        if (parts.size() >= 2) {
            m_artist = parts[0].trimmed();
            m_title = parts.mid(1).join(" - ").trimmed();
        }
    }

    // Set default values if empty
    if (m_artist.isEmpty()) {
        m_artist = "Unknown Artist";
    }

    if (m_album.isEmpty()) {
        m_album = "Unknown Album";
    }

    qDebug() << "Track: Basic metadata extracted for" << m_title;
}

void Track::extractDetailedMetadata()
{
    QMediaPlayer player;
    QAudioOutput audioOutput;
    player.setAudioOutput(&audioOutput);
    player.setSource(QUrl::fromLocalFile(m_path));

    // Wait for metadata to load
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    timer.setInterval(3000); // 3 second timeout

    bool metadataLoaded = false;

    QObject::connect(&player, &QMediaPlayer::metaDataChanged, [&]() {
        metadataLoaded = true;
        loop.quit();
    });

    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    timer.start();
    loop.exec();

    if (!metadataLoaded) {
        qWarning() << "Track: Timeout loading detailed metadata for" << m_path;
        return;
    }

    // Extract metadata from QMediaPlayer
    QMediaMetaData metadata = player.metaData();

    // Title
    QString title = metadata.stringValue(QMediaMetaData::Title);
    if (!title.isEmpty()) {
        m_title = sanitizeString(title);
    }

    // Artist
    QString artist = metadata.stringValue(QMediaMetaData::ContributingArtist);
    if (artist.isEmpty()) {
        artist = metadata.stringValue(QMediaMetaData::Author);
    }
    if (!artist.isEmpty()) {
        m_artist = sanitizeString(artist);
    }

    // Album
    QString album = metadata.stringValue(QMediaMetaData::AlbumTitle);
    if (!album.isEmpty()) {
        m_album = sanitizeString(album);
    }

    // Album Artist
    QString albumArtist = metadata.stringValue(QMediaMetaData::AlbumArtist);
    if (!albumArtist.isEmpty()) {
        m_albumArtist = sanitizeString(albumArtist);
    }

    // Genre
    QString genre = metadata.stringValue(QMediaMetaData::Genre);
    if (!genre.isEmpty()) {
        m_genre = sanitizeString(genre);
    }

    // Composer
    QString composer = metadata.stringValue(QMediaMetaData::Composer);
    if (!composer.isEmpty()) {
        m_composer = sanitizeString(composer);
    }

    // Comment
    QString comment = metadata.stringValue(QMediaMetaData::Comment);
    if (!comment.isEmpty()) {
        m_comment = sanitizeString(comment);
    }

    // Year
    QVariant yearVariant = metadata.value(QMediaMetaData::Date);
    if (yearVariant.isValid()) {
        if (yearVariant.canConvert<QDateTime>()) {
            m_year = yearVariant.toDateTime().date().year();
        } else if (yearVariant.canConvert<QString>()) {
            bool ok;
            int year = yearVariant.toString().toInt(&ok);
            if (ok) {
                m_year = year;
            }
        }
    }

    // Track Number
    QVariant trackNumVariant = metadata.value(QMediaMetaData::TrackNumber);
    if (trackNumVariant.isValid() && trackNumVariant.canConvert<int>()) {
        m_trackNumber = trackNumVariant.toInt();
    }

    // Duration
    m_duration = player.duration();

    // Audio information
    QVariant bitrateVariant = metadata.value(QMediaMetaData::AudioBitRate);
    if (bitrateVariant.isValid() && bitrateVariant.canConvert<int>()) {
        m_bitrate = bitrateVariant.toInt() / 1000; // Convert to kbps
    }

    // Try to get album art
    QVariant coverArt = metadata.value(QMediaMetaData::ThumbnailImage);
    if (!coverArt.isNull() && coverArt.canConvert<QImage>()) {
        m_albumArt = coverArt.value<QImage>();
        qDebug() << "Track: Album art loaded for" << m_title;
    } else {
        // Try alternative key
        coverArt = metadata.value(QMediaMetaData::CoverArtImage);
        if (!coverArt.isNull() && coverArt.canConvert<QImage>()) {
            m_albumArt = coverArt.value<QImage>();
            qDebug() << "Track: Album art loaded (alt) for" << m_title;
        }
    }

    qDebug() << "Track: Detailed metadata extracted for" << m_title;
}

QString Track::sanitizeString(const QString& str) const
{
    QString result = str.trimmed();

    // Remove null characters
    result.remove(QChar('\0'));

    // Remove excessive whitespace
    result = result.simplified();

    return result;
}

// ==================== Friend Functions ====================

QDebug operator<<(QDebug debug, const Track& track)
{
    QDebugStateSaver saver(debug);
    debug.nospace() << "Track("
                    << "title=" << track.m_title
                    << ", artist=" << track.m_artist
                    << ", album=" << track.m_album
                    << ", duration=" << track.formattedDuration()
                    << ", year=" << track.m_year
                    << ")";
    return debug;
}
