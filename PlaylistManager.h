// PlaylistManager.h - Demonstrates Friend Class
#ifndef PLAYLISTMANAGER_H
#define PLAYLISTMANAGER_H

#include "Track.h"
#include <QList>
#include <QString>

class PlaylistManager
{
public:
    PlaylistManager(const QString& name);

    void addTrack(const Track& track);
    void removeTrack(int index);

    // Friend class can access private members of Track
    void printAllTrackPaths() const;

    int trackCount() const { return m_tracks.size(); }
    Track getTrack(int index) const;

private:
    QString m_name;
    QList<Track> m_tracks;
};

#endif // PLAYLISTMANAGER_H
