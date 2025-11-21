// ===== LibraryModel.h (rewritten) =====


#ifndef LIBRARYMODEL_H
#define LIBRARYMODEL_H


#include <QAbstractListModel>
#include <QObject>
#include <vector>
#include <set>
#include "Track.h" // Keep your Track API -- this file assumes Track has: path(), title(), artist(), album(), genre(), year(), duration(), playCount()


class LibraryModel : public QAbstractListModel {
    Q_OBJECT


    Q_PROPERTY(int totalTracks READ totalTracks NOTIFY statsChanged)
    Q_PROPERTY(int totalArtists READ totalArtists NOTIFY statsChanged)
    Q_PROPERTY(int totalAlbums READ totalAlbums NOTIFY statsChanged)
    Q_PROPERTY(qint64 totalDuration READ totalDuration NOTIFY statsChanged)


public:
    enum TrackRoles {
        PathRole = Qt::UserRole + 1,
        TitleRole,
        ArtistRole,
        AlbumRole,
        GenreRole,
        YearRole,
        DurationRole,
        PlayCountRole,
        AlbumArtRole
    };


    explicit LibraryModel(QObject* parent = nullptr);


    // QAbstractListModel interface
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;


    // Properties (readers)
    int totalTracks() const { return m_totalTracks; }
    int totalArtists() const { return m_totalArtists; }
    int totalAlbums() const { return m_totalAlbums; }
    qint64 totalDuration() const { return m_totalDuration; }


    // Methods callable from QML
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void search(const QString& query);
    Q_INVOKABLE void setFilter(const QString& filter);
    Q_INVOKABLE void scanDirectory(const QString& path);
    Q_INVOKABLE void sortBy(const QString& field);


signals:
    void statsChanged();


private:
    // All tracks discovered on scan
    std::vector<Track> m_allTracks;
    // Current subset displayed (after search/filter/sort)
    std::vector<Track> m_displayedTracks;


    QString m_currentFilter;
    QString m_searchQuery;
    QString m_lastSortField;


#endif // LIBRARYMODEL_H
