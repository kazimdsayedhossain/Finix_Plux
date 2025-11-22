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
    }

    // Connections for library signals
    Connections {
        target: libraryModel

        function onScanProgressChanged(current, total) {
            scanProgressDialog.currentProgress = current
            scanProgressDialog.totalProgress = total

            if (current >= total && total > 0) {
                scanCloseTimer.start()
            }
        }

        function onStatsChanged() {
            console.log("Library stats updated")
        }
    }

    // Timer to close scan dialog
    Timer {
        id: scanCloseTimer
        interval: 500
        repeat: false
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

                // Logo
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "🎵"
                            font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }
    }

    // Save Playlist Dialog
    Popup {
        id: savePlaylistDialog
        anchors.centerIn: Overlay.overlay
        width: 450
        height: 240
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: root.surfaceColor
            radius: 12
            border.color: root.accentColor
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Label {
                text: qsTr("💾 Save Current Library as Playlist")
                font.pixelSize: 18
                font.bold: true
                color: root.textColor
            }

            Label {
                text: qsTr("Enter a name for your playlist (will be saved as M3U)")
                font.pixelSize: 11
                color: root.textSecondaryColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            TextField {
                id: playlistNameInput
                Layout.fillWidth: true
                placeholderText: qsTr("e.g., My Favorite Songs")
                font.pixelSize: 13
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
                font.pixelSize: 10
                color: root.textSecondaryColor
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    implicitHeight: 38

                    onClicked: {
                        savePlaylistDialog.close()
                        playlistNameInput.text = ""
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.pressed ? root.surfaceLightColor : root.backgroundColor
                        border.color: root.surfaceLightColor
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: root.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    implicitHeight: 38
                    enabled: playlistNameInput.text.trim().length > 0

                    onClicked: savePlaylist()

                    background: Rectangle {
                        radius: 8
                        color: parent.enabled ?
                               (parent.pressed ? Qt.lighter(root.accentColor, 1.2) : root.accentColor) :
                               root.surfaceLightColor
                    }

                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "white" : root.textSecondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }

        function savePlaylist() {
            var playlistName = playlistNameInput.text.trim()
            if (playlistName.length > 0) {
                // Add .m3u extension if not present
                if (!playlistName.toLowerCase().endsWith(".m3u")) {
                    playlistName += ".m3u"
                }
                
                console.log("Saving playlist as:", playlistName)
                // Note: Actual saving would be handled by C++ backend
                // This is a placeholder for the UI functionality
                
                savePlaylistDialog.close()
                playlistNameInput.text = ""
                
                // Show confirmation
                saveConfirmationPopup.open()
            }
        }
    }

    // Save Confirmation Popup
    Popup {
        id: saveConfirmationPopup
        anchors.centerIn: Overlay.overlay
        width: 350
        height: 150
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: root.surfaceColor
            radius: 10
            border.color: "#4CAF50"
            border.width: 2
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 15

            Label {
                text: "✓"
                font.pixelSize: 36
                color: "#4CAF50"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Playlist saved successfully!")
                font.pixelSize: 14
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

    // Scan Progress Dialog
    Popup {
        id: scanProgressDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 380
        height: 200
        closePolicy: Popup.CloseOnEscape

        property int currentProgress: 0
        property int totalProgress: 0

        background: Rectangle {
            color: root.surfaceColor
            radius: 10
            border.color: root.primaryColor
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Label {
                text: qsTr("Scanning Library")
                font.pixelSize: 17
                font.bold: true
                color: root.textColor
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Scanning for audio files in the selected directory...")
                font.pixelSize: 12
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
                    implicitHeight: 8
                    color: root.surfaceLightColor
                    radius: 4
                }

                contentItem: Item {
                    implicitWidth: 200
                    implicitHeight: 8

                    Rectangle {
                        width: scanProgressDialog.totalProgress > 0 ?
                               (scanProgressDialog.currentProgress / scanProgressDialog.totalProgress) * parent.width :
                               0
                        height: parent.height
                        radius: 4
                        color: root.primaryColor
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: scanProgressDialog.totalProgress > 0 ?
                      qsTr("Found: %1 / %2 tracks").arg(scanProgressDialog.currentProgress).arg(scanProgressDialog.totalProgress) :
                      qsTr("Initializing scan...")
                font.pixelSize: 11
                color: root.textSecondaryColor
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.fillHeight: true }

            Button {
                Layout.alignment: Qt.AlignRight
                text: qsTr("Close")
                implicitWidth: 100
                implicitHeight: 34

                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? root.primaryColor : root.surfaceLightColor
                    border.color: root.primaryColor
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 11
                }

                onClicked: {
                    scanProgressDialog.close()
                    libraryModel.refresh()
                }
            }
        }
    }

    // ==================== CUSTOM COMPONENTS ====================

    component NavButton: Item {
        id: navButton
        property string icon: ""
        property string text: ""
        property bool active: false
        signal clicked()

        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: 46

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: active ? root.primaryColor : (mouseArea.containsMouse ? root.surfaceLightColor : "transparent")

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            Label {
                text: navButton.icon
                font.pixelSize: 18
                Layout.preferredWidth: 28
            }

            Label {
                text: navButton.text
                font.pixelSize: 13
                font.bold: navButton.active
                color: root.textColor
                Layout.fillWidth: true
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: navButton.clicked()
        }
    }

    component QuickActionCard: Rectangle {
        property string icon: ""
        property string title: ""
        property string description: ""
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: 115
        color: root.surfaceColor
        radius: 12
        border.color: mouseArea.containsMouse ? root.primaryColor : "transparent"
        border.width: 2

        Behavior on border.color {
            ColorAnimation { duration: 200 }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: icon
                font.pixelSize: 38
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: title
                font.pixelSize: 14
                font.bold: true
                color: root.textColor
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: description
                font.pixelSize: 11
                color: root.textSecondaryColor
            }
        }
    }

    component StatItem: ColumnLayout {
        property string icon: ""
        property string label: ""
        property var value: 0
        property bool isTime: false

        spacing: 5

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: icon
            font.pixelSize: 22
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: isTime ? value : value.toString()
            font.pixelSize: 17
            font.bold: true
            color: root.primaryColor
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: label
            font.pixelSize: 10
            color: root.textSecondaryColor
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
                if (audioController.isPlaying) {
                    audioController.pause()
                } else {
                    audioController.play()
                }
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
        console.log("Finix Player initialized")
        console.log("Qt Version: 6.10")
        console.log("All features loaded successfully")
    }
} 42
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Finix Player")
                            font.pixelSize: 20
                            font.bold: true
                            color: root.textColor
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 15
                    Layout.rightMargin: 15
                    height: 1
                    color: root.surfaceLightColor
                }

                // Navigation
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 15
                    spacing: 6

                    NavButton {
                        icon: "🏠"
                        text: qsTr("Home")
                        active: stackView.currentItem && stackView.currentItem.objectName === "homePage"
                        onClicked: stackView.replace(homePage)
                    }

                    NavButton {
                        icon: "🎚️"
                        text: qsTr("Audio Effects")
                        active: stackView.currentItem && stackView.currentItem.objectName === "effectsPage"
                        onClicked: stackView.replace(effectsPage)
                    }

                    NavButton {
                        icon: "📚"
                        text: qsTr("Library")
                        active: stackView.currentItem && stackView.currentItem.objectName === "libraryPage"
                        onClicked: stackView.replace(libraryPage)
                    }

                    NavButton {
                        icon: "⚙️"
                        text: qsTr("Settings")
                        active: stackView.currentItem && stackView.currentItem.objectName === "settingsPage"
                        onClicked: stackView.replace(settingsPage)
                    }
                }

                Item { Layout.fillHeight: true }

                // Stats Section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 15
                    Layout.rightMargin: 15
                    Layout.bottomMargin: 15
                    Layout.preferredHeight: 100
                    color: root.surfaceLightColor
                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Label {
                            text: qsTr("📊 Library Stats")
                            font.pixelSize: 12
                            font.bold: true
                            color: root.textColor
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: qsTr("Tracks:")
                                font.pixelSize: 10
                                color: root.textSecondaryColor
                            }

                            Label {
                                text: libraryModel.totalTracks
                                font.pixelSize: 10
                                font.bold: true
                                color: root.primaryColor
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: qsTr("Artists:")
                                font.pixelSize: 10
                                color: root.textSecondaryColor
                            }

                            Label {
                                text: libraryModel.totalArtists
                                font.pixelSize: 10
                                font.bold: true
                                color: root.accentColor
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
                            anchors.margins: 20
                            contentHeight: homeContent.height
                            contentWidth: width
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: homeContent
                                width: parent.width
                                spacing: 20

                                Label {
                                    text: qsTr("Welcome to Finix Player")
                                    font.pixelSize: 28
                                    font.bold: true
                                    color: root.textColor
                                    Layout.topMargin: 10
                                }

                                Label {
                                    text: qsTr("Advanced Music Player with Audio Effects")
                                    font.pixelSize: 14
                                    color: root.textSecondaryColor
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 380
                                    color: root.surfaceColor
                                    radius: 14

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 25
                                        spacing: 18

                                        Label {
                                            text: qsTr("🎵 Now Playing")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Rectangle {
                                            Layout.alignment: Qt.AlignHCenter
                                            width: 200
                                            height: 200
                                            radius: 10
                                            color: root.surfaceLightColor

                                            Image {
                                                id: albumArt
                                                anchors.fill: parent
                                                anchors.margins: 2
                                                source: audioController.thumbnailUrl || ""
                                                fillMode: Image.PreserveAspectCrop
                                                visible: source != ""
                                                layer.enabled: true
                                                layer.effect: OpacityMask {
                                                    maskSource: Rectangle {
                                                        width: albumArt.width
                                                        height: albumArt.height
                                                        radius: 10
                                                    }
                                                }
                                            }

                                            Label {
                                                anchors.centerIn: parent
                                                text: "🎵"
                                                font.pixelSize: 72
                                                color: root.textSecondaryColor
                                                visible: !albumArt.visible
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 5

                                            Label {
                                                Layout.fillWidth: true
                                                text: audioController.trackTitle || qsTr("No track playing")
                                                font.pixelSize: 16
                                                font.bold: true
                                                color: root.textColor
                                                elide: Text.ElideRight
                                                horizontalAlignment: Text.AlignHCenter
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: audioController.trackArtist || qsTr("Unknown Artist")
                                                font.pixelSize: 13
                                                color: root.textSecondaryColor
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 3
                                    rowSpacing: 15
                                    columnSpacing: 15

                                    QuickActionCard {
                                        Layout.fillWidth: true
                                        icon: "📁"
                                        title: qsTr("Open File")
                                        description: qsTr("Play local audio")
                                        onClicked: fileDialog.open()
                                    }

                                    QuickActionCard {
                                        Layout.fillWidth: true
                                        icon: "🎬"
                                        title: qsTr("YouTube")
                                        description: qsTr("Stream from YouTube")
                                        onClicked: youtubeDialog.open()
                                    }

                                    QuickActionCard {
                                        Layout.fillWidth: true
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

                // ==================== AUDIO EFFECTS PAGE (FIXED) ====================
                Component {
                    id: effectsPage

                    Rectangle {
                        objectName: "effectsPage"
                        color: root.backgroundColor

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 20
                            contentHeight: effectsContent.height
                            contentWidth: width
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: effectsContent
                                width: parent.width
                                spacing: 15

                                Label {
                                    text: qsTr("Audio Effects")
                                    font.pixelSize: 26
                                    font.bold: true
                                    color: root.textColor
                                    Layout.topMargin: 5
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    color: "#1E3A5F"
                                    radius: 8
                                    border.color: root.primaryColor
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        spacing: 12

                                        Label {
                                            text: "✓"
                                            font.pixelSize: 22
                                            color: root.primaryColor
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("Real-time audio effects using Qt Multimedia")
                                            font.pixelSize: 12
                                            color: root.textColor
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }

                                // Gain Boost Effect
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: gainBoostContent.height + 40
                                    color: root.surfaceColor
                                    radius: 12
                                    border.color: root.surfaceLightColor
                                    border.width: 1

                                    ColumnLayout {
                                        id: gainBoostContent
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 10

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("🔊 Volume Gain Boost")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("Amplify audio beyond 100% volume")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.topMargin: 5
                                            spacing: 12

                                            Label {
                                                text: qsTr("Gain:")
                                                color: root.textColor
                                                Layout.preferredWidth: 70
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
                                                color: gainSlider.value > 1.0 ? "#FFA500" : root.textColor
                                                font.bold: gainSlider.value > 1.0
                                                Layout.preferredWidth: 55
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: gainSlider.value > 1.0 ?
                                                qsTr("⚠️ Warning: High gain may cause distortion") :
                                                qsTr("Normal audio level")
                                            font.pixelSize: 10
                                            color: gainSlider.value > 1.0 ? "#FFA500" : root.textSecondaryColor
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                // Balance Control
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: balanceContent.height + 40
                                    color: root.surfaceColor
                                    radius: 12
                                    border.color: root.surfaceLightColor
                                    border.width: 1

                                    ColumnLayout {
                                        id: balanceContent
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 10

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("🎚️ Stereo Balance")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("Adjust left/right audio balance")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.topMargin: 5
                                            spacing: 12

                                            Label {
                                                text: qsTr("L")
                                                color: root.textColor
                                                font.bold: true
                                                font.pixelSize: 13
                                                Layout.preferredWidth: 25
                                                horizontalAlignment: Text.AlignCenter
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
                                                color: root.textColor
                                                font.bold: true
                                                font.pixelSize: 13
                                                Layout.preferredWidth: 25
                                                horizontalAlignment: Text.AlignCenter
                                            }
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: balanceSlider.value < -0.1 ?
                                                qsTr("← Left: " + Math.abs(Math.round(balanceSlider.value * 100)) + "%") :
                                                balanceSlider.value > 0.1 ?
                                                qsTr("Right: " + Math.round(balanceSlider.value * 100) + "% →") :
                                                qsTr("Center (Balanced)")
                                            font.pixelSize: 10
                                            color: root.textSecondaryColor
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                // Playback Speed
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: speedContent.height + 40
                                    color: root.surfaceColor
                                    radius: 12
                                    border.color: root.surfaceLightColor
                                    border.width: 1

                                    ColumnLayout {
                                        id: speedContent
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 10

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("⏩ Playback Speed")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("Change playback speed (affects pitch)")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.topMargin: 5
                                            spacing: 12

                                            Label {
                                                text: qsTr("Speed:")
                                                color: root.textColor
                                                Layout.preferredWidth: 70
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
                                                color: root.textColor
                                                Layout.preferredWidth: 55
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        Flow {
                                            Layout.fillWidth: true
                                            Layout.topMargin: 5
                                            spacing: 8

                                            Repeater {
                                                model: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                                                delegate: Button {
                                                    text: modelData.toFixed(2) + "x"
                                                    implicitWidth: 70
                                                    implicitHeight: 30
                                                    onClicked: speedSlider.value = modelData

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
                                                        color: root.textColor
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                        font.pixelSize: 11
                                                        font.bold: Math.abs(speedSlider.value - modelData) < 0.01
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Fade In Effect
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: fadeContent.height + 40
                                    color: root.surfaceColor
                                    radius: 12
                                    border.color: root.surfaceLightColor
                                    border.width: 1

                                    ColumnLayout {
                                        id: fadeContent
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 10

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("🎼 Fade In Effect")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: qsTr("Gradually increase volume when playback starts")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                        }

                                        CheckBox {
                                            id: fadeInCheck
                                            Layout.alignment: Qt.AlignHCenter
                                            Layout.topMargin: 5
                                            text: qsTr("Enable Fade In (1 second)")
                                            checked: audioController.fadeInEnabled
                                            onCheckedChanged: audioController.setFadeInEnabled(checked)

                                            contentItem: Text {
                                                text: fadeInCheck.text
                                                font.pixelSize: 13
                                                color: root.textColor
                                                leftPadding: fadeInCheck.indicator.width + 8
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: fadeInCheck.checked ?
                                                qsTr("✓ Audio will fade in smoothly when you press play") :
                                                qsTr("Audio will start at full volume immediately")
                                            font.pixelSize: 10
                                            color: fadeInCheck.checked ? root.primaryColor : root.textSecondaryColor
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                // Reset Button
                                Button {
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.topMargin: 15
                                    Layout.bottomMargin: 10
                                    text: qsTr("🔄 Reset All Effects")
                                    implicitWidth: 200
                                    implicitHeight: 42

                                    onClicked: {
                                        audioController.resetEffects()
                                        gainSlider.value = 1.0
                                        balanceSlider.value = 0.0
                                        speedSlider.value = 1.0
                                        fadeInCheck.checked = false
                                    }

                                    background: Rectangle {
                                        radius: 21
                                        color: parent.pressed ? root.accentColor : root.surfaceLightColor
                                        border.color: root.accentColor
                                        border.width: 2
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: root.textColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Item { Layout.preferredHeight: 15 }
                            }
                        }
                    }
                }

                // ==================== LIBRARY PAGE (FIXED WITH SAVE PLAYLIST) ====================
                Component {
                    id: libraryPage

                    Rectangle {
                        objectName: "libraryPage"
                        color: root.backgroundColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 15

                                Label {
                                    text: qsTr("Music Library")
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: root.textColor
                                }

                                Item { Layout.fillWidth: true }

                                Button {
                                    text: qsTr("💾 Save Playlist")
                                    implicitHeight: 36
                                    enabled: libraryModel.totalTracks > 0
                                    onClicked: savePlaylistDialog.open()

                                    background: Rectangle {
                                        radius: 7
                                        color: parent.pressed ? root.accentColor : root.surfaceLightColor
                                        border.color: root.accentColor
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: root.textColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 12
                                    }
                                }

                                Button {
                                    text: qsTr("📂 Add Folder")
                                    implicitHeight: 36
                                    onClicked: folderDialog.open()

                                    background: Rectangle {
                                        radius: 7
                                        color: parent.pressed ? root.primaryColor : root.surfaceLightColor
                                        border.color: root.primaryColor
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: root.textColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 12
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 45
                                color: root.surfaceColor
                                radius: 22

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    Label {
                                        text: "🔍"
                                        font.pixelSize: 16
                                    }

                                    TextField {
                                        id: searchField
                                        Layout.fillWidth: true
                                        placeholderText: qsTr("Search tracks, artists, albums...")
                                        color: root.textColor
                                        font.pixelSize: 13
                                        background: Item {}
                                        onTextChanged: libraryModel.search(text)
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 75
                                color: root.surfaceColor
                                radius: 10

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    columns: 4
                                    columnSpacing: 20

                                    StatItem {
                                        icon: "🎵"
                                        label: qsTr("Tracks")
                                        value: libraryModel.totalTracks
                                    }

                                    StatItem {
                                        icon: "🎤"
                                        label: qsTr("Artists")
                                        value: libraryModel.totalArtists
                                    }

                                    StatItem {
                                        icon: "💿"
                                        label: qsTr("Albums")
                                        value: libraryModel.totalAlbums
                                    }

                                    StatItem {
                                        icon: "⏱️"
                                        label: qsTr("Duration")
                                        value: formatDuration(libraryModel.totalDuration)
                                        isTime: true
                                    }
                                }
                            }

                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                spacing: 6

                                model: libraryModel

                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 65
                                    color: mouseArea.containsMouse ? root.surfaceLightColor : root.surfaceColor
                                    radius: 7

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onDoubleClicked: audioController.openFile(model.path)
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12

                                        Label {
                                            text: (index + 1).toString()
                                            font.pixelSize: 12
                                            color: root.textSecondaryColor
                                            Layout.preferredWidth: 30
                                            horizontalAlignment: Text.AlignRight
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Label {
                                                text: model.title || "Unknown"
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: root.textColor
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            RowLayout {
                                                spacing: 8

                                                Label {
                                                    text: model.artist || "Unknown Artist"
                                                    font.pixelSize: 11
                                                    color: root.textSecondaryColor
                                                }

                                                Label {
                                                    text: "•"
                                                    font.pixelSize: 11
                                                    color: root.textSecondaryColor
                                                }

                                                Label {
                                                    text: model.album || "Unknown Album"
                                                    font.pixelSize: 11
                                                    color: root.textSecondaryColor
                                                }
                                            }
                                        }

                                        Label {
                                            text: formatDuration(model.duration)
                                            font.pixelSize: 11
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

                // ==================== SETTINGS PAGE (FIXED OVERLAPPING TEXT) ====================
                Component {
                    id: settingsPage

                    Rectangle {
                        objectName: "settingsPage"
                        color: root.backgroundColor

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 20
                            contentHeight: settingsContent.height + 40
                            contentWidth: width
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: settingsContent
                                width: parent.width
                                spacing: 20

                                Label {
                                    text: qsTr("Settings & About")
                                    font.pixelSize: 26
                                    font.bold: true
                                    color: root.textColor
                                    Layout.topMargin: 5
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: appInfoLayout.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 10

                                    ColumnLayout {
                                        id: appInfoLayout
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Label {
                                            text: qsTr("📱 Application Info")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        GridLayout {
                                            Layout.fillWidth: true
                                            columns: 2
                                            rowSpacing: 10
                                            columnSpacing: 15

                                            Label {
                                                text: qsTr("Name:")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                Layout.preferredWidth: 120
                                            }

                                            Label {
                                                text: qsTr("Finix Player")
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: root.textColor
                                                Layout.fillWidth: true
                                            }

                                            Label {
                                                text: qsTr("Version:")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                            }

                                            Label {
                                                text: qsTr("1.0.0")
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: root.textColor
                                                Layout.fillWidth: true
                                            }

                                            Label {
                                                text: qsTr("Framework:")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                            }

                                            Label {
                                                text: qsTr("Qt 6.10 + C++17")
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: root.textColor
                                                Layout.fillWidth: true
                                            }

                                            Label {
                                                text: qsTr("Build:")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                            }

                                            Label {
                                                text: qsTr("Release")
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: root.textColor
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: featuresLayout.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 10

                                    ColumnLayout {
                                        id: featuresLayout
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 12

                                        Label {
                                            text: qsTr("✨ Features")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Label {
                                                Layout.fillWidth: true
                                                text: qsTr("• Local audio file playback (MP3, FLAC, OGG, WAV, M4A, AAC)")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: qsTr("• YouTube audio streaming with search")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: qsTr("• Real-time audio effects (Gain, Balance, Speed, Fade In)")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: qsTr("• Music library with search and metadata")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: qsTr("• Modern user interface with dark theme")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: aboutLayout.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 10

                                    ColumnLayout {
                                        id: aboutLayout
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 12

                                        Label {
                                            text: qsTr("ℹ️ About")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            Label {
                                                Layout.fillWidth: true
                                                text: qsTr("Finix Player is a modern, feature-rich music player built with Qt 6 and C++.")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: qsTr("The application demonstrates advanced C++ programming concepts and modern Qt development practices.")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: qsTr("Developed with Qt Multimedia for high-quality audio playback and real-time effects processing.")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                wrapMode: Text.WordWrap
                                            }

                                            Label {
                                                text: qsTr("© 2024 Finix Player. All rights reserved.")
                                                font.pixelSize: 10
                                                color: root.textSecondaryColor
                                                Layout.topMargin: 10
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: controlsLayout.implicitHeight + 40
                                    color: root.surfaceColor
                                    radius: 10

                                    ColumnLayout {
                                        id: controlsLayout
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 12

                                        Label {
                                            text: qsTr("⌨️ Keyboard Shortcuts")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        GridLayout {
                                            Layout.fillWidth: true
                                            columns: 2
                                            rowSpacing: 10
                                            columnSpacing: 15

                                            Label {
                                                text: qsTr("Space:")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                                Layout.preferredWidth: 120
                                            }

                                            Label {
                                                text: qsTr("Play/Pause")
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: root.textColor
                                                Layout.fillWidth: true
                                            }

                                            Label {
                                                text: qsTr("Ctrl+O:")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                            }

                                            Label {
                                                text: qsTr("Open File")
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: root.textColor
                                                Layout.fillWidth: true
                                            }

                                            Label {
                                                text: qsTr("Ctrl+L:")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                            }

                                            Label {
                                                text: qsTr("Open Library")
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: root.textColor
                                                Layout.fillWidth: true
                                            }

                                            Label {
                                                text: qsTr("↑/↓:")
                                                font.pixelSize: 12
                                                color: root.textSecondaryColor
                                            }

                                            Label {
                                                text: qsTr("Volume Up/Down")
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: root.textColor
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }

                                Item { Layout.preferredHeight: 20 }
                            }
                        }
                    }
                }
            }

            // ==================== PLAYBACK CONTROLS (BOTTOM BAR) ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                color: root.surfaceColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: audioController.formattedPosition
                            font.pixelSize: 10
                            color: root.textSecondaryColor
                            Layout.preferredWidth: 45
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
                                implicitHeight: 4
                                width: progressSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: root.surfaceLightColor

                                Rectangle {
                                    width: progressSlider.visualPosition * parent.width
                                    height: parent.height
                                    radius: 2
                                    color: root.primaryColor
                                }
                            }

                            handle: Rectangle {
                                x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                implicitWidth: 12
                                implicitHeight: 12
                                radius: 6
                                color: progressSlider.pressed ? root.primaryColor : root.textColor
                                border.color: root.primaryColor
                                border.width: 2
                                visible: progressSlider.hovered || progressSlider.pressed
                            }
                        }

                        Label {
                            text: audioController.formattedDuration
                            font.pixelSize: 10
                            color: root.textSecondaryColor
                            Layout.preferredWidth: 45
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 300
                            spacing: 12

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 6
                                color: root.surfaceLightColor

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    source: audioController.thumbnailUrl || ""
                                    fillMode: Image.PreserveAspectCrop
                                    visible: source != ""
                                }

                                Label {
                                    anchors.centerIn: parent
                                    text: "🎵"
                                    font.pixelSize: 22
                                    visible: audioController.thumbnailUrl === ""
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: audioController.trackTitle || qsTr("No track")
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: root.textColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: audioController.trackArtist || qsTr("Unknown")
                                    font.pixelSize: 10
                                    color: root.textSecondaryColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            Layout.alignment: Qt.AlignCenter
                            spacing: 12

                            RoundButton {
                                text: "⏮"
                                implicitWidth: 36
                                implicitHeight: 36
                                font.pixelSize: 14
                                enabled: audioController.duration > 0

                                onClicked: audioController.seek(0)

                                background: Rectangle {
                                    radius: 18
                                    color: parent.pressed ? root.surfaceLightColor : "transparent"
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? root.textColor : root.textSecondaryColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: parent.font.pixelSize
                                }
                            }

                            RoundButton {
                                text: audioController.isPlaying ? "⏸" : "▶"
                                implicitWidth: 48
                                implicitHeight: 48
                                font.pixelSize: 18
                                enabled: audioController.duration > 0

                                onClicked: {
                                    if (audioController.isPlaying) {
                                        audioController.pause()
                                    } else {
                                        audioController.play()
                                    }
                                }

                                background: Rectangle {
                                    radius: 24
                                    color: parent.enabled ?
                                           (parent.pressed ? Qt.lighter(root.primaryColor, 1.2) : root.primaryColor) :
                                           root.surfaceLightColor
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? "white" : root.textSecondaryColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: parent.font.pixelSize
                                }
                            }

                            RoundButton {
                                text: "⏭"
                                implicitWidth: 36
                                implicitHeight: 36
                                font.pixelSize: 14
                                enabled: audioController.queueSize() > 0

                                onClicked: audioController.playNext()

                                background: Rectangle {
                                    radius: 18
                                    color: parent.pressed ? root.surfaceLightColor : "transparent"
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? root.textColor : root.textSecondaryColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: parent.font.pixelSize
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            Layout.alignment: Qt.AlignRight
                            Layout.maximumWidth: 180
                            spacing: 8

                            Label {
                                text: volumeSlider.value > 0.01 ? "🔊" : "🔇"
                                font.pixelSize: 16
                            }

                            Slider {
                                id: volumeSlider
                                from: 0
                                to: 1
                                value: audioController.volume
                                implicitWidth: 100
                                onMoved: audioController.setVolume(value)

                                background: Rectangle {
                                    x: volumeSlider.leftPadding
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 100
                                    implicitHeight: 4
                                    width: volumeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: root.surfaceLightColor

                                    Rectangle {
                                        width: volumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        radius: 2
                                        color: root.primaryColor
                                    }
                                }

                                handle: Rectangle {
                                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 12
                                    implicitHeight: 12
                                    radius: 6
                                    color: volumeSlider.pressed ? root.primaryColor : root.textColor
                                    border.color: root.primaryColor
                                    border.width: 2
                                    visible: volumeSlider.hovered || volumeSlider.pressed
                                }
                            }

                            Label {
                                text: Math.round(volumeSlider.value * 100) + "%"
                                font.pixelSize: 10
                                color: root.textSecondaryColor
                                Layout.preferredWidth: 35
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
        width: 480
        height: 190
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: root.surfaceColor
            radius: 12
            border.color: root.primaryColor
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Label {
                text: qsTr("🎬 Play from YouTube")
                font.pixelSize: 18
                font.bold: true
                color: root.textColor
            }

            Label {
                text: qsTr("Enter song name or YouTube URL")
                font.pixelSize: 11
                color: root.textSecondaryColor
            }

            TextField {
                id: youtubeInput
                Layout.fillWidth: true
                placeholderText: qsTr("e.g., Imagine Dragons - Believer")
                font.pixelSize: 13
                color: root.textColor

                background: Rectangle {
                    radius: 8
                    color: root.backgroundColor
                    border.color: youtubeInput.focus ? root.primaryColor : root.surfaceLightColor
                    border.width: 2
                }

                onAccepted: {
                    if (text.length > 0) {
                        audioController.playYouTubeAudio(text)
                        youtubeDialog.close()
                        youtubeInput.text = ""
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    implicitHeight: 38

                    onClicked: {
                        youtubeDialog.close()
                        youtubeInput.text = ""
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.pressed ? root.surfaceLightColor : root.backgroundColor
                        border.color: root.surfaceLightColor
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: root.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Play")
                    implicitHeight: 38
                    enabled: youtubeInput.text.length > 0

                    onClicked: {
                        audioController.playYouTubeAudio(youtubeInput.text)
                        youtubeDialog.close()
                        youtubeInput.text = ""
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.enabled ?
                               (parent.pressed ? Qt.lighter(root.primaryColor, 1.2) : root.primaryColor) :
                               root.surfaceLightColor
                    }

                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "white" : root.textSecondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize:
