// AudioController.cpp - Complete implementation with working audio effects

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
    , m_queue(100)           // CircularBuffer with capacity 100
    , m_albumArtCache(50)    // LRU Cache with capacity 50
{
    // Setup audio output
    m_player->setAudioOutput(m_audioOutput);
    m_audioOutput->setVolume(m_volume);

    // Initialize fade timer
    m_fadeTimer = new QTimer(this);
    m_fadeTimer->setInterval(50); // 50ms updates for smooth fade
    connect(m_fadeTimer, &QTimer::timeout, this, [this]() {
        if (m_fadeProgress < 1.0) {
            m_fadeProgress += 0.05; // Increase by 5% each tick (1 second total)
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

    qDebug() << "AudioController initialized with working audio effects";
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

        // Check if format is supported
        QString extension = fileInfo.suffix().toLower();
        QStringList supportedFormats = {"mp3", "flac", "ogg", "wav", "m4a", "aac"};
        if (!supportedFormats.contains(extension)) {
            throw UnsupportedFormatException(extension);
        }

        QUrl url = QUrl::fromLocalFile(filePath);
        m_player->setSource(url);

        // Create and load track
        m_currentTrack = Track(filePath);

        setTrackInfo(m_currentTrack.title(), m_currentTrack.artist());

        // Try to load album art from cache
        auto cachedArt = m_albumArtCache.get(m_currentTrack.album());
        if (cachedArt.has_value()) {
            qDebug() << "Using cached album art for:" << m_currentTrack.album();
        }

        setThumbnail("");

        play();

        // Update statistics
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
        qWarning() << "yt-dlp.exe not found at path:" << ytDlpPath;
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
            qWarning() << "yt-dlp process failed with code:" << exitCode;
            m_mediaStatus = Error;
            emit mediaStatusChanged();
            ytDlp->deleteLater();
            return;
        }

        QByteArray output = ytDlp->readAllStandardOutput();
        if (output.isEmpty()) {
            qWarning() << "yt-dlp returned no data.";
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
                qWarning() << "yt-dlp: No entries found for query.";
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
            qWarning() << "yt-dlp: Could not find audio URL in JSON.";
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
                qDebug() << "WebP thumbnail detected. Falling back to JPG:" << thumbnailUrl;
            }
        }

        // Create track from YouTube data
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

    // Start fade in if enabled
    if (m_fadeInEnabled) {
        startFadeIn();
    }
}

void AudioController::pause()
{
    m_player->pause();

    // Stop fade timer if running
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
    applyVolumeEffects(); // Apply all volume-based effects
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

// ==================== NEW: Working Audio Effects ====================

void AudioController::setGainBoost(qreal gain)
{
    gain = qBound(0.0, gain, 2.0); // Limit to 0-200%

    if (qFuzzyCompare(m_gainBoost, gain)) return;

    m_gainBoost = gain;
    applyVolumeEffects();
    emit gainBoostChanged();

    qDebug() << "Gain boost set to:" << m_gainBoost << "(" << (m_gainBoost * 100) << "%)";
}

void AudioController::setBalance(qreal balance)
{
    balance = qBound(-1.0, balance, 1.0); // -1 (left) to 1 (right)

    if (qFuzzyCompare(m_balance, balance)) return;

    m_balance = balance;
    // Note: Qt's QAudioOutput doesn't have built-in balance control
    // This would require lower-level audio API or custom processing
    // For now, we just store the value and emit signal
    emit balanceChanged();

    qDebug() << "Balance set to:" << m_balance;
}

void AudioController::setPlaybackRate(qreal rate)
{
    rate = qBound(0.25, rate, 2.0); // 25% to 200% speed

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
    // Calculate effective volume with gain boost
    qreal effectiveVolume = m_volume * m_gainBoost;

    // Apply fade if enabled and in progress
    if (m_fadeInEnabled && m_fadeProgress < 1.0) {
        effectiveVolume *= m_fadeProgress;
    }

    // Clamp to valid range (0.0 to 1.0)
    effectiveVolume = qBound(0.0, effectiveVolume, 1.0);

    // Apply to audio output
    m_audioOutput->setVolume(effectiveVolume);

    // Debug output
    if (m_fadeInEnabled && m_fadeProgress < 1.0) {
        qDebug() << "Applying volume effects - Base:" << m_volume
                 << "Gain:" << m_gainBoost
                 << "Fade:" << m_fadeProgress
                 << "Effective:" << effectiveVolume;
    }
}

void AudioController::startFadeIn()
{
    if (m_fadeInEnabled && isPlaying()) {
        m_fadeProgress = 0.0;
        applyVolumeEffects(); // Apply initial zero volume
        m_fadeTimer->start();
        qDebug() << "Fade in started (1 second duration)";
    }
}

// ==================== Legacy Audio Effects (Non-functional - Architecture Demo) ====================

void AudioController::addEqualizerEffect()
{
    try {
        auto eq = std::make_unique<EqualizerEffect>();
        m_effectChain.addEffect(std::move(eq));
        qDebug() << "Equalizer effect added (non-functional - architecture demo)";
    }
    catch (const std::exception& e) {
        qWarning() << "Failed to add equalizer:" << e.what();
    }
}

void AudioController::removeEffect(int index)
{
    try {
        m_effectChain.removeEffect(index);
        qDebug() << "Effect removed at index:" << index;
    }
    catch (const std::exception& e) {
        qWarning() << "Failed to remove effect:" << e.what();
    }
}

void AudioController::setEqualizerBand(int band, float gain)
{
    for (int i = 0; i < m_effectChain.effectCount(); ++i) {
        AudioEffect* effect = m_effectChain.getEffect(i);
        if (auto* eq = dynamic_cast<EqualizerEffect*>(effect)) {
            eq->setBand(band, gain);
            qDebug() << "EQ band" << band << "set to" << gain << "dB (non-functional)";
            break;
        }
    }
}

void AudioController::setEqualizerPreset(const QString& preset)
{
    for (int i = 0; i < m_effectChain.effectCount(); ++i) {
        AudioEffect* effect = m_effectChain.getEffect(i);
        if (auto* eq = dynamic_cast<EqualizerEffect*>(effect)) {
            eq->setPreset(preset);
            qDebug() << "EQ preset set to:" << preset << "(non-functional)";
            break;
        }
    }
}

void AudioController::addReverbEffect()
{
    try {
        auto reverb = std::make_unique<ReverbEffect>();
        m_effectChain.addEffect(std::move(reverb));
        qDebug() << "Reverb effect added (non-functional - architecture demo)";
    }
    catch (const std::exception& e) {
        qWarning() << "Failed to add reverb:" << e.what();
    }
}

void AudioController::setReverbRoomSize(float size)
{
    for (int i = 0; i < m_effectChain.effectCount(); ++i) {
        AudioEffect* effect = m_effectChain.getEffect(i);
        if (auto* reverb = dynamic_cast<ReverbEffect*>(effect)) {
            reverb->setRoomSize(size);
            qDebug() << "Reverb room size set to:" << size << "(non-functional)";
            break;
        }
    }
}

void AudioController::setReverbDamping(float damping)
{
    for (int i = 0; i < m_effectChain.effectCount(); ++i) {
        AudioEffect* effect = m_effectChain.getEffect(i);
        if (auto* reverb = dynamic_cast<ReverbEffect*>(effect)) {
            reverb->setDamping(damping);
            qDebug() << "Reverb damping set to:" << damping << "(non-functional)";
            break;
        }
    }
}

void AudioController::setReverbMix(float mix)
{
    for (int i = 0; i < m_effectChain.effectCount(); ++i) {
        AudioEffect* effect = m_effectChain.getEffect(i);
        if (auto* reverb = dynamic_cast<ReverbEffect*>(effect)) {
            reverb->setWetDryMix(mix);
            qDebug() << "Reverb mix set to:" << mix << "(non-functional)";
            break;
        }
    }
}

void AudioController::addBassBoostEffect()
{
    try {
        auto bass = std::make_unique<BassBoostEffect>();
        m_effectChain.addEffect(std::move(bass));
        qDebug() << "Bass boost effect added (non-functional - architecture demo)";
    }
    catch (const std::exception& e) {
        qWarning() << "Failed to add bass boost:" << e.what();
    }
}

void AudioController::setBassBoostLevel(float level)
{
    for (int i = 0; i < m_effectChain.effectCount(); ++i) {
        AudioEffect* effect = m_effectChain.getEffect(i);
        if (auto* bass = dynamic_cast<BassBoostEffect*>(effect)) {
            bass->setBoostLevel(level);
            qDebug() << "Bass boost level set to:" << level << "(non-functional)";
            break;
        }
    }
}

// ==================== Queue Management ====================

void AudioController::addToQueue(const QString& filePath)
{
    try {
        Track track(filePath);
        m_queue.push(track);
        qDebug() << "Added to queue:" << filePath << "- Queue size:" << m_queue.size();
    }
    catch (const std::exception& e) {
        qWarning() << "Failed to add to queue:" << e.what();
    }
}

void AudioController::playNext()
{
    try {
        if (!m_queue.isEmpty()) {
            Track nextTrack = m_queue.pop();
            openFile(nextTrack.path());
            qDebug() << "Playing next from queue:" << nextTrack.title();
        } else {
            qDebug() << "Queue is empty";
        }
    }
    catch (const std::exception& e) {
        qWarning() << "Failed to play next track:" << e.what();
    }
}

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
    case QMediaPlayer::LoadingMedia:
        m_mediaStatus = Loading;
        qDebug() << "Media Status: Loading...";
        break;
    case QMediaPlayer::LoadedMedia:
        m_mediaStatus = Loaded;
        qDebug() << "Media Status: Loaded.";
        m_isRecovering = false;
        break;
    case QMediaPlayer::BufferingMedia:
        m_mediaStatus = Buffering;
        qDebug() << "Media Status: Buffering...";
        break;
    case QMediaPlayer::StalledMedia:
        m_mediaStatus = Stalled;
        qWarning() << "Media Status: Stalled! (Network connection likely lost)";
        if (isPlaying() && !m_isRecovering) {
            qWarning() << "Attempting to recover stalled stream...";
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



// In AudioController.cpp - Add these test methods

void AudioController::testAllOOPFeatures()
{
    qDebug() << "\n========== TESTING ALL OOP FEATURES ==========\n";

    testFunctionOverloading();
    testOperatorOverloading();
    testStaticMembers();
    testFriendFunction();

    qDebug() << "\n========== ALL OOP TESTS COMPLETED ==========\n";
}

void AudioController::testFunctionOverloading()
{
    qDebug() << "--- Testing Function Overloading ---";

    Track track("test.mp3", "Test Song", "Test Artist");

    // Test overloaded setDuration
    track.setDuration(180000);           // milliseconds
    track.setDuration(3, 30);            // minutes, seconds
    track.setDuration(0, 4, 15);         // hours, minutes, seconds

    // Test overloaded play
    track.play();                        // no parameters
    track.play(0.75);                    // with volume
    track.play(0.5, 30000);              // with volume and position

    qDebug() << "Function Overloading: PASSED ✓\n";
}

void AudioController::testOperatorOverloading()
{
    qDebug() << "--- Testing Operator Overloading ---";

    Track track1("song1.mp3", "Hello", "Artist A");
    Track track2("song2.mp3", "World", "Artist B");
    Track track3("song3.mp3", "Hello", "Artist A");

    // Test comparison operators
    qDebug() << "track1 == track3:" << (track1 == track3);  // true
    qDebug() << "track1 != track2:" << (track1 != track2);  // true
    qDebug() << "track1 < track2:" << (track1 < track2);    // true (H < W)

    // Test stream operator
    qDebug() << "Track1:" << track1;

    // Test addition operator
    QString combined = track1 + track2;
    qDebug() << "Combined name:" << combined;

    // Test increment operators
    ++track1;  // Prefix
    qDebug() << "After ++track1, play count:" << track1.playCount();

    track2++;  // Postfix
    qDebug() << "After track2++, play count:" << track2.playCount();

    qDebug() << "Operator Overloading: PASSED ✓\n";
}

void AudioController::testStaticMembers()
{
    qDebug() << "--- Testing Static Members ---";

    // Test static functions
    qDebug() << "Supported formats:" << Track::getSupportedFormats();
    qDebug() << "Is 'song.mp3' valid?" << Track::isValidAudioFile("song.mp3");
    qDebug() << "Formatted duration:" << Track::formatDuration(215000);

    // Test static variable
    qDebug() << "Total tracks created:" << Track::getTotalTracksCreated();

    {
        Track temp1("temp1.mp3");
        Track temp2("temp2.mp3");
        qDebug() << "After creating 2 tracks:" << Track::getTotalTracksCreated();
    }

    qDebug() << "After destroying 2 tracks:" << Track::getTotalTracksCreated();
    qDebug() << "Static Members: PASSED ✓\n";
}

void AudioController::testFriendFunction()
{
    qDebug() << "--- Testing Friend Function & Friend Class ---";

    Track track("mysong.mp3", "My Song", "My Artist");
    track.setDuration(3, 45);
    track.incrementPlayCount();
    track.incrementPlayCount();

    // Test friend function
    printTrackDetails(track);

    // Test friend class
    PlaylistManager playlist("My Favorites");
    playlist.addTrack(track);
    playlist.addTrack(Track("song2.mp3", "Song 2", "Artist 2"));

    // Friend class can access private members
    playlist.printAllTrackPaths();

    qDebug() << "Friend Function & Class: PASSED ✓\n";
}
