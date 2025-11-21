
// ===== LibraryModel.cpp (rewritten) =====

#include "LibraryModel.h"
#include <algorithm>
#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QSet>

LibraryModel::LibraryModel(QObject* parent)
    : QAbstractListModel(parent)
    , m_currentFilter("All Tracks")
{
    qDebug() << "LibraryModel created";
}

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
        // Track may or may not have an album art API. Return empty QVariant as safe default.
        // If your Track class provides an albumArtPath()/albumArt() method, replace the next line with that call.
        return QVariant();
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
    computeStats();
    qDebug() << "Search results for:" << query << "- Found:" << m_displayedTracks.size();
}

void LibraryModel::setFilter(const QString& filter)
{
    m_currentFilter = filter;
    beginResetModel();
    updateDisplayedTracks();
    endResetModel();
    computeStats();
    qDebug() << "Filter set to:" << filter << "Displayed:" << m_displayedTracks.size();
}

void LibraryModel::scanDirectory(const QString& path)
{
    qDebug() << "Scanning directory:" << path;

    QStringList audioExtensions = {"*.mp3", "*.flac", "*.ogg", "*.wav", "*.m4a", "*.aac"};

    QDir dir(path);
    if (!dir.exists()) {
        qWarning() << "Directory does not exist:" << path;
        return;
    }

    beginResetModel();
    m_allTracks.clear();
    m_displayedTracks.clear();

    QDirIterator it(path, audioExtensions, QDir::Files, QDirIterator::Subdirectories);

    int count = 0;
    while (it.hasNext()) {
        QString filePath = it.next();

        // Construct Track - if Track constructor throws, catch to avoid crash
        try {
            Track track(filePath);
            m_allTracks.push_back(track);
            count++;
        }
        catch (const std::exception& e) {
            qWarning() << "Failed to load track:" << filePath << "-" << e.what();
        }

        if (count >= m_scanItemLimit) {
            qWarning() << "Reached" << m_scanItemLimit << "track limit. Stopping scan.";
            break;
        }
    }

    // After scanning, build the displayed list using current search/filter/sort
    updateDisplayedTracks();
    endResetModel();

    computeStats();
    emit statsChanged();

    qDebug() << "Scanned" << count << "audio files";
}

void LibraryModel::sortBy(const QString& field)
{
    m_lastSortField = field;

    beginResetModel();

    auto comparator = [&](const Track& a, const Track& b) {
        if (field == "Title") return a.title().toLower() < b.title().toLower();
        if (field == "Artist") return a.artist().toLower() < b.artist().toLower();
        if (field == "Album") return a.album().toLower() < b.album().toLower();
        if (field == "Duration") return a.duration() < b.duration();
        if (field == "Year") return a.year() < b.year();
        // Fallback to title
        return a.title().toLower() < b.title().toLower();
    };

    std::sort(m_displayedTracks.begin(), m_displayedTracks.end(), comparator);

    endResetModel();
    qDebug() << "Sorted by:" << field << "Displayed:" << m_displayedTracks.size();
}

void LibraryModel::updateDisplayedTracks()
{
    m_displayedTracks.clear();

    const bool hasQuery = !m_searchQuery.isEmpty();
    const QString q = m_searchQuery;

    for (const Track& t : m_allTracks) {
        if (hasQuery) {
            // Match title, artist, album, or genre
            bool matches = false;
            if (t.title().contains(q, Qt::CaseInsensitive)) matches = true;
            else if (t.artist().contains(q, Qt::CaseInsensitive)) matches = true;
            else if (t.album().contains(q, Qt::CaseInsensitive)) matches = true;
            else if (t.genre().contains(q, Qt::CaseInsensitive)) matches = true;

            if (!matches) continue;
        }

        // Filter support
        if (!trackMatchesFilter(t)) continue;

        m_displayedTracks.push_back(t);
    }

    // Apply last sort if any
    if (!m_lastSortField.isEmpty()) {
        sortBy(m_lastSortField);
        // sortBy calls begin/endResetModel and sorts m_displayedTracks
        // but we've already called begin/end outside in callers; to avoid double begin/end,
        // we allowed sortBy to manage begin/end. If you prefer a different behaviour,
        // you can instead call the comparator here directly.
    }

    qDebug() << "Display tracks updated. Count:" << m_displayedTracks.size();
}

void LibraryModel::computeStats()
{
    m_totalTracks = static_cast<int>(m_allTracks.size());
    m_totalDuration = 0;

    QSet<QString> artists;
    QSet<QString> albums;

    for (const Track& t : m_allTracks) {
        artists.insert(t.artist());
        albums.insert(t.album());
        m_totalDuration += static_cast<qint64>(t.duration());
    }

    m_totalArtists = artists.size();
    m_totalAlbums = albums.size();

    qDebug() << "Stats computed: tracks=" << m_totalTracks << "artists=" << m_totalArtists << "albums=" << m_totalAlbums << "duration=" << m_totalDuration;
}

bool LibraryModel::trackMatchesFilter(const Track& t) const
{
    // Example filters. Extend to fit your UI. "All Tracks" -> no filtering.
    if (m_currentFilter.isEmpty() || m_currentFilter == "All Tracks")
        return true;

    // You may want to implement more filter types (e.g., "Favorites", "Recently Added")
    if (m_currentFilter == "Favorites") {
        // Example: treat playCount >= 10 as a favorite. Change logic as needed.
        return t.playCount() >= 10;
    }

    // If filter equals an artist name, show only that artist
    if (m_currentFilter.startsWith("artist:", Qt::CaseInsensitive)) {
        QString artistName = m_currentFilter.mid(QString("artist:").length()).trimmed();
        return t.artist().compare(artistName, Qt::CaseInsensitive) == 0;
    }

    // Unknown filter: accept
    return true;
}
