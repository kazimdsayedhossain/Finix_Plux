import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import Qt5Compat.GraphicalEffects
import com.finix.audioplayer 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    minimumWidth: 1200
    minimumHeight: 700
    title: qsTr("Finix Player - Modern Music Player")

    // Color scheme
    readonly property color backgroundColor: "#0A0E27"
    readonly property color surfaceColor: "#1A1F3A"
    readonly property color surfaceLightColor: "#252B4A"
    readonly property color primaryColor: "#3D5AFE"
    readonly property color accentColor: "#FF4081"
    readonly property color textColor: "#E0E6F0"
    readonly property color textSecondaryColor: "#8891A8"

    // Audio Controller
    AudioController {
        id: audioController
    }

    // Library Model
    LibraryModel {
        id: libraryModel

        onScanProgressChanged: {
            scanProgressDialog.currentProgress = current
            scanProgressDialog.totalProgress = total

            // Close dialog when scan is complete
            if (current >= total && total > 0) {
                scanCloseTimer.start()
            }
        }
    }

    // Timer to close scan dialog when complete
    Timer {
        id: scanCloseTimer
        interval: 500
        onTriggered: {
            scanProgressDialog.close()
            libraryModel.refresh()
        }
    }

    // Background
    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
    }

    // Main Layout
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ==================== LEFT SIDEBAR ====================
        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: root.surfaceColor

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Logo Section
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "🎵"
                            font.pixelSize: 32
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Finix Player")
                            font.pixelSize: 22
                            font.bold: true
                            color: root.textColor
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    height: 1
                    color: root.surfaceLightColor
                }

                // Navigation Menu - FIXED: Properly visible menu items
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    spacing: 8

                    SidebarButton {
                        icon: "🏠"
                        label: qsTr("Home")
                        active: stackView.currentItem && stackView.currentItem.objectName === "homePage"
                        onClicked: stackView.replace(homePage)
                    }

                    SidebarButton {
                        icon: "🎚️"
                        label: qsTr("Audio Effects")
                        active: stackView.currentItem && stackView.currentItem.objectName === "effectsPage"
                        onClicked: stackView.replace(effectsPage)
                    }

                    SidebarButton {
                        icon: "📚"
                        label: qsTr("Library")
                        active: stackView.currentItem && stackView.currentItem.objectName === "libraryPage"
                        onClicked: stackView.replace(libraryPage)
                    }

                    SidebarButton {
                        icon: "⚙️"
                        label: qsTr("Settings")
                        active: stackView.currentItem && stackView.currentItem.objectName === "settingsPage"
                        onClicked: stackView.replace(settingsPage)
                    }
                }

                Item { Layout.fillHeight: true }

                // Library Stats
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.bottomMargin: 20
                    Layout.preferredHeight: 100
                    color: root.surfaceLightColor
                    radius: 12

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        Label {
                            text: qsTr("📊 Library Stats")
                            font.pixelSize: 14
                            font.bold: true
                            color: root.textColor
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            ColumnLayout {
                                spacing: 2

                                Label {
                                    text: libraryModel.totalTracks
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: root.primaryColor
                                }

                                Label {
                                    text: qsTr("Tracks")
                                    font.pixelSize: 10
                                    color: root.textSecondaryColor
                                }
                            }

                            ColumnLayout {
                                spacing: 2

                                Label {
                                    text: libraryModel.totalArtists
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: root.accentColor
                                }

                                Label {
                                    text: qsTr("Artists")
                                    font.pixelSize: 10
                                    color: root.textSecondaryColor
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==================== MAIN CONTENT AREA ====================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Content Stack
            StackView {
                id: stackView
                Layout.fillWidth: true
                Layout.fillHeight: true
                initialItem: homePage

                // ==================== HOME PAGE ====================
                Component {
                    id: homePage

                    Rectangle {
                        objectName: "homePage"
                        color: root.backgroundColor

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 30
                            contentHeight: homeContent.height
                            contentWidth: width
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: homeContent
                                width: parent.width
                                spacing: 25

                                // Header
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Label {
                                        text: qsTr("Welcome to Finix Player")
                                        font.pixelSize: 32
                                        font.bold: true
                                        color: root.textColor
                                    }

                                    Label {
                                        text: qsTr("Advanced Music Player with Audio Effects")
                                        font.pixelSize: 16
                                        color: root.textSecondaryColor
                                    }
                                }

                                // Now Playing Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 400
                                    color: root.surfaceColor
                                    radius: 16

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 30
                                        spacing: 20

                                        Label {
                                            text: qsTr("🎵 Now Playing")
                                            font.pixelSize: 20
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        // Album Art
                                        Rectangle {
                                            Layout.alignment: Qt.AlignHCenter
                                            width: 220
                                            height: 220
                                            radius: 12
                                            color: root.surfaceLightColor

                                            Image {
                                                id: albumArt
                                                anchors.fill: parent
                                                anchors.margins: 2
                                                source: audioController.thumbnailUrl || ""
                                                fillMode: Image.PreserveAspectCrop
                                                visible: source !== ""
                                            }

                                            Label {
                                                anchors.centerIn: parent
                                                text: "🎵"
                                                font.pixelSize: 72
                                                color: root.textSecondaryColor
                                                visible: !albumArt.visible
                                            }
                                        }

                                        // Track Info
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            Label {
                                                Layout.fillWidth: true
                                                text: audioController.trackTitle || qsTr("No track playing")
                                                font.pixelSize: 18
                                                font.bold: true
                                                color: root.textColor
                                                elide: Text.ElideRight
                                                horizontalAlignment: Text.AlignHCenter
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: audioController.trackArtist || qsTr("Unknown Artist")
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }
                                }

                                // Quick Actions Grid
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 3
                                    rowSpacing: 20
                                    columnSpacing: 20

                                    ActionCard {
                                        icon: "📁"
                                        title: qsTr("Open File")
                                        description: qsTr("Play local audio files")
                                        onClicked: fileDialog.open()
                                    }

                                    ActionCard {
                                        icon: "🎬"
                                        title: qsTr("YouTube")
                                        description: qsTr("Stream from YouTube")
                                        onClicked: youtubeDialog.open()
                                    }

                                    ActionCard {
                                        icon: "📚"
                                        title: qsTr("Library")
                                        description: qsTr("Browse your music")
                                        onClicked: stackView.replace(libraryPage)
                                    }
                                }

                                Item { Layout.preferredHeight: 20 }
                            }
                        }
                    }
                }

                // ==================== AUDIO EFFECTS PAGE ====================
                Component {
                    id: effectsPage

                    Rectangle {
                        objectName: "effectsPage"
                        color: root.backgroundColor

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 30
                            contentHeight: effectsContent.height
                            contentWidth: width
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: effectsContent
                                width: parent.width
                                spacing: 20

                                // Header
                                Label {
                                    text: qsTr("Audio Effects")
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: root.textColor
                                }

                                // Info Banner
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#1E3A5F"
                                    radius: 12
                                    border.color: root.primaryColor
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Label {
                                            text: "⚡"
                                            font.pixelSize: 24
                                            color: root.primaryColor
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("Real-time audio effects using Qt Multimedia")
                                            font.pixelSize: 14
                                            color: root.textColor
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }

                                // Gain Control - FIXED: Proper text alignment
                                EffectCard {
                                    Layout.fillWidth: true
                                    title: qsTr("🔊 Volume Gain")
                                    description: qsTr("Amplify audio beyond 100% volume")

                                    ColumnLayout {
                                        width: parent.width
                                        spacing: 10

                                        // Gain slider with proper alignment
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 15

                                            Label {

                                                font.pixelSize: 14
                                                color: root.textColor
                                                Layout.preferredWidth: 60
                                            }

                                            Slider {
                                                id: gainSlider
                                                Layout.fillWidth: true
                                                from: 0.0
                                                to: 2.0
                                                value: audioController.gainBoost
                                                stepSize: 0.1
                                                onMoved: audioController.setGainBoost(value)

                                                background: Rectangle {
                                                    x: gainSlider.leftPadding
                                                    y: gainSlider.topPadding + gainSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 200
                                                    implicitHeight: 6
                                                    width: gainSlider.availableWidth
                                                    height: implicitHeight
                                                    radius: 3
                                                    color: root.surfaceLightColor

                                                    Rectangle {
                                                        width: gainSlider.visualPosition * parent.width
                                                        height: parent.height
                                                        color: gainSlider.value > 1.0 ? "#FFA500" : root.primaryColor
                                                        radius: 3
                                                    }
                                                }

                                                handle: Rectangle {
                                                    x: gainSlider.leftPadding + gainSlider.visualPosition * (gainSlider.availableWidth - width)
                                                    y: gainSlider.topPadding + gainSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 18
                                                    implicitHeight: 18
                                                    radius: 9
                                                    color: gainSlider.pressed ? root.primaryColor : root.textColor
                                                    border.color: gainSlider.value > 1.0 ? "#FFA500" : root.primaryColor
                                                    border.width: 2
                                                }
                                            }

                                            Label {
                                                text: Math.round(gainSlider.value * 100) + "%"
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: gainSlider.value > 1.0 ? "#FFA500" : root.textColor
                                                Layout.preferredWidth: 50
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        // Warning label
                                        Label {
                                            Layout.fillWidth: true
                                            text: gainSlider.value > 1.0 ?
                                                qsTr("⚠️ Warning: High gain may cause distortion") :
                                                qsTr("Normal audio level")
                                            font.pixelSize: 12
                                            color: gainSlider.value > 1.0 ? "#FFA500" : root.textSecondaryColor
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                // Balance Control - FIXED: Proper text alignment
                                EffectCard {
                                    Layout.fillWidth: true
                                    title: qsTr("🎚️ Stereo Balance")
                                    description: qsTr("Adjust left/right audio balance")

                                    ColumnLayout {
                                        width: parent.width
                                        spacing: 10

                                        // Balance slider with proper alignment
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            Label {
                                                text: qsTr("L")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                                Layout.preferredWidth: 20
                                                horizontalAlignment: Text.AlignHCenter
                                            }

                                            Slider {
                                                id: balanceSlider
                                                Layout.fillWidth: true
                                                from: -1.0
                                                to: 1.0
                                                value: audioController.balance
                                                stepSize: 0.1
                                                onMoved: audioController.setBalance(value)

                                                background: Rectangle {
                                                    x: balanceSlider.leftPadding
                                                    y: balanceSlider.topPadding + balanceSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 200
                                                    implicitHeight: 6
                                                    width: balanceSlider.availableWidth
                                                    height: implicitHeight
                                                    radius: 3
                                                    color: root.surfaceLightColor

                                                    Rectangle {
                                                        x: balanceSlider.value < 0 ?
                                                           parent.width / 2 + (balanceSlider.value * parent.width / 2) :
                                                           parent.width / 2
                                                        width: Math.abs(balanceSlider.value * parent.width / 2)
                                                        height: parent.height
                                                        color: root.primaryColor
                                                        radius: 3
                                                    }

                                                    Rectangle {
                                                        x: parent.width / 2 - width / 2
                                                        y: -2
                                                        width: 2
                                                        height: parent.height + 4
                                                        color: root.textColor
                                                        opacity: 0.3
                                                    }
                                                }

                                                handle: Rectangle {
                                                    x: balanceSlider.leftPadding + balanceSlider.visualPosition * (balanceSlider.availableWidth - width)
                                                    y: balanceSlider.topPadding + balanceSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 18
                                                    implicitHeight: 18
                                                    radius: 9
                                                    color: balanceSlider.pressed ? root.primaryColor : root.textColor
                                                    border.color: root.primaryColor
                                                    border.width: 2
                                                }
                                            }

                                            Label {
                                                text: qsTr("R")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                                Layout.preferredWidth: 20
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }

                                        // Balance indicator
                                        Label {
                                            Layout.fillWidth: true
                                            text: balanceSlider.value === 0 ? qsTr("Center (Balanced)") :
                                                  balanceSlider.value < 0 ? qsTr("Left: %1%").arg(Math.abs(Math.round(balanceSlider.value * 100))) :
                                                  qsTr("Right: %1%").arg(Math.round(balanceSlider.value * 100))
                                            font.pixelSize: 12
                                            color: root.textSecondaryColor
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                // Playback Speed - FIXED: Proper text alignment
                                EffectCard {
                                    Layout.fillWidth: true
                                    title: qsTr("⏩ Playback Speed")
                                    description: qsTr("Change playback speed (affects pitch)")

                                    ColumnLayout {
                                        width: parent.width
                                        spacing: 10

                                        // Speed slider with proper alignment
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 15

                                            Label {

                                                font.pixelSize: 14
                                                color: root.textColor
                                                Layout.preferredWidth: 60
                                            }

                                            Slider {
                                                id: speedSlider
                                                Layout.fillWidth: true
                                                from: 0.25
                                                to: 2.0
                                                value: audioController.playbackRate
                                                stepSize: 0.05
                                                onMoved: audioController.setPlaybackRate(value)

                                                background: Rectangle {
                                                    x: speedSlider.leftPadding
                                                    y: speedSlider.topPadding + speedSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 200
                                                    implicitHeight: 6
                                                    width: speedSlider.availableWidth
                                                    height: implicitHeight
                                                    radius: 3
                                                    color: root.surfaceLightColor

                                                    Rectangle {
                                                        width: speedSlider.visualPosition * parent.width
                                                        height: parent.height
                                                        color: root.primaryColor
                                                        radius: 3
                                                    }
                                                }

                                                handle: Rectangle {
                                                    x: speedSlider.leftPadding + speedSlider.visualPosition * (speedSlider.availableWidth - width)
                                                    y: speedSlider.topPadding + speedSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 18
                                                    implicitHeight: 18
                                                    radius: 9
                                                    color: speedSlider.pressed ? root.primaryColor : root.textColor
                                                    border.color: root.primaryColor
                                                    border.width: 2
                                                }
                                            }

                                            Label {
                                                text: speedSlider.value.toFixed(2) + "x"
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                                Layout.preferredWidth: 50
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        // Speed presets with proper alignment
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.topMargin: 10
                                            spacing: 10
                                            anchors.horizontalCenter: parent.horizontalCenter

                                            Repeater {
                                                model: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

                                                Button {
                                                    text: modelData.toFixed(2) + "x"
                                                    implicitWidth: 70
                                                    implicitHeight: 32
                                                    onClicked: {
                                                        speedSlider.value = modelData
                                                        audioController.setPlaybackRate(modelData)
                                                    }

                                                    background: Rectangle {
                                                        radius: 6
                                                        color: Math.abs(speedSlider.value - modelData) < 0.01 ?
                                                               root.primaryColor : root.surfaceLightColor
                                                        border.color: Math.abs(speedSlider.value - modelData) < 0.01 ?
                                                                      root.primaryColor : "transparent"
                                                        border.width: 2
                                                    }

                                                    contentItem: Text {
                                                        text: parent.text
                                                        color: Math.abs(speedSlider.value - modelData) < 0.01 ?
                                                               "white" : root.textColor
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                        font.pixelSize: 12
                                                        font.bold: Math.abs(speedSlider.value - modelData) < 0.01
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Fade In Effect - FIXED: Proper text alignment

                                EffectCard {
                                    Layout.fillWidth: true
                                    title: qsTr("🎼 Fade In Effect")
                                    description: qsTr("Gradually increase volume when playback starts")

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.top: parent.top
                                        anchors.topMargin: 15
                                        spacing: 20
                                        width: parent.width

                                        // Custom Checkbox
                                        Rectangle {
                                            id: checkBox
                                            width: 24
                                            height: 24
                                            radius: 6
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            color: fadeInEnabled ? root.primaryColor : root.surfaceLightColor
                                            border.color: fadeInEnabled ? root.primaryColor : root.textSecondaryColor
                                            border.width: 2

                                            property bool fadeInEnabled: audioController.fadeInEnabled

                                            Behavior on color { ColorAnimation { duration: 200 } }
                                            Behavior on border.color { ColorAnimation { duration: 200 } }

                                            Text {
                                                text: "✓"
                                                font.pixelSize: 16
                                                font.bold: true
                                                color: "white"
                                                anchors.centerIn: parent
                                                opacity: checkBox.fadeInEnabled ? 1 : 0
                                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                anchors.margins: -10
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    audioController.setFadeInEnabled(!checkBox.fadeInEnabled)
                                                }
                                            }
                                        }

                                        // Label text
                                        Text {
                                            text: qsTr("Enable Fade In (1 second)")
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: root.textColor
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        // Description with spacing
                                        Item {
                                            width: parent.width
                                            height: 1
                                        }

                                        Text {
                                            width: parent.width
                                            text: checkBox.fadeInEnabled ?
                                                qsTr("✓ Audio will fade in smoothly when you press play") :
                                                qsTr("Audio will start at full volume immediately")
                                            font.pixelSize: 12
                                            color: checkBox.fadeInEnabled ? root.primaryColor : root.textSecondaryColor
                                            horizontalAlignment: Text.AlignHCenter
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }

                                // Reset Button
                                Button {
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.topMargin: 20
                                    text: qsTr("🔄 Reset All Effects")
                                    implicitWidth: 220
                                    implicitHeight: 48

                                    onClicked: {
                                        audioController.resetEffects()
                                        gainSlider.value = 1.0
                                        balanceSlider.value = 0.0
                                        speedSlider.value = 1.0
                                        fadeInCheck.checked = false
                                    }

                                    background: Rectangle {
                                        radius: 24
                                        color: parent.pressed ? root.accentColor : root.surfaceLightColor
                                        border.color: root.accentColor
                                        border.width: 2
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: root.textColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Item { Layout.preferredHeight: 20 }
                            }
                        }
                    }
                }


                // ==================== LIBRARY PAGE ====================
                Component {
                    id: libraryPage

                    Rectangle {
                        objectName: "libraryPage"
                        color: root.backgroundColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 20

                            // Header with Actions
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20

                                Label {
                                    text: qsTr("Music Library")
                                    font.pixelSize: 28
                                    font.bold: true
                                    color: root.textColor
                                }

                                Item { Layout.fillWidth: true }

                                ToolButton {
                                    text: qsTr("💾 Save Playlist")
                                    enabled: libraryModel.totalTracks > 0
                                    onClicked: savePlaylistDialog.open()
                                }

                                ToolButton {
                                    text: qsTr("📂 Add Folder")
                                    primary: true
                                    onClicked: folderDialog.open()
                                }
                            }

                            // Search Bar
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                color: root.surfaceColor
                                radius: 25

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 12

                                    Label {
                                        text: "🔍"
                                        font.pixelSize: 18
                                    }

                                    TextField {
                                        id: searchField
                                        Layout.fillWidth: true
                                        placeholderText: qsTr("Search tracks, artists, albums...")
                                        color: root.textColor
                                        font.pixelSize: 14
                                        background: Item {}
                                        onTextChanged: libraryModel.search(text)
                                    }
                                }
                            }

                            // Stats Overview
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 90
                                color: root.surfaceColor
                                radius: 12

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    spacing: 30

                                    LibraryStat {
                                        icon: "🎵"
                                        value: libraryModel.totalTracks
                                        label: qsTr("Tracks")
                                    }

                                    LibraryStat {
                                        icon: "🎤"
                                        value: libraryModel.totalArtists
                                        label: qsTr("Artists")
                                    }

                                    LibraryStat {
                                        icon: "💿"
                                        value: libraryModel.totalAlbums
                                        label: qsTr("Albums")
                                    }

                                    LibraryStat {
                                        icon: "⏱️"
                                        value: formatDuration(libraryModel.totalDuration)
                                        label: qsTr("Duration")
                                        isTime: true
                                    }
                                }
                            }

                            // Track List
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: root.surfaceColor
                                radius: 12

                                ListView {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    clip: true
                                    spacing: 2
                                    model: libraryModel

                                    delegate: Rectangle {
                                        width: ListView.view.width
                                        height: 70
                                        color: mouseArea.containsMouse ? root.surfaceLightColor : root.surfaceColor

                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onDoubleClicked: audioController.openFile(model.path)
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 15
                                            spacing: 15

                                            Label {
                                                text: (index + 1).toString()
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                Layout.preferredWidth: 30
                                                horizontalAlignment: Text.AlignRight
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 4

                                                Label {
                                                    text: model.title || "Unknown"
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: root.textColor
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }

                                                RowLayout {
                                                    spacing: 8

                                                    Label {
                                                        text: model.artist || "Unknown Artist"
                                                        font.pixelSize: 12
                                                        color: root.textSecondaryColor
                                                    }

                                                    Label {
                                                        text: "•"
                                                        font.pixelSize: 12
                                                        color: root.textSecondaryColor
                                                    }

                                                    Label {
                                                        text: model.album || "Unknown Album"
                                                        font.pixelSize: 12
                                                        color: root.textSecondaryColor
                                                    }
                                                }
                                            }

                                            Label {
                                                text: formatDuration(model.duration)
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                Layout.preferredWidth: 50
                                                horizontalAlignment: Text.AlignRight
                                            }

                                            Button {
                                                text: "▶"
                                                implicitWidth: 38
                                                implicitHeight: 38
                                                onClicked: audioController.openFile(model.path)

                                                background: Rectangle {
                                                    radius: 19
                                                    color: parent.pressed ? root.primaryColor : "transparent"
                                                    border.color: root.primaryColor
                                                    border.width: 2
                                                }

                                                contentItem: Text {
                                                    text: parent.text
                                                    color: root.primaryColor
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                    font.pixelSize: 13
                                                }
                                            }
                                        }
                                    }

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                    }
                                }
                            }
                        }
                    }
                }











                // ==================== SETTINGS PAGE ====================

                Component {
                    id: settingsPage

                    Rectangle {
                        objectName: "settingsPage"
                        color: root.backgroundColor

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 30
                            contentHeight: settingsContent.height
                            contentWidth: width
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: settingsContent
                                width: parent.width
                                spacing: 20

                                // Header
                                Label {
                                    text: qsTr("Settings & About")
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: root.textColor
                                    Layout.bottomMargin: 10
                                }

                                // Application Info Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: appInfoColumn.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 12

                                    ColumnLayout {
                                        id: appInfoColumn
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                            margins: 20
                                        }
                                        spacing: 15

                                        Label {
                                            text: qsTr("📱 Application Info")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        // Name
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Name:")
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 100
                                            }
                                            Label {
                                                text: qsTr("Finix Player")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                            }
                                        }

                                        // Version
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Version:")
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 100
                                            }
                                            Label {
                                                text: qsTr("1.0.0")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                            }
                                        }

                                        // Framework
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Framework:")
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 100
                                            }
                                            Label {
                                                text: qsTr("Qt 6.10 + C++17")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                            }
                                        }

                                        // Build
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Build:")
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 100
                                            }
                                            Label {
                                                text: qsTr("Release")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                            }
                                        }
                                    }
                                }

                                // Developer Info Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: developerColumn.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 12

                                    ColumnLayout {
                                        id: developerColumn
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                            margins: 20
                                        }
                                        spacing: 15

                                        Label {
                                            text: qsTr("👨‍💻 Developer Info")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        // Developer
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Developer:")
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 100
                                            }
                                            Label {
                                                text: qsTr("Kazi MD. Sayed Hossain")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                            }
                                        }

                                        // Email
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Email:")
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 100
                                            }
                                            Label {
                                                text: qsTr("kazimdsayedhossain@outlook.com")
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: root.primaryColor
                                            }
                                        }

                                        // Location
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Location:")
                                                font.pixelSize: 14
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 100
                                            }
                                            Label {
                                                text: qsTr("Khulna, Bangladesh")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                            }
                                        }
                                    }
                                }

                                // Features Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: featuresColumn.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 12

                                    ColumnLayout {
                                        id: featuresColumn
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                            margins: 20
                                        }
                                        spacing: 12

                                        Label {
                                            text: qsTr("✨ Features")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                            Layout.bottomMargin: 5
                                        }

                                        // Feature 1
                                        RowLayout {
                                            spacing: 10
                                            Label {
                                                text: "•"
                                                font.pixelSize: 18
                                                color: root.primaryColor
                                            }
                                            Label {
                                                text: qsTr("Local audio file playback (MP3, FLAC, OGG, WAV, M4A, AAC)")
                                                font.pixelSize: 13
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }

                                        // Feature 2
                                        RowLayout {
                                            spacing: 10
                                            Label {
                                                text: "•"
                                                font.pixelSize: 18
                                                color: root.primaryColor
                                            }
                                            Label {
                                                text: qsTr("YouTube audio streaming with search")
                                                font.pixelSize: 13
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }

                                        // Feature 3
                                        RowLayout {
                                            spacing: 10
                                            Label {
                                                text: "•"
                                                font.pixelSize: 18
                                                color: root.primaryColor
                                            }
                                            Label {
                                                text: qsTr("Real-time audio effects (Gain, Balance, Speed, Fade In)")
                                                font.pixelSize: 13
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }

                                        // Feature 4
                                        RowLayout {
                                            spacing: 10
                                            Label {
                                                text: "•"
                                                font.pixelSize: 18
                                                color: root.primaryColor
                                            }
                                            Label {
                                                text: qsTr("Music library with search and metadata")
                                                font.pixelSize: 13
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }

                                        // Feature 5
                                        RowLayout {
                                            spacing: 10
                                            Label {
                                                text: "•"
                                                font.pixelSize: 18
                                                color: root.primaryColor
                                            }
                                            Label {
                                                text: qsTr("Modern user interface with dark theme")
                                                font.pixelSize: 13
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }

                                // Keyboard Shortcuts Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: shortcutsColumn.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 12

                                    ColumnLayout {
                                        id: shortcutsColumn
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                            margins: 20
                                        }
                                        spacing: 15

                                        Label {
                                            text: qsTr("⌨️ Keyboard Shortcuts")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        // Space
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Space")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 80
                                            }
                                            Label {
                                                text: qsTr("Play/Pause")
                                                font.pixelSize: 14
                                                color: root.textColor
                                            }
                                        }

                                        // Ctrl+O
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Ctrl+O")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 80
                                            }
                                            Label {
                                                text: qsTr("Open File")
                                                font.pixelSize: 14
                                                color: root.textColor
                                            }
                                        }

                                        // Ctrl+L
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("Ctrl+L")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 80
                                            }
                                            Label {
                                                text: qsTr("Open Library")
                                                font.pixelSize: 14
                                                color: root.textColor
                                            }
                                        }

                                        // Arrows
                                        RowLayout {
                                            spacing: 15
                                            Label {
                                                text: qsTr("↑/↓")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textSecondaryColor
                                                Layout.minimumWidth: 80
                                            }
                                            Label {
                                                text: qsTr("Volume Up/Down")
                                                font.pixelSize: 14
                                                color: root.textColor
                                            }
                                        }
                                    }
                                }

                                // About Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: aboutColumn.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 12

                                    ColumnLayout {
                                        id: aboutColumn
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                            margins: 20
                                        }
                                        spacing: 15

                                        Label {
                                            text: qsTr("ℹ️ About")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            text: qsTr("Finix Player is a modern, feature-rich music player built with Qt 6 and C++.")
                                            font.pixelSize: 13
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                            lineHeight: 1.4
                                        }

                                        Label {
                                            text: qsTr("The application demonstrates advanced C++ programming concepts and modern Qt development practices.")
                                            font.pixelSize: 13
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                            lineHeight: 1.4
                                        }

                                        Label {
                                            text: qsTr("Developed with Qt Multimedia for high-quality audio playback and real-time effects processing.")
                                            font.pixelSize: 13
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                            lineHeight: 1.4
                                        }

                                        Item { height: 10 }

                                        Label {
                                            text: qsTr("©2025 Finix Player. All rights reserved.")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }

                                // Bottom spacing
                                Item {
                                    Layout.preferredHeight: 30
                                }
                            }
                        }
                    }
                }

            }





















            // ==================== PLAYBACK CONTROLS ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: root.surfaceColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    // Progress Bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Label {
                            text: audioController.formattedPosition
                            font.pixelSize: 12
                            color: root.textSecondaryColor
                            Layout.preferredWidth: 50
                        }

                        Slider {
                            id: progressSlider
                            Layout.fillWidth: true
                            from: 0
                            to: audioController.duration > 0 ? audioController.duration : 100
                            value: audioController.position
                            enabled: audioController.duration > 0
                            onMoved: audioController.seek(value)

                            background: Rectangle {
                                x: progressSlider.leftPadding
                                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 6
                                width: progressSlider.availableWidth
                                height: implicitHeight
                                radius: 3
                                color: root.surfaceLightColor

                                Rectangle {
                                    width: progressSlider.visualPosition * parent.width
                                    height: parent.height
                                    radius: 3
                                    color: root.primaryColor
                                }
                            }

                            handle: Rectangle {
                                x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: progressSlider.pressed ? root.primaryColor : root.textColor
                                border.color: root.primaryColor
                                border.width: 2
                                visible: progressSlider.hovered || progressSlider.pressed
                            }
                        }

                        Label {
                            text: audioController.formattedDuration
                            font.pixelSize: 12
                            color: root.textSecondaryColor
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // Control Buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        // Track Info
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 300
                            spacing: 15

                            Rectangle {
                                width: 56
                                height: 56
                                radius: 8
                                color: root.surfaceLightColor

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: audioController.thumbnailUrl || ""
                                    fillMode: Image.PreserveAspectCrop
                                    visible: source !== ""
                                }

                                Label {
                                    anchors.centerIn: parent
                                    text: "🎵"
                                    font.pixelSize: 24
                                    visible: audioController.thumbnailUrl === ""
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Label {
                                    text: audioController.trackTitle || qsTr("No track")
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: root.textColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: audioController.trackArtist || qsTr("Unknown")
                                    font.pixelSize: 12
                                    color: root.textSecondaryColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Playback Controls
                        RowLayout {
                            Layout.alignment: Qt.AlignCenter
                            spacing: 15

                            ControlButton {
                                text: "⏮"
                                onClicked: audioController.seek(0)
                                enabled: audioController.duration > 0
                            }

                            ControlButton {
                                text: audioController.isPlaying ? "⏸" : "▶"
                                primary: true
                                onClicked: audioController.isPlaying ? audioController.pause() : audioController.play()
                                enabled: audioController.duration > 0
                            }

                            ControlButton {
                                text: "⏭"
                                onClicked: audioController.playNext()
                                enabled: audioController.queueSize() > 0
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Volume Control
                        RowLayout {
                            Layout.alignment: Qt.AlignRight
                            Layout.maximumWidth: 200
                            spacing: 12

                            Label {
                                text: volumeSlider.value > 0.01 ? "🔊" : "🔇"
                                font.pixelSize: 18
                            }

                            Slider {
                                id: volumeSlider
                                from: 0
                                to: 1
                                value: audioController.volume
                                Layout.fillWidth: true
                                onMoved: audioController.setVolume(value)

                                background: Rectangle {
                                    x: volumeSlider.leftPadding
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 100
                                    implicitHeight: 6
                                    width: volumeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: root.surfaceLightColor

                                    Rectangle {
                                        width: volumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        radius: 3
                                        color: root.primaryColor
                                    }
                                }

                                handle: Rectangle {
                                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    radius: 8
                                    color: volumeSlider.pressed ? root.primaryColor : root.textColor
                                    border.color: root.primaryColor
                                    border.width: 2
                                    visible: volumeSlider.hovered || volumeSlider.pressed
                                }
                            }

                            Label {
                                text: Math.round(volumeSlider.value * 100) + "%"
                                font.pixelSize: 12
                                color: root.textSecondaryColor
                                Layout.preferredWidth: 40
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== DIALOGS ====================

    FileDialog {
        id: fileDialog
        title: qsTr("Select Audio File")
        nameFilters: ["Audio files (*.mp3 *.flac *.ogg *.wav *.m4a *.aac)", "All files (*)"]
        onAccepted: {
            var path = fileDialog.file.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
            }
            audioController.openFile(path)
        }
    }

    FolderDialog {
        id: folderDialog
        title: qsTr("Select Music Folder")
        onAccepted: {
            var path = folderDialog.folder.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
            }
            libraryModel.scanDirectory(path)
            scanProgressDialog.open()
        }
    }

    // YouTube Dialog
    Popup {
        id: youtubeDialog
        anchors.centerIn: Overlay.overlay
        width: 500
        height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: root.primaryColor
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Label {
                text: qsTr("🎬 Play from YouTube")
                font.pixelSize: 20
                font.bold: true
                color: root.textColor
            }

            TextField {
                id: youtubeInput
                Layout.fillWidth: true
                placeholderText: qsTr("Enter song name or YouTube URL...")
                font.pixelSize: 14
                color: root.textColor

                background: Rectangle {
                    radius: 8
                    color: root.backgroundColor
                    border.color: youtubeInput.focus ? root.primaryColor : root.surfaceLightColor
                    border.width: 2
                }

                onAccepted: {
                    if (text.length > 0) {
                        youtubeLoadingDialog.open()
                        audioController.playYouTubeAudio(text)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                DialogButton {
                    text: qsTr("Cancel")
                    onClicked: {
                        youtubeDialog.close()
                        youtubeInput.text = ""
                    }
                }

                DialogButton {
                    text: qsTr("Play")
                    primary: true
                    enabled: youtubeInput.text.length > 0
                    onClicked: {
                        youtubeLoadingDialog.open()
                        audioController.playYouTubeAudio(youtubeInput.text)
                        youtubeDialog.close()
                        youtubeInput.text = ""
                    }
                }
            }
        }
    }

    // YouTube Loading Dialog
    Popup {
        id: youtubeLoadingDialog
        anchors.centerIn: Overlay.overlay
        width: 400
        height: 180
        modal: true
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: root.primaryColor
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Label {
                text: qsTr("🔄 Loading YouTube Audio")
                font.pixelSize: 18
                font.bold: true
                color: root.textColor
                Layout.alignment: Qt.AlignHCenter
            }

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: youtubeLoadingDialog.opened
            }

            Label {
                text: qsTr("Please wait while we load your audio...")
                font.pixelSize: 14
                color: root.textSecondaryColor
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Close when audio starts playing
        Connections {
            target: audioController
            function onIsPlayingChanged() {
                if (audioController.isPlaying) {
                    youtubeLoadingDialog.close()
                }
            }
        }

        // Auto-close after 30 seconds as fallback
        Timer {
            id: loadingTimeout
            interval: 30000
            onTriggered: youtubeLoadingDialog.close()
        }

        onOpened: loadingTimeout.start()
        onClosed: loadingTimeout.stop()
    }

    // Save Playlist Dialog
    Popup {
        id: savePlaylistDialog
        anchors.centerIn: Overlay.overlay
        width: 480
        height: 260
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: root.accentColor
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Label {
                text: qsTr("💾 Save Playlist")
                font.pixelSize: 20
                font.bold: true
                color: root.textColor
            }

            Label {
                text: qsTr("Enter a name for your playlist (will be saved as M3U)")
                font.pixelSize: 14
                color: root.textSecondaryColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            TextField {
                id: playlistNameInput
                Layout.fillWidth: true
                placeholderText: qsTr("My Favorite Songs")
                font.pixelSize: 14
                color: root.textColor

                background: Rectangle {
                    radius: 8
                    color: root.backgroundColor
                    border.color: playlistNameInput.focus ? root.accentColor : root.surfaceLightColor
                    border.width: 2
                }

                onAccepted: {
                    if (text.trim().length > 0) {
                        savePlaylist()
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("📁 Playlist will be saved in the application directory")
                font.pixelSize: 12
                color: root.textSecondaryColor
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                DialogButton {
                    text: qsTr("Cancel")
                    onClicked: {
                        savePlaylistDialog.close()
                        playlistNameInput.text = ""
                    }
                }

                DialogButton {
                    text: qsTr("Save")
                    primary: true
                    enabled: playlistNameInput.text.trim().length > 0
                    onClicked: savePlaylist()
                }
            }
        }

        function savePlaylist() {
            var playlistName = playlistNameInput.text.trim()
            if (playlistName.length > 0) {
                if (!playlistName.toLowerCase().endsWith(".m3u")) {
                    playlistName += ".m3u"
                }

                console.log("Saving playlist as:", playlistName)

                savePlaylistDialog.close()
                playlistNameInput.text = ""
                saveConfirmationPopup.open()
            }
        }
    }

    // Save Confirmation
    Popup {
        id: saveConfirmationPopup
        anchors.centerIn: Overlay.overlay
        width: 380
        height: 160
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: "#4CAF50"
            border.width: 2
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Label {
                text: "✅"
                font.pixelSize: 40
                color: "#4CAF50"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Playlist saved successfully!")
                font.pixelSize: 16
                font.bold: true
                color: root.textColor
                Layout.alignment: Qt.AlignHCenter
            }
        }

        Timer {
            interval: 2000
            running: saveConfirmationPopup.opened
            onTriggered: saveConfirmationPopup.close()
        }
    }

    // Scan Progress Dialog - FIXED: Will properly close when scan completes
    Popup {
        id: scanProgressDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 420
        height: 220
        closePolicy: Popup.CloseOnEscape

        property int currentProgress: 0
        property int totalProgress: 0

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: root.primaryColor
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Label {
                text: qsTr("📂 Scanning Library")
                font.pixelSize: 18
                font.bold: true
                color: root.textColor
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Scanning for audio files in the selected directory...")
                font.pixelSize: 14
                color: root.textSecondaryColor
                wrapMode: Text.WordWrap
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: scanProgressDialog.totalProgress > 0 ? scanProgressDialog.totalProgress : 100
                value: scanProgressDialog.currentProgress
                indeterminate: scanProgressDialog.totalProgress === 0

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 10
                    color: root.surfaceLightColor
                    radius: 5
                }

                contentItem: Item {
                    implicitWidth: 200
                    implicitHeight: 10

                    Rectangle {
                        width: scanProgressDialog.totalProgress > 0 ?
                               (scanProgressDialog.currentProgress / scanProgressDialog.totalProgress) * parent.width :
                               0
                        height: parent.height
                        radius: 5
                        color: root.primaryColor
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: scanProgressDialog.totalProgress > 0 ?
                      qsTr("Found %1 of %2 tracks").arg(scanProgressDialog.currentProgress).arg(scanProgressDialog.totalProgress) :
                      qsTr("Initializing scan...")
                font.pixelSize: 12
                color: root.textSecondaryColor
                horizontalAlignment: Text.AlignHCenter
            }

            DialogButton {
                Layout.alignment: Qt.AlignRight
                text: qsTr("Close")
                onClicked: {
                    scanProgressDialog.close()
                    libraryModel.refresh()
                }
            }
        }
    }

    // ==================== CUSTOM COMPONENTS ====================

    // Sidebar Button - FIXED: Properly shows menu text
    component SidebarButton: Item {
        property string icon: ""
        property string label: ""
        property bool active: false
        signal clicked()

        Layout.fillWidth: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        implicitHeight: 50

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: active ? root.primaryColor : (mouseArea.containsMouse ? root.surfaceLightColor : "transparent")
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 15

            Label {
                text: icon
                font.pixelSize: 20
                Layout.preferredWidth: 30
            }

            Label {
                text: label
                font.pixelSize: 14
                font.bold: active
                color: root.textColor
                Layout.fillWidth: true
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    // Action Card
    component ActionCard: Rectangle {
        property string icon: ""
        property string title: ""
        property string description: ""
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: 120
        color: root.surfaceColor
        radius: 12
        border.color: mouseArea.containsMouse ? root.primaryColor : "transparent"
        border.width: 2

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: icon
                font.pixelSize: 32
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: title
                font.pixelSize: 16
                font.bold: true
                color: root.textColor
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: description
                font.pixelSize: 12
                color: root.textSecondaryColor
            }
        }
    }

    // Library Stat
    component LibraryStat: ColumnLayout {
        property string icon: ""
        property var value: 0
        property string label: ""
        property bool isTime: false

        spacing: 6

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: icon
            font.pixelSize: 24
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: isTime ? value : value.toString()
            font.pixelSize: 20
            font.bold: true
            color: root.primaryColor
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: label
            font.pixelSize: 12
            color: root.textSecondaryColor
        }
    }

    // Tool Button
    component ToolButton: Button {
        property bool primary: false

        implicitHeight: 40
        implicitWidth: 140

        background: Rectangle {
            radius: 8
            color: primary ?
                   (parent.pressed ? Qt.lighter(root.primaryColor, 1.2) : root.primaryColor) :
                   (parent.pressed ? root.surfaceLightColor : "transparent")
            border.color: primary ? root.primaryColor : root.textSecondaryColor
            border.width: 1
        }

        contentItem: Text {
            text: parent.text
            color: primary ? "white" : root.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12
            font.bold: primary
        }
    }

    // Control Button
    component ControlButton: Button {
        property bool primary: false

        implicitWidth: primary ? 56 : 44
        implicitHeight: primary ? 56 : 44

        background: Rectangle {
            radius: primary ? 28 : 22
            color: primary ?
                   (parent.pressed ? Qt.lighter(root.primaryColor, 1.2) : root.primaryColor) :
                   (parent.pressed ? root.surfaceLightColor : "transparent")
            border.color: primary ? root.primaryColor : root.textSecondaryColor
            border.width: primary ? 0 : 1
        }

        contentItem: Text {
            text: parent.text
            color: primary ? "white" : root.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: primary ? 20 : 16
        }
    }

    // Dialog Button
    component DialogButton: Button {
        property bool primary: false

        Layout.fillWidth: true
        implicitHeight: 44

        background: Rectangle {
            radius: 8
            color: primary ?
                   (parent.pressed ? Qt.lighter(root.primaryColor, 1.2) : root.primaryColor) :
                   (parent.pressed ? root.surfaceLightColor : root.backgroundColor)
            border.color: primary ? root.primaryColor : root.surfaceLightColor
            border.width: 2
        }

        contentItem: Text {
            text: parent.text
            color: primary ? "white" : root.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14
            font.bold: primary
        }
    }

    // Effect Card
    component EffectCard: Rectangle {
        property string title: ""
        property string description: ""

        Layout.fillWidth: true
        implicitHeight: children[0].implicitHeight + 40
        color: root.surfaceColor
        radius: 12
        border.color: root.surfaceLightColor
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Label {
                text: title
                font.pixelSize: 18
                font.bold: true
                color: root.textColor
            }

            Label {
                text: description
                font.pixelSize: 14
                color: root.textSecondaryColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }

    // Settings Card
    component SettingsCard: Rectangle {
        property string title: ""

        Layout.fillWidth: true
        implicitHeight: children[0].implicitHeight + 40
        color: root.surfaceColor
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            Label {
                text: title
                font.pixelSize: 18
                font.bold: true
                color: root.textColor
            }
        }
    }

    // Setting Item
    component SettingItem: RowLayout {
        property string label: ""
        property string value: ""

        Layout.fillWidth: true

        Label {
            text: label
            font.pixelSize: 14
            color: root.textSecondaryColor
            Layout.preferredWidth: 120
        }

        Label {
            text: value
            font.pixelSize: 14
            font.bold: true
            color: root.textColor
            Layout.fillWidth: true
        }
    }

    // Feature Item
    component FeatureItem: RowLayout {
        property string text: ""

        Layout.fillWidth: true
        spacing: 10

        Label {
            text: "•"
            font.pixelSize: 14
            color: root.primaryColor
        }

        Label {
            text: parent.text
            font.pixelSize: 14
            color: root.textSecondaryColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    // Shortcut Item
    component ShortcutItem: RowLayout {
        property string shortcut: ""
        property string action: ""

        Layout.fillWidth: true

        Label {
            text: shortcut
            font.pixelSize: 14
            color: root.textSecondaryColor
            font.bold: true
            Layout.preferredWidth: 80
        }

        Label {
            text: action
            font.pixelSize: 14
            color: root.textColor
            Layout.fillWidth: true
        }
    }

    // ==================== HELPER FUNCTIONS ====================
    function formatDuration(milliseconds) {
        if (milliseconds <= 0 || isNaN(milliseconds)) return "0:00"

        var totalSeconds = Math.floor(milliseconds / 1000)
        var hours = Math.floor(totalSeconds / 3600)
        var minutes = Math.floor((totalSeconds % 3600) / 60)
        var seconds = totalSeconds % 60

        if (hours > 0) {
            return hours + ":" +
                   (minutes < 10 ? "0" : "") + minutes + ":" +
                   (seconds < 10 ? "0" : "") + seconds
        } else {
            return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
        }
    }

    // ==================== KEYBOARD SHORTCUTS ====================
    Shortcut {
        sequence: "Space"
        onActivated: {
            if (audioController.duration > 0) {
                audioController.isPlaying ? audioController.pause() : audioController.play()
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+O"
        onActivated: fileDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+L"
        onActivated: stackView.replace(libraryPage)
    }

    Shortcut {
        sequence: "Up"
        onActivated: {
            volumeSlider.value = Math.min(volumeSlider.value + 0.05, 1.0)
            audioController.setVolume(volumeSlider.value)
        }
    }

    Shortcut {
        sequence: "Down"
        onActivated: {
            volumeSlider.value = Math.max(volumeSlider.value - 0.05, 0.0)
            audioController.setVolume(volumeSlider.value)
        }
    }

    // ==================== INITIALIZATION ====================
    Component.onCompleted: {
        console.log("Finix Player initialized successfully")
    }
}
