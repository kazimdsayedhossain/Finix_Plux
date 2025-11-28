#ifndef RECOMMENDATIONMANAGER_H
#define RECOMMENDATIONMANAGER_H

#include <QObject>
#include <QString>
#include <QList>
#include <QQueue>
#include <QTimer>
#include <QThread>
#include <QMutex>
#include <QVariantList>
#include <QDateTime>
#include <QProcess>

// Structure to represent a recommended song
struct RecommendedSong {
    QString title;
    QString artist;
    QString thumbnailUrl;
    QString searchQuery;
    double similarityScore = 0.0;

    RecommendedSong() = default;
    RecommendedSong(const QString& t, const QString& a, const QString& thumb, const QString& query, double score = 0.0)
        : title(t), artist(a), thumbnailUrl(thumb), searchQuery(query), similarityScore(score) {}
};

// Structure to track played YouTube songs
struct PlayedSong {
    QString title;
    QString artist;
    QString genre;
    QStringList keywords;
    qint64 timestamp;

    PlayedSong() = default;
    PlayedSong(const QString& t, const QString& a, const QString& g = QString())
        : title(t), artist(a), genre(g), timestamp(QDateTime::currentMSecsSinceEpoch()) {
        extractKeywords();
    }

private:
    void extractKeywords();
};

class RecommendationWorker : public QObject {
    Q_OBJECT

public:
    explicit RecommendationWorker(QObject* parent = nullptr);

    // Public method for fetching YouTube results (needed for test recommendations)
    QList<RecommendedSong> fetchYouTubeResults(const QString& searchQuery, int maxResults = 1);

public slots:
    void generateRecommendations(const PlayedSong& currentSong, const QList<PlayedSong>& playedHistory);

signals:
    void recommendationsReady(const QList<RecommendedSong>& recommendations);

private:
    QList<RecommendedSong> generateRelatedSongs(const PlayedSong& song);
    QString findYtDlpPath() const;
    QString fixThumbnailUrl(const QString& thumbnailUrl) const;
    double calculateSimilarity(const PlayedSong& song1, const PlayedSong& song2) const;
    QStringList extractKeywords(const QString& text) const;
};

class RecommendationManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList recommendations READ getRecommendations NOTIFY recommendationsChanged)
    Q_PROPERTY(int count READ recommendationCount NOTIFY recommendationsChanged)

public:
    explicit RecommendationManager(QObject *parent = nullptr);
    ~RecommendationManager();

    // Getters
    QVariantList getRecommendations() const;
    int recommendationCount() const;

    // Methods
    Q_INVOKABLE void startRecommendationTimer(const QString& title, const QString& artist);
    Q_INVOKABLE void cancelRecommendationTimer();
    Q_INVOKABLE void playRecommendedSong(int index);
    Q_INVOKABLE void clearRecommendations();
    Q_INVOKABLE void addTestRecommendations();
    Q_INVOKABLE void forceRefresh();

signals:
    void recommendationsChanged();
    void playYouTubeSong(const QString& query);

private slots:
    void onRecommendationTimerTimeout();
    void onRecommendationsReady(const QList<RecommendedSong>& newRecommendations);

private:
    void addRecommendations(const QList<RecommendedSong>& newRecs);
    void ensureQueueSize();
    QString extractGenreFromArtist(const QString& artist) const;

    // Threading
    QThread* m_workerThread;
    RecommendationWorker* m_worker;

    // Data structures
    QList<PlayedSong> m_playedSongs;
    QQueue<RecommendedSong> m_recommendations;
    mutable QMutex m_dataMutex;

    // Timer
    QTimer* m_recommendationTimer;
    QString m_pendingTitle;
    QString m_pendingArtist;
    QString m_lastProcessedTitle;  // Track the last song we generated recommendations for
    QString m_lastProcessedArtist;

    static const int MAX_RECOMMENDATIONS = 100;
    static const int RECOMMENDATIONS_PER_SONG = 7;
    static const int TIMER_DELAY_MS = 10000; // 10 seconds
};

#endif // RECOMMENDATIONMANAGER_H
