// ===== LibraryModel.h (Complete Rewrite) =====

#ifndef LIBRARYMODEL_H
#define LIBRARYMODEL_H

#include <QAbstractListModel>
#include <QObject>
#include <vector>
#include <set>
#include "Track.h"

class LibraryModel : public QAbstractListModel {
    Q_OBJECT

    // Properties exposed to QML
    Q_PROPERTY(int totalTracks READ totalTracks NOTIFY statsChanged)
    Q_PROPERTY(int totalArtists READ totalArtists NOTIFY statsChanged)
    Q_PROPERTY(int totalAlbums READ totalAlbums NOTIFY statsChanged)
    Q_PROPERTY(qint64 totalDuration READ totalDuration NOTIFY statsChanged)

public:
    // Roles for QML access
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
    ~LibraryModel() override = default;

    // QAbstractListModel interface implementation
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Property getters
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
    Q_INVOKABLE void clearLibrary();
    Q_INVOKABLE QString getTrackPath(int index) const;

signals:
    void statsChanged();
    void scanProgressChanged(int current, int total);
    void errorOccurred(const QString& message);

private:
    // Helper methods
    void updateDisplayedTracks();
    void computeStats();
    bool trackMatchesFilter(const Track& track) const;
    void sortDisplayedTracks(const QString& field);

    // All tracks discovered on scan
    std::vector<Track> m_allTracks;

    // Current subset displayed (after search/filter/sort)
    std::vector<Track> m_displayedTracks;

    // Filter and search state
    QString m_currentFilter;
    QString m_searchQuery;
    QString m_lastSortField;

    // Statistics
    int m_totalTracks = 0;
    int m_totalArtists = 0;
    int m_totalAlbums = 0;
    qint64 m_totalDuration = 0;

    // Scan limit to prevent hanging on large directories
    static constexpr int m_scanItemLimit = 10000;
};

#endif // LIBRARYMODEL_H
