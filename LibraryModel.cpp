// ===== LibraryModel.cpp (Complete Rewrite) =====

#include "LibraryModel.h"
#include "AudioException.h"
#include <algorithm>
#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QSet>

LibraryModel::LibraryModel(QObject* parent)
    : QAbstractListModel(parent)
    , m_currentFilter("All Tracks")
{
    qDebug() << "LibraryModel created";
}

// ==================== QAbstractListModel Interface ====================

int LibraryModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0;

    return static_cast<int>(m_displayedTracks.size());
}

QVariant LibraryModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid())
        return QVariant();

    int row = index.row();
    if (row < 0 || row >= static_cast<int>(m_displayedTracks.size()))
        return QVariant();

    const Track& track = m_displayedTracks[row];

    switch (role) {
    case PathRole:
        return track.path();
    case TitleRole:
        return track.title();
    case ArtistRole:
        return track.artist();
    case AlbumRole:
        return track.album();
    case GenreRole:
        return track.genre();
    case YearRole:
        return track.year();
    case DurationRole:
        return static_cast<qint64>(track.duration());
    case PlayCountRole:
        return track.playCount();
    case AlbumArtRole:
        return QString();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> LibraryModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[PathRole] = "path";
    roles[TitleRole] = "title";
    roles[ArtistRole] = "artist";
    roles[AlbumRole] = "album";
    roles[GenreRole] = "genre";
    roles[YearRole] = "year";
    roles[DurationRole] = "duration";
    roles[PlayCountRole] = "playCount";
    roles[AlbumArtRole] = "albumArt";
    return roles;
}

// ==================== Public Methods ====================

void LibraryModel::refresh()
{
    beginResetModel();
    updateDisplayedTracks();
    endResetModel();

    computeStats();
    emit statsChanged();

    qDebug() << "Library refreshed. Displayed tracks:" << m_displayedTracks.size();
}

void LibraryModel::search(const QString& query)
{
    m_searchQuery = query.trimmed();

    beginResetModel();
    updateDisplayedTracks();
    endResetModel();

    qDebug() << "Search results for:" << query << "- Found:" << m_displayedTracks.size();
}

void LibraryModel::setFilter(const QString& filter)
{
    if (m_currentFilter == filter)
        return;

    m_currentFilter = filter;

    beginResetModel();
    updateDisplayedTracks();
    endResetModel();

    qDebug() << "Filter set to:" << filter << "- Displayed:" << m_displayedTracks.size();
}

void LibraryModel::scanDirectory(const QString& path)
{
    qDebug() << "Scanning directory:" << path;

    QStringList audioExtensions = {"*.mp3", "*.flac", "*.ogg", "*.wav", "*.m4a", "*.aac"};

    QDir dir(path);
    if (!dir.exists()) {
        qWarning() << "Directory does not exist:" << path;
        emit errorOccurred("Directory does not exist: " + path);
        return;
    }

    // Clear existing tracks
    beginResetModel();
    m_allTracks.clear();
    m_displayedTracks.clear();
    endResetModel();

    QDirIterator it(path, audioExtensions, QDir::Files, QDirIterator::Subdirectories);

    int count = 0;
    int totalFound = 0;

    // First pass: count total files
    QDirIterator countIt(path, audioExtensions, QDir::Files, QDirIterator::Subdirectories);
    while (countIt.hasNext() && totalFound < m_scanItemLimit) {
        countIt.next();
        totalFound++;
    }

    qDebug() << "Found" << totalFound << "audio files to scan";

    // Second pass: load tracks
    while (it.hasNext()) {
        QString filePath = it.next();

        try {
            Track track(filePath);
            m_allTracks.push_back(track);
            count++;

            // Emit progress
            if (count % 10 == 0) {
                emit scanProgressChanged(count, totalFound);
            }
        }
        catch (const AudioException& e) {
            qWarning() << "Failed to load track:" << filePath << "-" << e.what();
        }
        catch (const std::exception& e) {
            qWarning() << "Failed to load track:" << filePath << "-" << e.what();
        }

        if (count >= m_scanItemLimit) {
            qWarning() << "Reached" << m_scanItemLimit << "track limit. Stopping scan.";
            break;
        }
    }

    // Update displayed list
    beginResetModel();
    updateDisplayedTracks();
    endResetModel();

    computeStats();
    emit statsChanged();
    emit scanProgressChanged(count, totalFound);

    qDebug() << "Scan complete. Loaded" << count << "tracks";
}

void LibraryModel::sortBy(const QString& field)
{
    if (field.isEmpty())
        return;

    m_lastSortField = field;

    beginResetModel();
    sortDisplayedTracks(field);
    endResetModel();

    qDebug() << "Sorted by:" << field << "- Tracks:" << m_displayedTracks.size();
}

void LibraryModel::clearLibrary()
{
    beginResetModel();
    m_allTracks.clear();
    m_displayedTracks.clear();
    endResetModel();

    m_searchQuery.clear();
    m_currentFilter = "All Tracks";
    m_lastSortField.clear();

    computeStats();
    emit statsChanged();

    qDebug() << "Library cleared";
}

QString LibraryModel::getTrackPath(int index) const
{
    if (index >= 0 && index < static_cast<int>(m_displayedTracks.size())) {
        return m_displayedTracks[index].path();
    }
    return QString();
}

// ==================== Private Helper Methods ====================

void LibraryModel::updateDisplayedTracks()
{
    m_displayedTracks.clear();

    const bool hasQuery = !m_searchQuery.isEmpty();
    const QString lowerQuery = m_searchQuery.toLower();

    for (const Track& track : m_allTracks) {
        // Apply search filter
        if (hasQuery) {
            bool matches = false;

            if (track.title().toLower().contains(lowerQuery))
                matches = true;
            else if (track.artist().toLower().contains(lowerQuery))
                matches = true;
            else if (track.album().toLower().contains(lowerQuery))
                matches = true;
            else if (track.genre().toLower().contains(lowerQuery))
                matches = true;

            if (!matches)
                continue;
        }

        // Apply category filter
        if (!trackMatchesFilter(track))
            continue;

        m_displayedTracks.push_back(track);
    }

    // Apply last sort if any
    if (!m_lastSortField.isEmpty()) {
        sortDisplayedTracks(m_lastSortField);
    }

    qDebug() << "Displayed tracks updated. Count:" << m_displayedTracks.size();
}

void LibraryModel::computeStats()
{
    m_totalTracks = static_cast<int>(m_allTracks.size());
    m_totalDuration = 0;

    QSet<QString> artists;
    QSet<QString> albums;

    for (const Track& track : m_allTracks) {
        // Collect unique artists and albums
        QString artist = track.artist();
        QString album = track.album();

        if (!artist.isEmpty() && artist != "Unknown Artist")
            artists.insert(artist);

        if (!album.isEmpty() && album != "Unknown Album")
            albums.insert(album);

        m_totalDuration += static_cast<qint64>(track.duration());
    }

    m_totalArtists = artists.size();
    m_totalAlbums = albums.size();

    qDebug() << "Stats - Tracks:" << m_totalTracks
             << "Artists:" << m_totalArtists
             << "Albums:" << m_totalAlbums
             << "Duration:" << m_totalDuration << "ms";
}

bool LibraryModel::trackMatchesFilter(const Track& track) const
{
    // "All Tracks" shows everything
    if (m_currentFilter.isEmpty() || m_currentFilter == "All Tracks")
        return true;

    // Filter by category
    if (m_currentFilter == "Artists") {
        // When viewing by artists, show all tracks (grouping handled by view)
        return true;
    }

    if (m_currentFilter == "Albums") {
        // When viewing by albums, show all tracks (grouping handled by view)
        return true;
    }

    if (m_currentFilter == "Genres") {
        // When viewing by genres, show all tracks (grouping handled by view)
        return true;
    }

    // Filter by favorites (example: play count >= 5)
    if (m_currentFilter == "Favorites") {
        return track.playCount() >= 5;
    }

    // Filter by recently played (example: played in last 7 days)
    if (m_currentFilter == "Recently Played") {
        QDateTime lastPlayed = track.lastPlayed();
        if (lastPlayed.isValid()) {
            qint64 daysAgo = lastPlayed.daysTo(QDateTime::currentDateTime());
            return daysAgo <= 7;
        }
        return false;
    }

    // Custom filter matching artist/album/genre name
    if (m_currentFilter.startsWith("artist:", Qt::CaseInsensitive)) {
        QString artistName = m_currentFilter.mid(7).trimmed();
        return track.artist().compare(artistName, Qt::CaseInsensitive) == 0;
    }

    if (m_currentFilter.startsWith("album:", Qt::CaseInsensitive)) {
        QString albumName = m_currentFilter.mid(6).trimmed();
        return track.album().compare(albumName, Qt::CaseInsensitive) == 0;
    }

    if (m_currentFilter.startsWith("genre:", Qt::CaseInsensitive)) {
        QString genreName = m_currentFilter.mid(6).trimmed();
        return track.genre().compare(genreName, Qt::CaseInsensitive) == 0;
    }

    // Unknown filter: accept all
    return true;
}

void LibraryModel::sortDisplayedTracks(const QString& field)
{
    if (field.isEmpty())
        return;

    if (field == "Title") {
        std::sort(m_displayedTracks.begin(), m_displayedTracks.end(),
                  [](const Track& a, const Track& b) {
                      return a.title().toLower() < b.title().toLower();
                  });
    }
    else if (field == "Artist") {
        std::sort(m_displayedTracks.begin(), m_displayedTracks.end(),
                  [](const Track& a, const Track& b) {
                      return a.artist().toLower() < b.artist().toLower();
                  });
    }
    else if (field == "Album") {
        std::sort(m_displayedTracks.begin(), m_displayedTracks.end(),
                  [](const Track& a, const Track& b) {
                      return a.album().toLower() < b.album().toLower();
                  });
    }
    else if (field == "Duration") {
        std::sort(m_displayedTracks.begin(), m_displayedTracks.end(),
                  [](const Track& a, const Track& b) {
                      return a.duration() < b.duration();
                  });
    }
    else if (field == "Year") {
        std::sort(m_displayedTracks.begin(), m_displayedTracks.end(),
                  [](const Track& a, const Track& b) {
                      return a.year() < b.year();
                  });
    }
    else if (field == "PlayCount") {
        std::sort(m_displayedTracks.begin(), m_displayedTracks.end(),
                  [](const Track& a, const Track& b) {
                      return a.playCount() > b.playCount(); // Descending order
                  });
    }
    else {
        // Default to title sort
        std::sort(m_displayedTracks.begin(), m_displayedTracks.end(),
                  [](const Track& a, const Track& b) {
                      return a.title().toLower() < b.title().toLower();
                  });
    }
}

bool LibraryModel::saveAsM3UPlaylist(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Could not open file for writing:" << filePath;
        emit errorOccurred("Failed to save playlist: Could not create file");
        return false;
    }

    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);

    // Write M3U header
    out << "#EXTM3U\n";

    // Write each track
    for (const Track& track : m_displayedTracks) {
        // Format: #EXTINF:duration_in_seconds,Artist - Title
        qint64 durationSeconds = track.duration() / 1000;
        out << "#EXTINF:" << durationSeconds << ","
            << track.artist() << " - " << track.title() << "\n";
        out << track.path() << "\n";
    }

    file.close();

    qDebug() << "Saved" << m_displayedTracks.size() << "tracks to playlist:" << filePath;
    return true;
}
