#include "AudioController.h"
#include "AudioException.h"
#include "AudioUtils.h"
#include <QUrl>
#include <QFileInfo>
#include <QProcess>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QRegularExpression>
#include <QFile>

// ==================== Constructor & Destructor ====================

AudioController::AudioController(QObject *parent)
    : QObject(parent)
    , m_player(new QMediaPlayer(this))
    , m_audioOutput(new QAudioOutput(this))
    , m_queue(100)
    , m_albumArtCache(50)
{
    // Setup audio output
    m_player->setAudioOutput(m_audioOutput);
    m_audioOutput->setVolume(m_volume);

    // Initialize fade timer
    m_fadeTimer = new QTimer(this);
    m_fadeTimer->setInterval(50);
    connect(m_fadeTimer, &QTimer::timeout, this, [this]() {
        if (m_fadeProgress < 1.0) {
            m_fadeProgress += 0.05;
            applyVolumeEffects();
        } else {
            m_fadeTimer->stop();
            m_fadeProgress = 1.0;
            applyVolumeEffects();
        }
    });

    // Connect media player signals
    connect(m_player, &QMediaPlayer::positionChanged, this, &AudioController::onPositionChanged);
    connect(m_player, &QMediaPlayer::durationChanged, this, &AudioController::onDurationChanged);
    connect(m_player, &QMediaPlayer::playbackStateChanged, this, &AudioController::onPlaybackStateChanged);
    connect(m_player, &QMediaPlayer::metaDataChanged, this, &AudioController::onMetaDataChanged);
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, &AudioController::onMediaStatusChanged);
    connect(m_player, &QMediaPlayer::errorOccurred, this, &AudioController::onErrorOccurred);

    qDebug() << "AudioController initialized successfully";
}

AudioController::~AudioController()
{
    if (m_fadeTimer) {
        m_fadeTimer->stop();
    }
    qDebug() << "AudioController destroyed";
}

// ==================== File Opening with Exception Handling ====================

void AudioController::openFile(const QString &filePath)
{
    try {
        if (filePath.isEmpty()) {
            throw InvalidOperationException("File path is empty");
        }

        QFileInfo fileInfo(filePath);
        if (!fileInfo.exists()) {
            throw FileNotFoundException(filePath);
        }

        QString extension = fileInfo.suffix().toLower();
        QStringList supportedFormats = {"mp3", "flac", "ogg", "wav", "m4a", "aac"};
        if (!supportedFormats.contains(extension)) {
            throw UnsupportedFormatException(extension);
        }

        QUrl url = QUrl::fromLocalFile(filePath);
        m_player->setSource(url);

        m_currentTrack = Track(filePath);
        setTrackInfo(m_currentTrack.title(), m_currentTrack.artist());

        auto cachedArt = m_albumArtCache.get(m_currentTrack.album());
        if (cachedArt.has_value()) {
            qDebug() << "Using cached album art for:" << m_currentTrack.album();
        }

        setThumbnail("");
        play();

        m_currentTrack.incrementPlayCount();
        m_currentTrack.updateLastPlayed();

        qDebug() << "Successfully opened file:" << filePath;
    }
    catch (const FileNotFoundException& e) {
        qCritical() << "File not found:" << e.what();
        m_mediaStatus = Error;
        emit mediaStatusChanged();
    }
    catch (const UnsupportedFormatException& e) {
        qCritical() << "Unsupported format:" << e.what();
        m_mediaStatus = Error;
        emit mediaStatusChanged();
    }
    catch (const AudioException& e) {
        qCritical() << "Audio exception:" << e.what();
        m_mediaStatus = Error;
        emit mediaStatusChanged();
    }
    catch (const std::exception& e) {
        qCritical() << "Unexpected error:" << e.what();
        m_mediaStatus = Error;
        emit mediaStatusChanged();
    }
}

// ==================== YouTube Support ====================

void AudioController::playYouTubeAudio(const QString &query)
{
    if (query.isEmpty()) return;

    m_mediaStatus = Loading;
    emit mediaStatusChanged();

    QString ytDlpPath = QCoreApplication::applicationDirPath() + "/yt-dlp.exe";
    if (!QFile::exists(ytDlpPath)) {
        qWarning() << "yt-dlp.exe not found at:" << ytDlpPath;
        m_mediaStatus = Error;
        emit mediaStatusChanged();
        return;
    }

    QProcess *ytDlp = new QProcess(this);
    QStringList args = {
        "-J",
        "--no-warnings",
        "-f", "bestaudio[ext=m4a]/bestaudio",
        "ytsearch1:" + query
    };

    connect(ytDlp, &QProcess::finished, this, [=](int exitCode) {
        if (exitCode != 0) {
            qWarning() << "yt-dlp failed with code:" << exitCode;
            m_mediaStatus = Error;
            emit mediaStatusChanged();
            ytDlp->deleteLater();
            return;
        }

        QByteArray output = ytDlp->readAllStandardOutput();
        if (output.isEmpty()) {
            qWarning() << "yt-dlp returned no data";
            m_mediaStatus = Error;
            emit mediaStatusChanged();
            ytDlp->deleteLater();
            return;
        }

        QJsonDocument doc = QJsonDocument::fromJson(output);
        QJsonObject entry = doc.object();

        if (entry.contains("entries") && entry["entries"].isArray()) {
            QJsonArray entries = entry["entries"].toArray();
            if (entries.isEmpty()) {
                qWarning() << "No entries found for query";
                m_mediaStatus = Error;
                emit mediaStatusChanged();
                ytDlp->deleteLater();
                return;
            }
            entry = entries[0].toObject();
        }

        QString audioUrl = entry["url"].toString();
        QString title = entry["title"].toString("YouTube Track");
        QString artist = entry["uploader"].toString("YouTube");
        QString thumbnailUrl = entry["thumbnail"].toString();

        if (audioUrl.isEmpty()) {
            qWarning() << "Could not find audio URL in JSON";
            m_mediaStatus = Error;
            emit mediaStatusChanged();
            ytDlp->deleteLater();
            return;
        }

        // Fix WebP thumbnails
        if (thumbnailUrl.contains("vi_webp")) {
            QRegularExpression re("vi_webp/([\\w-]+)/.*");
            QRegularExpressionMatch match = re.match(thumbnailUrl);
            if (match.hasMatch()) {
                QString videoId = match.captured(1);
                thumbnailUrl = QString("https://i.ytimg.com/vi/%1/hqdefault.jpg").arg(videoId);
            }
        }

        m_currentTrack = Track();
        m_currentTrack.setTitle(title);
        m_currentTrack.setArtist(artist);

        setTrackInfo(title, artist);
        setThumbnail(thumbnailUrl);
        m_player->setSource(QUrl(audioUrl));
        play();

        ytDlp->deleteLater();
    });

    ytDlp->start(ytDlpPath, args);
}

// ==================== Playback Controls ====================

void AudioController::play()
{
    m_player->play();

    if (m_fadeInEnabled) {
        startFadeIn();
    }
}

void AudioController::pause()
{
    m_player->pause();

    if (m_fadeTimer->isActive()) {
        m_fadeTimer->stop();
    }
}

void AudioController::seek(qint64 position)
{
    m_player->setPosition(position);
}

void AudioController::setVolume(qreal volume)
{
    volume = qBound(0.0, volume, 1.0);

    if (qFuzzyCompare(m_volume, volume)) return;

    m_volume = volume;
    applyVolumeEffects();
    emit volumeChanged();
}

// ==================== Getters ====================

qint64 AudioController::duration() const
{
    return m_player->duration();
}

qint64 AudioController::position() const
{
    return m_player->position();
}

bool AudioController::isPlaying() const
{
    return m_player->playbackState() == QMediaPlayer::PlayingState;
}

QString AudioController::formatTime(qint64 milliseconds) const
{
    if (milliseconds <= 0) return "0:00";
    qint64 totalSeconds = milliseconds / 1000;
    qint64 minutes = totalSeconds / 60;
    qint64 seconds = totalSeconds % 60;
    return QString("%1:%2").arg(minutes).arg(seconds, 2, 10, QChar('0'));
}

QString AudioController::formattedPosition() const
{
    return formatTime(position());
}

QString AudioController::formattedDuration() const
{
    return formatTime(duration());
}

void AudioController::setThumbnail(const QString &url)
{
    if (m_thumbnailUrl == url) return;
    m_thumbnailUrl = url;
    emit thumbnailUrlChanged();
}

void AudioController::setTrackInfo(const QString &title, const QString &artist)
{
    if (m_trackTitle != title) {
        m_trackTitle = title;
        emit trackTitleChanged();
    }

    if (m_trackArtist != artist) {
        m_trackArtist = artist;
        emit trackArtistChanged();
    }
}

// ==================== Audio Effects ====================

void AudioController::setGainBoost(qreal gain)
{
    gain = qBound(0.0, gain, 2.0);

    if (qFuzzyCompare(m_gainBoost, gain)) return;

    m_gainBoost = gain;
    applyVolumeEffects();
    emit gainBoostChanged();

    qDebug() << "Gain boost set to:" << (m_gainBoost * 100) << "%";
}

void AudioController::setBalance(qreal balance)
{
    balance = qBound(-1.0, balance, 1.0);

    if (qFuzzyCompare(m_balance, balance)) return;

    m_balance = balance;
    emit balanceChanged();

    qDebug() << "Balance set to:" << m_balance;
}

void AudioController::setPlaybackRate(qreal rate)
{
    rate = qBound(0.25, rate, 2.0);

    if (qFuzzyCompare(m_playbackRate, rate)) return;

    m_playbackRate = rate;
    m_player->setPlaybackRate(rate);
    emit playbackRateChanged();

    qDebug() << "Playback rate set to:" << m_playbackRate << "x";
}

void AudioController::setFadeInEnabled(bool enabled)
{
    if (m_fadeInEnabled == enabled) return;

    m_fadeInEnabled = enabled;
    emit fadeInEnabledChanged();

    qDebug() << "Fade in" << (enabled ? "enabled" : "disabled");
}

void AudioController::resetEffects()
{
    setGainBoost(1.0);
    setBalance(0.0);
    setPlaybackRate(1.0);
    setFadeInEnabled(false);

    m_fadeProgress = 1.0;
    if (m_fadeTimer->isActive()) {
        m_fadeTimer->stop();
    }

    applyVolumeEffects();

    qDebug() << "All effects reset to defaults";
}

void AudioController::applyVolumeEffects()
{
    qreal effectiveVolume = m_volume * m_gainBoost;

    if (m_fadeInEnabled && m_fadeProgress < 1.0) {
        effectiveVolume *= m_fadeProgress;
    }

    effectiveVolume = qBound(0.0, effectiveVolume, 1.0);
    m_audioOutput->setVolume(effectiveVolume);
}

void AudioController::startFadeIn()
{
    if (m_fadeInEnabled && isPlaying()) {
        m_fadeProgress = 0.0;
        applyVolumeEffects();
        m_fadeTimer->start();
        qDebug() << "Fade in started";
    }
}

// ==================== Library Playback ====================

void AudioController::setLibraryPlaybackMode(bool enabled)
{
    if (m_libraryPlaybackEnabled == enabled) return;

    m_libraryPlaybackEnabled = enabled;
    emit libraryPlaybackEnabledChanged();

    qDebug() << "Library playback mode:" << (enabled ? "enabled" : "disabled");
}

void AudioController::playFromLibraryIndex(int index)
{
    if (index < 0 || index >= static_cast<int>(m_libraryQueue.size())) {
        qWarning() << "Invalid library index:" << index;
        return;
    }

    m_currentLibraryIndex = index;
    QString trackPath = m_libraryQueue[index];
    openFile(trackPath);

    qDebug() << "Playing from library index:" << index << "Path:" << trackPath;
}

void AudioController::updateLibraryQueue(const QStringList& trackPaths)
{
    m_libraryQueue.clear();
    for (const QString& path : trackPaths) {
        m_libraryQueue.push_back(path);
    }

    qDebug() << "Library queue updated with" << m_libraryQueue.size() << "tracks";
}

void AudioController::playNextInLibrary()
{
    if (!m_libraryPlaybackEnabled || m_libraryQueue.empty()) {
        qDebug() << "Library playback disabled or queue empty";
        return;
    }

    m_currentLibraryIndex++;

    if (m_currentLibraryIndex >= static_cast<int>(m_libraryQueue.size())) {
        qDebug() << "Reached end of library";
        m_currentLibraryIndex = -1;
        m_libraryPlaybackEnabled = false;
        emit libraryPlaybackEnabledChanged();
        return;
    }

    QString nextTrack = m_libraryQueue[m_currentLibraryIndex];
    qDebug() << "Auto-playing next:" << m_currentLibraryIndex + 1 << "/" << m_libraryQueue.size();
    openFile(nextTrack);
}


// ==================== Queue Management ====================

void AudioController::addToQueue(const QString& filePath)
{
    try {
        Track track(filePath);
        m_queue.push(track);
        qDebug() << "Added to queue:" << filePath << "- Size:" << m_queue.size();
    }
    catch (const std::exception& e) {
        qWarning() << "Failed to add to queue:" << e.what();
    }
}

// void AudioController::playNext()
// {
//     try {
//         if (!m_queue.isEmpty()) {
//             Track nextTrack = m_queue.pop();
//             openFile(nextTrack.path());
//             qDebug() << "Playing next from queue:" << nextTrack.title();
//         } else {
//             qDebug() << "Queue is empty";
//         }
//     }
//     catch (const std::exception& e) {
//         qWarning() << "Failed to play next:" << e.what();
//     }
// }

int AudioController::queueSize() const
{
    return static_cast<int>(m_queue.size());
}

// ==================== Private Slots ====================

void AudioController::onPositionChanged(qint64 pos)
{
    Q_UNUSED(pos);
    emit positionChanged();
}

void AudioController::onDurationChanged(qint64 dur)
{
    Q_UNUSED(dur);
    emit durationChanged();
}

void AudioController::onPlaybackStateChanged(QMediaPlayer::PlaybackState state)
{
    Q_UNUSED(state);
    emit isPlayingChanged();
}

void AudioController::onMetaDataChanged()
{
    if (m_trackTitle.isEmpty() || m_trackTitle == "Local File") {
        QString title = m_player->metaData().stringValue(QMediaMetaData::Title);
        QString artist = m_player->metaData().stringValue(QMediaMetaData::Author);
        if (!title.isEmpty()) {
            setTrackInfo(title, artist.isEmpty() ? "Unknown Artist" : artist);
        }
    }
}

void AudioController::onMediaStatusChanged(QMediaPlayer::MediaStatus status)
{
    switch (status) {
    case QMediaPlayer::EndOfMedia:
        qDebug() << "Media Status: End of Media";
        if (m_libraryPlaybackEnabled) {
            qDebug() << "Auto-playing next track...";
            playNextInLibrary();
        }
        break;

    case QMediaPlayer::LoadingMedia:
        m_mediaStatus = Loading;
        qDebug() << "Media Status: Loading...";
        break;

    case QMediaPlayer::LoadedMedia:
        m_mediaStatus = Loaded;
        qDebug() << "Media Status: Loaded";
        m_isRecovering = false;
        break;

    case QMediaPlayer::BufferingMedia:
        m_mediaStatus = Buffering;
        qDebug() << "Media Status: Buffering...";
        break;

    case QMediaPlayer::StalledMedia:
        m_mediaStatus = Stalled;
        qWarning() << "Media Status: Stalled!";
        if (isPlaying() && !m_isRecovering) {
            qWarning() << "Attempting recovery...";
            m_isRecovering = true;
            qint64 pos = m_player->position();
            m_player->pause();
            m_player->setPosition(pos + 1);
            m_player->play();
        }
        break;

    case QMediaPlayer::InvalidMedia:
        qWarning() << "Media Status: Invalid Media!";
        m_mediaStatus = Error;
        break;

    case QMediaPlayer::NoMedia:
    default:
        m_mediaStatus = NoMedia;
        break;
    }
    emit mediaStatusChanged();
}

void AudioController::onErrorOccurred(QMediaPlayer::Error error, const QString &errorString)
{
    qWarning() << "QMediaPlayer Error:" << error << errorString;
    m_mediaStatus = Error;
    emit mediaStatusChanged();
}

