#ifndef AUDIOCONTROLLER_H
#define AUDIOCONTROLLER_H

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QMediaMetaData>
#include <QTimer>
#include <memory>
#include <QImage>
#include "Track.h"
#include "AudioEffect.h"
#include "CircularBuffer.h"
#include "Cache.h"
#include "PlaylistManager.h"

class AudioController : public QObject
{
    Q_OBJECT

    // ==================== Media Status Enum ====================
public:
    enum MediaStatus {
        NoMedia,
        Loading,
        Loaded,
        Buffering,
        Stalled,
        Error
    };
    Q_ENUM(MediaStatus)

    // ==================== Properties for QML ====================

    // Playback properties
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(qint64 position READ position NOTIFY positionChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)
    Q_PROPERTY(qreal volume READ volume WRITE setVolume NOTIFY volumeChanged)

    // Track info properties
    Q_PROPERTY(QString thumbnailUrl READ thumbnailUrl NOTIFY thumbnailUrlChanged)
    Q_PROPERTY(QString trackTitle READ trackTitle NOTIFY trackTitleChanged)
    Q_PROPERTY(QString trackArtist READ trackArtist NOTIFY trackArtistChanged)
    Q_PROPERTY(QString formattedPosition READ formattedPosition NOTIFY positionChanged)
    Q_PROPERTY(QString formattedDuration READ formattedDuration NOTIFY durationChanged)
    Q_PROPERTY(MediaStatus mediaStatus READ mediaStatus NOTIFY mediaStatusChanged)

    // NEW: Audio Effect Properties
    Q_PROPERTY(qreal gainBoost READ gainBoost WRITE setGainBoost NOTIFY gainBoostChanged)
    Q_PROPERTY(qreal balance READ balance WRITE setBalance NOTIFY balanceChanged)
    Q_PROPERTY(qreal playbackRate READ playbackRate WRITE setPlaybackRate NOTIFY playbackRateChanged)
    Q_PROPERTY(bool fadeInEnabled READ fadeInEnabled WRITE setFadeInEnabled NOTIFY fadeInEnabledChanged)

public:
    explicit AudioController(QObject *parent = nullptr);
    ~AudioController();

    // ==================== Getters ====================

    // Playback getters
    qint64 duration() const;
    qint64 position() const;
    bool isPlaying() const;
    qreal volume() const { return m_volume; }

    // Track info getters
    QString thumbnailUrl() const { return m_thumbnailUrl; }
    QString trackTitle() const { return m_trackTitle; }
    QString trackArtist() const { return m_trackArtist; }
    QString formattedPosition() const;
    QString formattedDuration() const;
    MediaStatus mediaStatus() const { return m_mediaStatus; }

    // NEW: Effect getters
    qreal gainBoost() const { return m_gainBoost; }
    qreal balance() const { return m_balance; }
    qreal playbackRate() const { return m_playbackRate; }
    bool fadeInEnabled() const { return m_fadeInEnabled; }

    // ==================== Invokable Methods ====================

    // Playback control
    Q_INVOKABLE void openFile(const QString &filePath);
    Q_INVOKABLE void playYouTubeAudio(const QString &query);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void seek(qint64 position);
    Q_INVOKABLE void setVolume(qreal volume);

    // NEW: Audio Effects Methods
    Q_INVOKABLE void setGainBoost(qreal gain);
    Q_INVOKABLE void setBalance(qreal balance);
    Q_INVOKABLE void setPlaybackRate(qreal rate);
    Q_INVOKABLE void setFadeInEnabled(bool enabled);
    Q_INVOKABLE void resetEffects();

    // Legacy effect methods (kept for compatibility but not functional)
    Q_INVOKABLE void addEqualizerEffect();
    Q_INVOKABLE void removeEffect(int index);
    Q_INVOKABLE void setEqualizerBand(int band, float gain);
    Q_INVOKABLE void setEqualizerPreset(const QString& preset);
    Q_INVOKABLE void addReverbEffect();
    Q_INVOKABLE void setReverbRoomSize(float size);
    Q_INVOKABLE void setReverbDamping(float damping);
    Q_INVOKABLE void setReverbMix(float mix);
    Q_INVOKABLE void addBassBoostEffect();
    Q_INVOKABLE void setBassBoostLevel(float level);

    // Queue management
    Q_INVOKABLE void addToQueue(const QString& filePath);
    Q_INVOKABLE void playNext();
    Q_INVOKABLE int queueSize() const;


    // In AudioController.h - Add these methods to test features

    Q_INVOKABLE void testAllOOPFeatures();
    Q_INVOKABLE void testFunctionOverloading();
    Q_INVOKABLE void testOperatorOverloading();
    Q_INVOKABLE void testStaticMembers();
    Q_INVOKABLE void testFriendFunction();

signals:
    // Playback signals
    void durationChanged();
    void positionChanged();
    void isPlayingChanged();
    void volumeChanged();

    // Track info signals
    void thumbnailUrlChanged();
    void trackTitleChanged();
    void trackArtistChanged();
    void mediaStatusChanged();

    // NEW: Effect signals
    void gainBoostChanged();
    void balanceChanged();
    void playbackRateChanged();
    void fadeInEnabledChanged();

private slots:
    // Media player event handlers
    void onPositionChanged(qint64 pos);
    void onDurationChanged(qint64 dur);
    void onPlaybackStateChanged(QMediaPlayer::PlaybackState state);
    void onMetaDataChanged();
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);
    void onErrorOccurred(QMediaPlayer::Error error, const QString &errorString);

private:
    // ==================== Private Methods ====================
    QString formatTime(qint64 milliseconds) const;
    void setThumbnail(const QString &url);
    void setTrackInfo(const QString &title, const QString &artist);

    // NEW: Effect application methods
    void applyVolumeEffects();
    void startFadeIn();

    // ==================== Member Variables ====================

    // Core media components
    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;

    // Playback state
    qreal m_volume = 0.5;
    QString m_thumbnailUrl;
    QString m_trackTitle;
    QString m_trackArtist;
    MediaStatus m_mediaStatus = NoMedia;
    bool m_isRecovering = false;

    // NEW: Audio effect parameters
    qreal m_gainBoost = 1.0;           // 0.0 to 2.0 (volume boost)
    qreal m_balance = 0.0;             // -1.0 (left) to 1.0 (right)
    qreal m_playbackRate = 1.0;        // 0.25 to 2.0 (speed/pitch)
    bool m_fadeInEnabled = false;      // Fade in on play

    // Fade effect state
    QTimer* m_fadeTimer;
    qreal m_fadeProgress = 0.0;

    // Legacy effect chain (kept for architecture demonstration)
    EffectChain m_effectChain;

    // Playback queue
    CircularBuffer<Track> m_queue;

    // Album art cache
    LRUCache<QString, QImage> m_albumArtCache;

    // Current track
    Track m_currentTrack;
};

#endif // AUDIOCONTROLLER_H
