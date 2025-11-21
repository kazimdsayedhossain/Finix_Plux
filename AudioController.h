#ifndef AUDIOCONTROLLER_H
#define AUDIOCONTROLLER_H

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QMediaMetaData>
#include <memory>
#include "Track.h"
#include "AudioEffect.h"
#include "CircularBuffer.h"
#include "Cache.h"

class AudioController : public QObject
{
    Q_OBJECT

    // === Q_ENUM for Media Status ===
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

    // === Q_PROPERTIES for QML ===
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(qint64 position READ position NOTIFY positionChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)
    Q_PROPERTY(qreal volume READ volume WRITE setVolume NOTIFY volumeChanged)

    Q_PROPERTY(QString thumbnailUrl READ thumbnailUrl NOTIFY thumbnailUrlChanged)
    Q_PROPERTY(QString trackTitle READ trackTitle NOTIFY trackTitleChanged)
    Q_PROPERTY(QString trackArtist READ trackArtist NOTIFY trackArtistChanged)
    Q_PROPERTY(QString formattedPosition READ formattedPosition NOTIFY positionChanged)
    Q_PROPERTY(QString formattedDuration READ formattedDuration NOTIFY durationChanged)
    Q_PROPERTY(MediaStatus mediaStatus READ mediaStatus NOTIFY mediaStatusChanged)

public:
    explicit AudioController(QObject *parent = nullptr);
    ~AudioController();

    // --- Getters for Q_PROPERTIES ---
    qint64 duration() const;
    qint64 position() const;
    bool isPlaying() const;
    qreal volume() const;
    QString thumbnailUrl() const { return m_thumbnailUrl; }
    QString trackTitle() const { return m_trackTitle; }
    QString trackArtist() const { return m_trackArtist; }
    QString formattedPosition() const;
    QString formattedDuration() const;
    MediaStatus mediaStatus() const { return m_mediaStatus; }

    // --- Q_INVOKABLE Methods (Called from QML) ---
    Q_INVOKABLE void openFile(const QString &filePath);
    Q_INVOKABLE void playYouTubeAudio(const QString &query);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void seek(qint64 position);
    Q_INVOKABLE void setVolume(qreal volume);

    // Audio Effects Methods
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

    Q_INVOKABLE void addToQueue(const QString& filePath);
    Q_INVOKABLE void playNext();
    Q_INVOKABLE int queueSize() const;

signals:
    void durationChanged();
    void positionChanged();
    void isPlayingChanged();
    void volumeChanged();
    void thumbnailUrlChanged();
    void trackTitleChanged();
    void trackArtistChanged();
    void mediaStatusChanged();

private slots:
    void onPositionChanged(qint64 pos);
    void onDurationChanged(qint64 dur);
    void onPlaybackStateChanged(QMediaPlayer::PlaybackState state);
    void onMetaDataChanged();
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);
    void onErrorOccurred(QMediaPlayer::Error error, const QString &errorString);

private:
    QString formatTime(qint64 milliseconds) const;
    void setThumbnail(const QString &url);
    void setTrackInfo(const QString &title, const QString &artist);

    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;

    qreal m_volume = 0.5;
    QString m_thumbnailUrl;
    QString m_trackTitle;
    QString m_trackArtist;
    MediaStatus m_mediaStatus = NoMedia;

    bool m_isRecovering = false;

    // Effect chain for audio processing
    EffectChain m_effectChain;

    // Playback queue
    CircularBuffer<Track> m_queue;

    // Album art cache
    LRUCache<QString, QImage> m_albumArtCache;

    // Current track
    Track m_currentTrack;
};

#endif // AUDIOCONTROLLER_H
