import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: libraryView
    color: "#1E1E1E"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Search bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#282828"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Search library..."

                    background: Rectangle {
                        radius: 20
                        color: "#3E3E3E"
                        border.color: searchField.activeFocus ? "#1DB954" : "#4E4E4E"
                        border.width: 1
                    }

                    onTextChanged: {
                        libraryModel.search(text)
                    }
                }

                ComboBox {
                    id: filterCombo
                    Layout.preferredWidth: 150
                    model: ["All Tracks", "Artists", "Albums", "Genres"]

                    onCurrentTextChanged: {
                        libraryModel.setFilter(currentText)
                    }
                }

                Button {
                    text: "Scan Library"
                    onClicked: scanDialog.open()
                }
            }
        }

        // Statistics bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#242424"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 20

                Label {
                    text: libraryModel.totalTracks + " tracks"
                    color: "#B3B3B3"
                }

                Label {
                    text: libraryModel.totalArtists + " artists"
                    color: "#B3B3B3"
                }

                Label {
                    text: libraryModel.totalAlbums + " albums"
                    color: "#B3B3B3"
                }

                Label {
                    text: "Total: " + formatDuration(libraryModel.totalDuration)
                    color: "#B3B3B3"
                }

                Item { Layout.fillWidth: true }
            }
        }

        // Track list
        ListView {
            id: trackListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: libraryModel

            delegate: ItemDelegate {
                width: trackListView.width
                height: 50

                background: Rectangle {
                    color: parent.hovered ? "#2A2A2A" : "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    // Album art thumbnail
                    Image {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        source: model.albumArt || "qrc:/assests/default.jpg"
                        fillMode: Image.PreserveAspectCrop
                    }

                    // Track info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            text: model.title
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.artist + " • " + model.album
                            color: "#B3B3B3"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                    }

                    // Duration
                    Label {
                        text: formatDuration(model.duration)
                        color: "#B3B3B3"
                        font.pixelSize: 12
                    }

                    // Play count
                    Label {
                        text: "♫ " + model.playCount
                        color: "#B3B3B3"
                        font.pixelSize: 12
                    }
                }

                onDoubleClicked: {
                    audioController.openFile(model.path)
                }

                // Context menu
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton

                    onClicked: {
                        contextMenu.popup()
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }
    }

    // Context menu
    Menu {
        id: contextMenu

        MenuItem {
            text: "Play"
            onTriggered: {
                // Play selected track
            }
        }

        MenuItem {
            text: "Add to Queue"
            onTriggered: {
                // Add to queue
            }
        }

        MenuItem {
            text: "Add to Playlist"
            onTriggered: playlistDialog.open()
        }

        MenuSeparator {}

        MenuItem {
            text: "Show in Explorer"
            onTriggered: {
                // Open file location
            }
        }

        MenuItem {
            text: "Edit Tags"
            onTriggered: tagEditorDialog.open()
        }

        MenuItem {
            text: "Delete from Library"
            onTriggered: {
                // Remove track
            }
        }
    }

    function formatDuration(ms) {
        var totalSeconds = Math.floor(ms / 1000)
        var minutes = Math.floor(totalSeconds / 60)
        var seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }
}
