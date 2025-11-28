#include "RecommendationManager.h"
#include <QDateTime>
#include <QRegularExpression>
#include <QDebug>
#include <algorithm>
#include <QRandomGenerator>
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QCoreApplication>
#include <QFile>
#include <QEventLoop>

// ==================== PlayedSong Implementation ====================

void PlayedSong::extractKeywords() {
    QString combined = title + " " + artist;
    combined = combined.toLower();

    combined.replace(QRegularExpression("\\b(the|and|or|but|in|on|at|to|for|of|with|by)\\b"), "");
    combined.replace(QRegularExpression("[^a-zA-Z0-9\\s]"), "");
    combined = combined.simplified();

    keywords = combined.split(" ", Qt::SkipEmptyParts);
}

// ==================== RecommendationWorker Implementation ====================

RecommendationWorker::RecommendationWorker(QObject* parent)
    : QObject(parent)
{
}

void RecommendationWorker::generateRecommendations(const PlayedSong& currentSong, const QList<PlayedSong>& playedHistory) {
    qDebug() << "=== GENERATING REAL RECOMMENDATIONS ===";
    qDebug() << "For song:" << currentSong.title << "by" << currentSong.artist;

    QList<RecommendedSong> recommendations;

    // Generate related songs with REAL YouTube data
    recommendations = generateRelatedSongs(currentSong);

    // Add recommendations based on similar songs from history
    if (!playedHistory.isEmpty()) {
        QList<std::pair<double, int>> similarities;
        for (int i = 0; i < playedHistory.size(); ++i) {
            double similarity = calculateSimilarity(currentSong, playedHistory[i]);
            similarities.append({similarity, i});
        }

        std::sort(similarities.begin(), similarities.end(),
                  [](const auto& a, const auto& b) { return a.first > b.first; });

        // Get recommendations from top 2 similar songs
        for (int i = 0; i < qMin(2, similarities.size()); ++i) {
            if (similarities[i].first > 0.3) {
                const PlayedSong& similarSong = playedHistory[similarities[i].second];
                QList<RecommendedSong> similarRecs = generateRelatedSongs(similarSong);
                recommendations.append(similarRecs);
            }
        }
    }

    // Remove duplicates
    QSet<QString> seenQueries;
    QList<RecommendedSong> uniqueRecommendations;

    for (const auto& rec : recommendations) {
        if (!seenQueries.contains(rec.searchQuery) && uniqueRecommendations.size() < 7) {
            uniqueRecommendations.append(rec);
            seenQueries.insert(rec.searchQuery);
        }
    }

    qDebug() << "Generated" << uniqueRecommendations.size() << "unique recommendations";
    emit recommendationsReady(uniqueRecommendations);
}

QList<RecommendedSong> RecommendationWorker::generateRelatedSongs(const PlayedSong& song) {
    QList<RecommendedSong> recommendations;
    QStringList searchQueries;

    // Generate search queries
    if (!song.artist.isEmpty()) {
        searchQueries.append(QString(" viral song ").arg(song.artist));
        searchQueries.append(QString(" songs by").arg(song.artist));
    }

    if (!song.genre.isEmpty()) {
        searchQueries.append(QString(" x mashup").arg(song.genre));
    }

    // Add keyword-based searches
    for (const QString& keyword : song.keywords) {
        if (keyword.length() > 4 && searchQueries.size() < 5) {
            searchQueries.append(QString(" same vibe ").arg(keyword));
        }
    }

    // Limit to 5 search queries to avoid too many yt-dlp calls
    searchQueries = searchQueries.mid(0, 7);

    // Fetch real YouTube results for each query
    for (const QString& query : searchQueries) {
        qDebug() << "Fetching YouTube results for:" << query;
        QList<RecommendedSong> results = fetchYouTubeResults(query, 1); // Get 1 result per query
        recommendations.append(results);

        // Small delay to avoid overwhelming yt-dlp
        QThread::msleep(200);
    }

    return recommendations;
}

QList<RecommendedSong> RecommendationWorker::fetchYouTubeResults(const QString& searchQuery, int maxResults) {
    QList<RecommendedSong> results;

    QString ytDlpPath = findYtDlpPath();
    if (ytDlpPath.isEmpty()) {
        qWarning() << "yt-dlp not found, cannot fetch real recommendations";
        return results;
    }

    QProcess process;
    QStringList args = {
        "-J",
        "--no-warnings",
        "--flat-playlist",
        QString("ytsearch%1:%2").arg(maxResults).arg(searchQuery)
    };

    qDebug() << "Running yt-dlp with query:" << searchQuery;

    process.start(ytDlpPath, args);

    if (!process.waitForFinished(15000)) { // 15 second timeout
        qWarning() << "yt-dlp process timeout for query:" << searchQuery;
        process.kill();
        return results;
    }

    if (process.exitCode() != 0) {
        qWarning() << "yt-dlp failed with code:" << process.exitCode();
        qWarning() << "Error:" << process.readAllStandardError();
        return results;
    }

    QByteArray output = process.readAllStandardOutput();
    if (output.isEmpty()) {
        qWarning() << "yt-dlp returned no data";
        return results;
    }

    // Parse JSON response
    QJsonDocument doc = QJsonDocument::fromJson(output);
    QJsonObject rootObj = doc.object();

    // Handle both single result and playlist results
    QJsonArray entries;
    if (rootObj.contains("entries") && rootObj["entries"].isArray()) {
        entries = rootObj["entries"].toArray();
    } else if (rootObj.contains("title")) {
        // Single result
        entries.append(rootObj);
    }

    for (const QJsonValue& value : entries) {
        QJsonObject entry = value.toObject();

        QString title = entry["title"].toString();
        QString uploader = entry["uploader"].toString("Unknown Artist");
        QString thumbnailUrl = entry["thumbnail"].toString();
        QString videoId = entry["id"].toString();

        // Fix thumbnail URL if needed
        thumbnailUrl = fixThumbnailUrl(thumbnailUrl);

        // If no thumbnail from flat-playlist, construct one from video ID
        if (thumbnailUrl.isEmpty() && !videoId.isEmpty()) {
            thumbnailUrl = QString("https://i.ytimg.com/vi/%1/hqdefault.jpg").arg(videoId);
        }

        // Use title as search query for playback
        QString playbackQuery = title;

        if (!title.isEmpty()) {
            results.append(RecommendedSong(title, uploader, thumbnailUrl, playbackQuery, 1.0));
            qDebug() << "  Found:" << title << "by" << uploader;
        }
    }

    return results;
}

QString RecommendationWorker::findYtDlpPath() const {
    QStringList searchPaths = {
        QCoreApplication::applicationDirPath() + "/yt-dlp.exe",
        QCoreApplication::applicationDirPath() + "/../yt-dlp.exe",
        QCoreApplication::applicationDirPath() + "/../../yt-dlp.exe"
    };

    for (const QString& path : searchPaths) {
        if (QFile::exists(path)) {
            return path;
        }
    }

    return QString();
}

QString RecommendationWorker::fixThumbnailUrl(const QString& thumbnailUrl) const {
    if (thumbnailUrl.isEmpty()) {
        return thumbnailUrl;
    }

    // Fix WebP thumbnails
    if (thumbnailUrl.contains("vi_webp")) {
        QRegularExpression re("vi_webp/([\\w-]+)/.*");
        QRegularExpressionMatch match = re.match(thumbnailUrl);
        if (match.hasMatch()) {
            QString videoId = match.captured(1);
            return QString("https://i.ytimg.com/vi/%1/hqdefault.jpg").arg(videoId);
        }
    }

    return thumbnailUrl;
}

double RecommendationWorker::calculateSimilarity(const PlayedSong& song1, const PlayedSong& song2) const {
    if (song1.artist == song2.artist && !song1.artist.isEmpty()) {
        return 1.0;
    }

    if (song1.genre == song2.genre && !song1.genre.isEmpty()) {
        return 0.8;
    }

    QSet<QString> keywords1(song1.keywords.begin(), song1.keywords.end());
    QSet<QString> keywords2(song2.keywords.begin(), song2.keywords.end());

    QSet<QString> intersection = keywords1.intersect(keywords2);
    QSet<QString> unionSet = keywords1.unite(keywords2);

    if (unionSet.isEmpty()) return 0.0;

    double jaccardSimilarity = static_cast<double>(intersection.size()) / unionSet.size();

    qint64 timeDiff = qAbs(song1.timestamp - song2.timestamp);
    double timeWeight = qMax(0.1, 1.0 - (timeDiff / (24.0 * 60.0 * 60.0 * 1000.0)));

    return jaccardSimilarity * timeWeight;
}

QStringList RecommendationWorker::extractKeywords(const QString& text) const {
    QString cleaned = text.toLower();
    cleaned.replace(QRegularExpression("\\b(the|and|or|but|in|on|at|to|for|of|with|by|a|an)\\b"), "");
    cleaned.replace(QRegularExpression("[^a-zA-Z0-9\\s]"), "");
    return cleaned.split(" ", Qt::SkipEmptyParts);
}

// ==================== RecommendationManager Implementation ====================

RecommendationManager::RecommendationManager(QObject *parent)
    : QObject(parent)
    , m_workerThread(new QThread(this))
    , m_worker(new RecommendationWorker())
    , m_recommendationTimer(new QTimer(this))
{
    m_worker->moveToThread(m_workerThread);
    m_workerThread->start();

    connect(m_worker, &RecommendationWorker::recommendationsReady,
            this, &RecommendationManager::onRecommendationsReady);

    m_recommendationTimer->setSingleShot(true);
    connect(m_recommendationTimer, &QTimer::timeout,
            this, &RecommendationManager::onRecommendationTimerTimeout);

    qDebug() << "RecommendationManager initialized with REAL YouTube fetching";
}

RecommendationManager::~RecommendationManager() {
    m_workerThread->quit();
    m_workerThread->wait();
    qDebug() << "RecommendationManager destroyed";
}

QVariantList RecommendationManager::getRecommendations() const {
    QMutexLocker locker(&m_dataMutex);
    QVariantList result;

    for (const auto& rec : m_recommendations) {
        QVariantMap item;
        item["title"] = rec.title;
        item["artist"] = rec.artist;
        item["thumbnailUrl"] = rec.thumbnailUrl;
        item["searchQuery"] = rec.searchQuery;
        item["similarityScore"] = rec.similarityScore;
        result.append(item);
    }

    return result;
}

int RecommendationManager::recommendationCount() const {
    QMutexLocker locker(&m_dataMutex);
    return m_recommendations.size();
}

void RecommendationManager::startRecommendationTimer(const QString& title, const QString& artist) {
    // Check if we've already processed this song
    if (m_lastProcessedTitle == title && m_lastProcessedArtist == artist) {
        qDebug() << "========================================";
        qDebug() << "SKIPPING - Already generated recommendations for this song";
        qDebug() << "Title:" << title;
        qDebug() << "Artist:" << artist;
        qDebug() << "========================================";
        return;
    }

    cancelRecommendationTimer();

    m_pendingTitle = title;
    m_pendingArtist = artist;

    m_recommendationTimer->start(TIMER_DELAY_MS);

    qDebug() << "========================================";
    qDebug() << "RECOMMENDATION TIMER STARTED";
    qDebug() << "Title:" << title;
    qDebug() << "Artist:" << artist;
    qDebug() << "Delay:" << TIMER_DELAY_MS << "ms (" << (TIMER_DELAY_MS/1000) << "seconds)";
    qDebug() << "========================================";
}

void RecommendationManager::cancelRecommendationTimer() {
    if (m_recommendationTimer->isActive()) {
        m_recommendationTimer->stop();
        qDebug() << "Cancelled recommendation timer";
    }
}

void RecommendationManager::playRecommendedSong(int index) {
    QMutexLocker locker(&m_dataMutex);
    if (index >= 0 && index < m_recommendations.size()) {
        const RecommendedSong& song = m_recommendations[index];
        locker.unlock();

        qDebug() << "Playing recommended song:" << song.title;
        emit playYouTubeSong(song.searchQuery);
    } else {
        qWarning() << "Invalid recommendation index:" << index << "Total:" << m_recommendations.size();
    }
}

void RecommendationManager::clearRecommendations() {
    QMutexLocker locker(&m_dataMutex);
    m_recommendations.clear();
    locker.unlock();

    // Reset tracking so the same song can generate recommendations again if needed
    m_lastProcessedTitle.clear();
    m_lastProcessedArtist.clear();

    qDebug() << "Cleared all recommendations and reset tracking";
    emit recommendationsChanged();
}

void RecommendationManager::addTestRecommendations() {
    qDebug() << "=== FETCHING REAL TEST RECOMMENDATIONS ===";

    // Create a temporary worker to fetch test data
    QThread thread;
    RecommendationWorker worker;
    worker.moveToThread(&thread);
    thread.start();

    // Fetch real YouTube data for popular songs
    QList<RecommendedSong> testRecs;

    QStringList testQueries = {
        "Queen Bohemian Rhapsody",
        "Led Zeppelin Stairway to Heaven",
        "Eagles Hotel California",
        "Nirvana Smells Like Teen Spirit",
        "The Beatles Hey Jude"
    };

    for (const QString& query : testQueries) {
        QMetaObject::invokeMethod(&worker, [&worker, query, &testRecs]() {
            QList<RecommendedSong> results = worker.fetchYouTubeResults(query, 1);
            if (!results.isEmpty()) {
                testRecs.append(results.first());
            }
        }, Qt::BlockingQueuedConnection);

        QThread::msleep(300); // Small delay between requests
    }

    thread.quit();
    thread.wait();

    if (!testRecs.isEmpty()) {
        addRecommendations(testRecs);
        qDebug() << "Added" << testRecs.size() << "real test recommendations";
    } else {
        qWarning() << "Failed to fetch test recommendations";
    }
}

void RecommendationManager::forceRefresh() {
    qDebug() << "Force refresh called, current count:" << m_recommendations.size();
    emit recommendationsChanged();
}

void RecommendationManager::onRecommendationTimerTimeout() {
    QMutexLocker locker(&m_dataMutex);
    QString genre = extractGenreFromArtist(m_pendingArtist);
    PlayedSong playedSong(m_pendingTitle, m_pendingArtist, genre);
    m_playedSongs.append(playedSong);

    while (m_playedSongs.size() > 50) {
        m_playedSongs.removeFirst();
    }

    QList<PlayedSong> historyCopy = m_playedSongs;
    locker.unlock();

    qDebug() << "Generating REAL recommendations for:" << m_pendingTitle << "by" << m_pendingArtist;

    QMetaObject::invokeMethod(m_worker, "generateRecommendations",
                              Qt::QueuedConnection,
                              Q_ARG(PlayedSong, playedSong),
                              Q_ARG(QList<PlayedSong>, historyCopy));
}

void RecommendationManager::onRecommendationsReady(const QList<RecommendedSong>& newRecommendations) {
    qDebug() << "=== REAL RECOMMENDATIONS READY ===";
    qDebug() << "Received" << newRecommendations.size() << "new recommendations";

    for (int i = 0; i < newRecommendations.size(); ++i) {
        qDebug() << "  [" << i << "]" << newRecommendations[i].title
                 << "by" << newRecommendations[i].artist
                 << "- Thumbnail:" << (newRecommendations[i].thumbnailUrl.isEmpty() ? "NONE" : "YES");
    }

    addRecommendations(newRecommendations);

    qDebug() << "Total recommendations now:" << m_recommendations.size();

    emit recommendationsChanged();

    qDebug() << "Emitted recommendationsChanged signal";
}

void RecommendationManager::addRecommendations(const QList<RecommendedSong>& newRecs) {
    QMutexLocker locker(&m_dataMutex);

    for (const auto& rec : newRecs) {
        m_recommendations.enqueue(rec);
    }

    ensureQueueSize();

    qDebug() << "Added recommendations, queue size:" << m_recommendations.size();
}

void RecommendationManager::ensureQueueSize() {
    while (m_recommendations.size() > MAX_RECOMMENDATIONS) {
        for (int i = 0; i < RECOMMENDATIONS_PER_SONG && !m_recommendations.isEmpty(); ++i) {
            m_recommendations.dequeue();
        }
    }
}

QString RecommendationManager::extractGenreFromArtist(const QString& artist) const {
    QString lowerArtist = artist.toLower();

    if (lowerArtist.contains("rock") || lowerArtist.contains("metal") || lowerArtist.contains("punk")) {
        return "Rock";
    } else if (lowerArtist.contains("pop") || lowerArtist.contains("boy") || lowerArtist.contains("girl")) {
        return "Pop";
    } else if (lowerArtist.contains("hip") || lowerArtist.contains("rap") || lowerArtist.contains("hop")) {
        return "Hip Hop";
    } else if (lowerArtist.contains("electronic") || lowerArtist.contains("edm") || lowerArtist.contains("dj")) {
        return "Electronic";
    } else if (lowerArtist.contains("jazz") || lowerArtist.contains("blues")) {
        return "Jazz";
    } else if (lowerArtist.contains("country") || lowerArtist.contains("folk")) {
        return "Country";
    } else if (lowerArtist.contains("classical") || lowerArtist.contains("orchestra")) {
        return "Classical";
    }

    return "Unknown";
}
