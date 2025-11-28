#include "Track.h"
#include <QFileInfo>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QEventLoop>
#include <QTimer>

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
}

Track::Track(const QString& path)
    : m_path(path)
    , m_genre("Unknown Genre")
    , m_year(0)
    , m_playCount(0)
{
    loadMetadata();
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
}

// ==================== DESTRUCTOR ====================
Track::~Track()
{
}

// ==================== STATIC FUNCTIONS ====================
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

// ==================== METHODS ====================
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
