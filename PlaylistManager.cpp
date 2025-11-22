// PlaylistManager.cpp
#include "PlaylistManager.h"
#include <QDebug>

PlaylistManager::PlaylistManager(const QString& name)
    : m_name(name)
{
    qDebug() << "Playlist created:" << m_name;
}

void PlaylistManager::addTrack(const Track& track)
{
    m_tracks.append(track);
    qDebug() << "Track added to playlist:" << track.title();
}

void PlaylistManager::removeTrack(int index)
{
    if (index >= 0 && index < m_tracks.size()) {
        qDebug() << "Removing track:" << m_tracks[index].title();
        m_tracks.removeAt(index);
    }
}

// Friend class can access private members of Track directly
void PlaylistManager::printAllTrackPaths() const
{
    qDebug() << "========== Playlist:" << m_name << "==========";
    for (const Track& track : m_tracks) {
        // Can access private m_path because PlaylistManager is a friend
        qDebug() << "  - Path:" << track.m_path;
    }
    qDebug() << "==========================================";
}

Track PlaylistManager::getTrack(int index) const
{
    if (index >= 0 && index < m_tracks.size()) {
        return m_tracks[index];
    }
    return Track();
}
