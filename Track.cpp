// Track.cpp - Add year support in constructors and methods
#include "Track.h"
#include <QFileInfo>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QEventLoop>
#include <QTimer>

// ==================== STATIC MEMBER INITIALIZATION ====================
int Track::s_totalTracksCreated = 0;

// ==================== CONSTRUCTORS ====================
Track::Track()
    : m_path("")
    , m_title("Unknown")
    , m_artist("Unknown Artist")
    , m_album("Unknown Album")
    , m_genre("Unknown Genre")
    , m_year(0)
    , m_duration(0)
    , m_playCount(0)
{
    s_totalTracksCreated++;
    qDebug() << "Track created (empty). Total tracks:" << s_totalTracksCreated;
}

Track::Track(const QString& path)
    : m_path(path)
    , m_genre("Unknown Genre")
    , m_year(0)
    , m_playCount(0)
{
    s_totalTracksCreated++;
    loadMetadata();
    qDebug() << "Track created from path:" << path << "Total tracks:" << s_totalTracksCreated;
}

Track::Track(const QString& path, const QString& title, const QString& artist)
    : m_path(path)
    , m_title(title)
    , m_artist(artist)
    , m_album("Unknown Album")
    , m_genre("Unknown Genre")
    , m_year(0)
    , m_duration(0)
    , m_playCount(0)
{
    s_totalTracksCreated++;
    qDebug() << "Track created with metadata. Total tracks:" << s_totalTracksCreated;
}

// ==================== DESTRUCTOR ====================
Track::~Track()
{
    s_totalTracksCreated--;
    qDebug() << "Track destroyed:" << m_title << "Remaining tracks:" << s_totalTracksCreated;
}

// ==================== FUNCTION OVERLOADING IMPLEMENTATION ====================

void Track::setDuration(qint64 durationMs)
{
    m_duration = durationMs;
    qDebug() << "Duration set:" << durationMs << "ms";
}

void Track::setDuration(int minutes, int seconds)
{
    m_duration = (minutes * 60 + seconds) * 1000;
    qDebug() << "Duration set:" << minutes << "min" << seconds << "sec";
}

void Track::setDuration(int hours, int minutes, int seconds)
{
    m_duration = ((hours * 3600) + (minutes * 60) + seconds) * 1000;
    qDebug() << "Duration set:" << hours << "h" << minutes << "m" << seconds << "s";
}

void Track::play()
{
    qDebug() << "Playing track:" << m_title << "at default volume";
    incrementPlayCount();
}

void Track::play(qreal volume)
{
    qDebug() << "Playing track:" << m_title << "at volume:" << volume;
    incrementPlayCount();
}

void Track::play(qreal volume, qint64 startPosition)
{
    qDebug() << "Playing track:" << m_title
             << "at volume:" << volume
             << "from position:" << startPosition;
    incrementPlayCount();
}

// ==================== OPERATOR OVERLOADING IMPLEMENTATION ====================

bool Track::operator==(const Track& other) const
{
    return m_title == other.m_title && m_artist == other.m_artist;
}

bool Track::operator!=(const Track& other) const
{
    return !(*this == other);
}

bool Track::operator<(const Track& other) const
{
    return m_title < other.m_title;
}

bool Track::operator>(const Track& other) const
{
    return m_title > other.m_title;
}

Track& Track::operator=(const Track& other)
{
    if (this != &other) {
        m_path = other.m_path;
        m_title = other.m_title;
        m_artist = other.m_artist;
        m_album = other.m_album;
        m_genre = other.m_genre;
        m_year = other.m_year;  // Copy year
        m_duration = other.m_duration;
        m_playCount = other.m_playCount;
        m_lastPlayed = other.m_lastPlayed;
    }
    return *this;
}

QDebug operator<<(QDebug debug, const Track& track)
{
    debug.nospace() << "Track("
                    << track.m_title << ", "
                    << track.m_artist << ", "
                    << track.m_year << ", "  // Include year
                    << track.formatDuration(track.m_duration) << ")";
    return debug.space();
}

QString Track::operator+(const Track& other) const
{
    return m_title + " & " + other.m_title;
}

Track& Track::operator++()
{
    incrementPlayCount();
    return *this;
}

Track Track::operator++(int)
{
    Track temp(*this);
    incrementPlayCount();
    return temp;
}

// ==================== STATIC MEMBER FUNCTIONS ====================

int Track::getTotalTracksCreated()
{
    return s_totalTracksCreated;
}

bool Track::isValidAudioFile(const QString& path)
{
    QStringList validExtensions = {"mp3", "flac", "ogg", "wav", "m4a", "aac", "wma"};
    QFileInfo fileInfo(path);

    if (!fileInfo.exists()) {
        return false;
    }

    QString extension = fileInfo.suffix().toLower();
    return validExtensions.contains(extension);
}

QStringList Track::getSupportedFormats()
{
    return {"MP3", "FLAC", "OGG", "WAV", "M4A", "AAC", "WMA"};
}

QString Track::formatDuration(qint64 milliseconds)
{
    if (milliseconds <= 0) return "0:00";

    qint64 totalSeconds = milliseconds / 1000;
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

// ==================== FRIEND FUNCTION IMPLEMENTATION ====================

void printTrackDetails(const Track& track)
{
    qDebug() << "========== Track Details ==========";
    qDebug() << "Path:" << track.m_path;
    qDebug() << "Title:" << track.m_title;
    qDebug() << "Artist:" << track.m_artist;
    qDebug() << "Album:" << track.m_album;
    qDebug() << "Genre:" << track.m_genre;
    qDebug() << "Year:" << track.m_year;  // Include year
    qDebug() << "Duration:" << Track::formatDuration(track.m_duration);
    qDebug() << "Play Count:" << track.m_playCount;
    qDebug() << "Last Played:" << track.m_lastPlayed.toString();
    qDebug() << "===================================";
}

// ==================== EXISTING METHODS ====================

void Track::incrementPlayCount()
{
    m_playCount++;
    updateLastPlayed();
}

void Track::updateLastPlayed()
{
    m_lastPlayed = QDateTime::currentDateTime();
}

void Track::loadMetadata()
{
    if (m_path.isEmpty()) return;

    QFileInfo fileInfo(m_path);
    if (!fileInfo.exists()) {
        qWarning() << "File does not exist:" << m_path;
        m_title = "Unknown";
        m_artist = "Unknown Artist";
        m_album = "Unknown Album";
        m_genre = "Unknown Genre";
        m_year = 0;
        return;
    }

    // Use filename as title if no metadata available
    m_title = fileInfo.baseName();
    m_artist = "Unknown Artist";
    m_album = "Unknown Album";
    m_genre = "Unknown Genre";
    m_year = 0;

    // Try to get duration using QMediaPlayer
    QMediaPlayer tempPlayer;
    QAudioOutput tempOutput;
    tempPlayer.setAudioOutput(&tempOutput);

    QEventLoop loop;
    QTimer timeoutTimer;
    timeoutTimer.setSingleShot(true);
    timeoutTimer.setInterval(2000); // 2 second timeout

    bool durationLoaded = false;

    QObject::connect(&tempPlayer, &QMediaPlayer::durationChanged, [&](qint64 duration) {
        if (duration > 0) {
            m_duration = duration;
            durationLoaded = true;
            loop.quit();
        }
    });

    QObject::connect(&timeoutTimer, &QTimer::timeout, [&]() {
        loop.quit();
    });

    tempPlayer.setSource(QUrl::fromLocalFile(m_path));
    timeoutTimer.start();

    // Wait for duration or timeout
    if (!durationLoaded) {
        loop.exec();
    }

    if (m_duration == 0) {
        qDebug() << "Could not determine duration for:" << m_path;
    } else {
        qDebug() << "Loaded metadata for:" << m_title << "Duration:" << formatDuration(m_duration);
    }
}
