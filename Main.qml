import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.lottieqt 1.0
import com.finix.audioplayer 1.0
import Qt.labs.platform 1.1

ApplicationWindow {
    id: root
    width: 1200
    height: 700
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: qsTr("Finix Audio Player - Complete OOP Edition")

    // ==================== Color Scheme ====================
    readonly property color primaryColor: "#1DB954"
    readonly property color backgroundColor: "#121212"
    readonly property color surfaceColor: "#282828"
    readonly property color surfaceLightColor: "#3E3E3E"
    readonly property color textColor: "#FFFFFF"
    readonly property color textSecondaryColor: "#B3B3B3"
    readonly property color accentColor: "#BD2E2E"
    readonly property color hoverColor: "#404040"

    // ==================== Controllers & Models ====================
    AudioController {
        id: audioController
    }

    LibraryModel {
        id: libraryModel

        onScanProgressChanged: function(current, total) {
            scanProgressDialog.currentValue = current
            scanProgressDialog.totalValue = total
        }

        onErrorOccurred: function(message) {
            errorNotification.show(message)
        }
    }

    // ==================== Background ====================
    background: Rectangle {
        color: root.backgroundColor

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: "qrc:/assests/background.jpg"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.15
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.07, 0.07, 0.07, 0.95) }
                GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.05, 0.05, 0.98) }
            }
        }
    }

    // ==================== Helper Functions ====================
    function formatTime(milliseconds) {
        if (milliseconds <= 0 || isNaN(milliseconds))
            return "0:00"
        var totalSeconds = Math.floor(milliseconds / 1000)
        var minutes = Math.floor(totalSeconds / 60)
        var seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    // ==================== File Dialog ====================
    FileDialog {
        id: fileDialog
        title: qsTr("Select Audio File")
        nameFilters: [
            qsTr("Audio files (*.mp3 *.wav *.ogg *.flac *.m4a *.aac)"),
            qsTr("All files (*)")
        ]
        onAccepted: {
            if (fileDialog.file) {
                var filePath = fileDialog.file.toString()
                if (filePath.startsWith("file:///"))
                    filePath = filePath.substring(8)
                else if (filePath.startsWith("file://"))
                    filePath = filePath.substring(7)
                console.log("Opening audio file:", filePath)
                audioController.openFile(filePath)
            }
        }
        onRejected: {
            console.log("File selection cancelled")
        }
    }

    // ==================== Folder Dialog ====================
    FolderDialog {
        id: folderDialog
        title: qsTr("Select Music Folder")
        onAccepted: {
            if (folderDialog.folder) {
                var folderPath = folderDialog.folder.toString()
                if (folderPath.startsWith("file:///"))
                    folderPath = folderPath.substring(8)
                else if (folderPath.startsWith("file://"))
                    folderPath = folderPath.substring(7)
                console.log("Scanning folder:", folderPath)
                scanProgressDialog.open()
                libraryModel.scanDirectory(folderPath)
            }
        }
    }

    // ==================== Main Layout ====================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========== TOP BAR ==========
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: root.surfaceColor
            z: 10

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Image {
                    source: "qrc:/assests/app_icon_full.png"
                    sourceSize.width: 40
                    sourceSize.height: 40
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: "Finix Player"
                    font.pixelSize: 20
                    font.bold: true
                    color: root.textColor
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                Row {
                    spacing: 10
                    Layout.alignment: Qt.AlignVCenter

                    Button {
                        id: playerViewBtn
                        text: "🎵 Player"
                        checkable: true
                        checked: true
                        width: 100
                        height: 36

                        background: Rectangle {
                            radius: 18
                            color: playerViewBtn.checked ? root.primaryColor : root.surfaceLightColor
                            border.color: root.primaryColor
                            border.width: 1
                        }

                        contentItem: Text {
                            text: playerViewBtn.text
                            color: root.textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 13
                        }

                        onClicked: {
                            playerViewBtn.checked = true
                            libraryViewBtn.checked = false
                            effectsViewBtn.checked = false
                            stackLayout.currentIndex = 0
                        }
                    }

                    Button {
                        id: libraryViewBtn
                        text: "📚 Library"
                        checkable: true
                        checked: false
                        width: 100
                        height: 36

                        background: Rectangle {
                            radius: 18
                            color: libraryViewBtn.checked ? root.primaryColor : root.surfaceLightColor
                            border.color: root.primaryColor
                            border.width: 1
                        }

                        contentItem: Text {
                            text: libraryViewBtn.text
                            color: root.textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 13
                        }

                        onClicked: {
                            playerViewBtn.checked = false
                            libraryViewBtn.checked = true
                            effectsViewBtn.checked = false
                            stackLayout.currentIndex = 1
                        }
                    }

                    Button {
                        id: effectsViewBtn
                        text: "🎛️ Effects"
                        checkable: true
                        checked: false
                        width: 100
                        height: 36

                        background: Rectangle {
                            radius: 18
                            color: effectsViewBtn.checked ? root.primaryColor : root.surfaceLightColor
                            border.color: root.primaryColor
                            border.width: 1
                        }

                        contentItem: Text {
                            text: effectsViewBtn.text
                            color: root.textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 13
                        }

                        onClicked: {
                            playerViewBtn.checked = false
                            libraryViewBtn.checked = false
                            effectsViewBtn.checked = true
                            stackLayout.currentIndex = 2
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: root.surfaceLightColor
            }
        }

        // ========== MAIN CONTENT AREA ==========
        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            // ========== PAGE 0: PLAYER VIEW ==========
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // YouTube search bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: youtubeSearchField
                            Layout.fillWidth: true
                            placeholderText: qsTr("Search YouTube or paste link...")
                            font.pixelSize: 14
                            color: root.textColor
                            placeholderTextColor: root.textSecondaryColor
                            selectByMouse: true

                            background: Rectangle {
                                radius: 8
                                color: root.surfaceColor
                                border.color: youtubeSearchField.activeFocus ? root.accentColor : root.surfaceLightColor
                                border.width: 2

                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                            }

                            Keys.onReturnPressed: {
                                if (text.trim() !== "")
                                    audioController.playYouTubeAudio(text)
                            }

                            leftPadding: 15
                            rightPadding: 15
                            topPadding: 12
                            bottomPadding: 12
                        }

                        Button {
                            id: playYoutubeButton
                            text: qsTr("Play YouTube")
                            implicitWidth: 140
                            implicitHeight: 46
                            enabled: youtubeSearchField.text.trim() !== ""

                            onClicked: {
                                if (youtubeSearchField.text.trim() !== "")
                                    audioController.playYouTubeAudio(youtubeSearchField.text)
                            }

                            contentItem: Text {
                                text: playYoutubeButton.text
                                font.pixelSize: 14
                                font.bold: true
                                color: playYoutubeButton.enabled ? root.textColor : root.textSecondaryColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 8
                                color: {
                                    if (!playYoutubeButton.enabled)
                                        return root.surfaceLightColor
                                    if (playYoutubeButton.down)
                                        return Qt.darker(root.accentColor, 1.2)
                                    if (playYoutubeButton.hovered)
                                        return Qt.lighter(root.accentColor, 1.1)
                                    return root.accentColor
                                }

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }

                        Button {
                            id: openFileButton
                            text: qsTr("Open File")
                            implicitWidth: 140
                            implicitHeight: 46

                            onClicked: {
                                fileDialog.open()
                            }

                            contentItem: Text {
                                text: openFileButton.text
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 8
                                color: openFileButton.down ? root.surfaceLightColor
                                     : openFileButton.hovered ? root.hoverColor
                                     : root.surfaceColor
                                border.color: root.primaryColor
                                border.width: 2

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }
                    }

                    // Main visualizer area
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: root.surfaceColor
                        radius: 12
                        border.color: audioController.duration > 0 ? root.primaryColor : root.surfaceLightColor
                        border.width: 2

                        Behavior on border.color {
                            ColorAnimation { duration: 300 }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 20
                            visible: audioController.duration > 0

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 30

                                Rectangle {
                                    Layout.preferredWidth: 200
                                    Layout.preferredHeight: 200
                                    color: "#1E1E1E"
                                    radius: 10
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        source: audioController.thumbnailUrl !== "" ?
                                               audioController.thumbnailUrl : "qrc:/assests/default.jpg"
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Label {
                                        Layout.fillWidth: true
                                        text: audioController.trackTitle || qsTr("Unknown Track")
                                        font.pixelSize: 32
                                        font.bold: true
                                        color: root.textColor
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: audioController.trackArtist || qsTr("Unknown Artist")
                                        font.pixelSize: 20
                                        color: root.textSecondaryColor
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 4
                                        color: root.primaryColor
                                        radius: 2
                                    }

                                    Label {
                                        text: qsTr("Duration: ") + formatTime(audioController.duration)
                                        font.pixelSize: 14
                                        color: root.textSecondaryColor
                                    }

                                    Item { Layout.fillHeight: true }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Visualizer bars
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                spacing: 15

                                Repeater {
                                    model: 3

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        LottieAnimation {
                                            id: visualizer
                                            anchors.fill: parent
                                            source: "qrc:/assests/animation.json"
                                            loops: LottieAnimation.Infinite
                                            autoPlay: false
                                            quality: LottieAnimation.HighQuality
                                            antialiasing: true

                                            Component.onCompleted: {
                                                if (audioController.isPlaying) {
                                                    play()
                                                }
                                            }

                                            Connections {
                                                target: audioController
                                                function onIsPlayingChanged() {
                                                    if (audioController.isPlaying) {
                                                        visualizer.play()
                                                    } else {
                                                        visualizer.pause()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Placeholder
                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: audioController.duration <= 0
                            spacing: 20

                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                source: "qrc:/assests/app_icon_full.png"
                                sourceSize.width: 100
                                sourceSize.height: 100
                                opacity: 0.5
                            }

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("No audio loaded")
                                font.pixelSize: 24
                                font.bold: true
                                color: root.textSecondaryColor
                            }

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("Search YouTube or open an audio file to start")
                                font.pixelSize: 16
                                color: root.textSecondaryColor
                            }
                        }
                    }
                }
            }

            // ========== PAGE 1: LIBRARY VIEW ==========
            Rectangle {
                color: root.backgroundColor

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: root.surfaceColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10

                            Label {
                                text: qsTr("Music Library")
                                font.pixelSize: 24
                                font.bold: true
                                color: root.textColor
                            }

                            Label {
                                text: qsTr("Browse and manage your audio collection")
                                font.pixelSize: 14
                                color: root.textSecondaryColor
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        color: root.surfaceColor

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15

                            TextField {
                                id: librarySearchField
                                Layout.fillWidth: true
                                placeholderText: qsTr("Search your library...")

                                background: Rectangle {
                                    radius: 20
                                    color: root.backgroundColor
                                    border.color: librarySearchField.activeFocus ? root.primaryColor : root.surfaceLightColor
                                    border.width: 1
                                }

                                onTextChanged: {
                                    libraryModel.search(text)
                                }
                            }

                            ComboBox {
                                id: sortCombo
                                Layout.preferredWidth: 150
                                model: ["Title", "Artist", "Album", "Duration", "Year"]

                                background: Rectangle {
                                    radius: 8
                                    color: root.surfaceLightColor
                                    border.color: root.primaryColor
                                    border.width: 1
                                }

                                contentItem: Text {
                                    text: sortCombo.displayText
                                    color: root.textColor
                                    leftPadding: 10
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onCurrentTextChanged: {
                                    libraryModel.sortBy(currentText)
                                }
                            }

                            Button {
                                text: qsTr("Scan Folder")
                                implicitWidth: 120
                                implicitHeight: 40

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
                                }

                                onClicked: {
                                    folderDialog.open()
                                }
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
                                color: root.textSecondaryColor
                            }

                            Label {
                                text: libraryModel.totalArtists + " artists"
                                color: root.textSecondaryColor
                            }

                            Label {
                                text: libraryModel.totalAlbums + " albums"
                                color: root.textSecondaryColor
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
                            height: 60

                            background: Rectangle {
                                color: parent.hovered ? "#2A2A2A" : "transparent"
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 15

                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    color: "#1E1E1E"
                                    radius: 4

                                    Label {
                                        anchors.centerIn: parent
                                        text: "♪"
                                        font.pixelSize: 24
                                        color: root.textSecondaryColor
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.title || "Unknown"
                                        color: root.textColor
                                        font.pixelSize: 14
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: (model.artist || "Unknown") + " • " + (model.album || "Unknown")
                                        color: root.textSecondaryColor
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }
                                }

                                Label {
                                    text: formatTime(model.duration)
                                    color: root.textSecondaryColor
                                    font.pixelSize: 12
                                }
                            }

                            onDoubleClicked: {
                                audioController.openFile(model.path)
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        // Empty state
                        Label {
                            anchors.centerIn: parent
                            visible: trackListView.count === 0
                            text: qsTr("No tracks in library\nClick 'Scan Folder' to add music")
                            font.pixelSize: 16
                            color: root.textSecondaryColor
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // ========== PAGE 2: EFFECTS VIEW ==========
            // ========== PAGE 2: WORKING EFFECTS VIEW ==========
            // ========== PAGE 2: WORKING EFFECTS VIEW (FIXED ALIGNMENT) ==========
            Rectangle {
                color: root.backgroundColor

                ScrollView {
                    anchors.fill: parent
                    clip: true
                    contentWidth: availableWidth

                    ColumnLayout {
                        width: parent.width
                        spacing: 20

                        Label {
                            text: qsTr("Audio Effects")
                            font.pixelSize: 28
                            font.bold: true
                            color: root.textColor
                            Layout.topMargin: 20
                            Layout.leftMargin: 20
                        }

                        // Info banner
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 20
                            Layout.preferredHeight: 60
                            color: "#1E3A5F"
                            radius: 8
                            border.color: root.primaryColor
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Label {
                                    text: "✓"
                                    font.pixelSize: 24
                                    color: root.primaryColor
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: qsTr("These effects are fully functional using Qt's audio system")
                                    font.pixelSize: 13
                                    color: root.textColor
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        // Gain Boost Effect
                        GroupBox {
                            Layout.fillWidth: true
                            Layout.margins: 20

                            background: Rectangle {
                                color: root.surfaceColor
                                radius: 12
                                border.color: root.surfaceLightColor
                                border.width: 1
                            }

                            label: Label {
                                text: qsTr("🔊 Volume Gain Boost")
                                font.pixelSize: 18
                                font.bold: true
                                color: root.textColor
                                // leftPadding: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 20


                                Label {

                                    font.pixelSize: 12
                                    color: root.textSecondaryColor
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    Label {
                                        text: qsTr("Gain:")
                                        color: root.textColor
                                        Layout.preferredWidth: 80
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Slider {
                                        id: gainSlider
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        from: 0.0
                                        to: 2.0
                                        value: 1.0
                                        stepSize: 0.1

                                        onValueChanged: {
                                            audioController.setGainBoost(value)
                                        }

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
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: gainSlider.pressed ? root.primaryColor : root.textColor
                                            border.color: gainSlider.value > 1.0 ? "#FFA500" : root.primaryColor
                                            border.width: 2
                                        }
                                    }

                                    Label {
                                        text: (gainSlider.value * 100).toFixed(0) + "%"
                                        color: gainSlider.value > 1.0 ? "#FFA500" : root.textColor
                                        font.bold: gainSlider.value > 1.0
                                        Layout.preferredWidth: 60
                                        Layout.alignment: Qt.AlignVCenter
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }

                                Label {
                                    text: gainSlider.value > 1.0 ?
                                        qsTr("⚠️ Warning: High gain may cause distortion") :
                                        qsTr("Normal audio level")
                                    font.pixelSize: 10
                                    color: gainSlider.value > 1.0 ? "#FFA500" : root.textSecondaryColor
                                    visible: true
                                }
                            }
                        }

                        // Balance/Pan Control
                        GroupBox {
                            Layout.fillWidth: true
                            Layout.margins: 20

                            background: Rectangle {
                                color: root.surfaceColor
                                radius: 12
                                border.color: root.surfaceLightColor
                                border.width: 1
                            }

                            label: Label {
                                text: qsTr("🎚️ Stereo Balance")
                                font.pixelSize: 18
                                font.bold: true
                                color: root.textColor
                                // leftPadding: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 20


                                Label {

                                    font.pixelSize: 12
                                    color: root.textSecondaryColor
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    Label {
                                        text: qsTr("L")
                                        color: root.textColor
                                        font.bold: true
                                        font.pixelSize: 14
                                        Layout.preferredWidth: 20
                                        Layout.alignment: Qt.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Slider {
                                        id: balanceSlider
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        from: -1.0
                                        to: 1.0
                                        value: 0.0
                                        stepSize: 0.1

                                        onValueChanged: {
                                            audioController.setBalance(value)
                                        }

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

                                            // Center marker
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
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: balanceSlider.pressed ? root.primaryColor : root.textColor
                                            border.color: root.primaryColor
                                            border.width: 2
                                        }
                                    }

                                    Label {
                                        text: qsTr("R")
                                        color: root.textColor
                                        font.bold: true
                                        font.pixelSize: 14
                                        Layout.preferredWidth: 20
                                        Layout.alignment: Qt.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }

                                Label {
                                    text: balanceSlider.value < -0.1 ?
                                        qsTr("← Left: " + Math.abs(balanceSlider.value * 100).toFixed(0) + "%") :
                                        balanceSlider.value > 0.1 ?
                                        qsTr("Right: " + (balanceSlider.value * 100).toFixed(0) + "% →") :
                                        qsTr("Center (Balanced)")
                                    font.pixelSize: 11
                                    color: root.textSecondaryColor
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        // Playback Speed/Pitch
                        GroupBox {
                            Layout.fillWidth: true
                            Layout.margins: 20

                            background: Rectangle {
                                color: root.surfaceColor
                                radius: 12
                                border.color: root.surfaceLightColor
                                border.width: 1
                            }

                            label: Label {
                                text: qsTr("⏩ Playback Speed")
                                font.pixelSize: 18
                                font.bold: true
                                color: root.textColor
                                // leftPadding: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 20

                                Label {

                                    font.pixelSize: 12
                                    color: root.textSecondaryColor
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    Label {
                                        text: qsTr("Speed:")
                                        color: root.textColor
                                        Layout.preferredWidth: 80
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Slider {
                                        id: speedSlider
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        from: 0.25
                                        to: 2.0
                                        value: 1.0
                                        stepSize: 0.05

                                        onValueChanged: {
                                            audioController.setPlaybackRate(value)
                                        }

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
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: speedSlider.pressed ? root.primaryColor : root.textColor
                                            border.color: root.primaryColor
                                            border.width: 2
                                        }
                                    }

                                    Label {
                                        text: speedSlider.value.toFixed(2) + "x"
                                        color: root.textColor
                                        Layout.preferredWidth: 60
                                        Layout.alignment: Qt.AlignVCenter
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }

                                // Speed preset buttons
                                GridLayout {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 80
                                    Layout.rightMargin: 60
                                    columns: 6
                                    rowSpacing: 8
                                    columnSpacing: 8

                                    Button {
                                        text: "0.5x"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        onClicked: speedSlider.value = 0.5

                                        background: Rectangle {
                                            radius: 6
                                            color: parent.pressed ? root.primaryColor : root.surfaceLightColor
                                            border.color: speedSlider.value === 0.5 ? root.primaryColor : "transparent"
                                            border.width: 2
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: root.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 11
                                        }
                                    }

                                    Button {
                                        text: "0.75x"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        onClicked: speedSlider.value = 0.75

                                        background: Rectangle {
                                            radius: 6
                                            color: parent.pressed ? root.primaryColor : root.surfaceLightColor
                                            border.color: speedSlider.value === 0.75 ? root.primaryColor : "transparent"
                                            border.width: 2
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: root.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 11
                                        }
                                    }

                                    Button {
                                        text: "1.0x"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        onClicked: speedSlider.value = 1.0

                                        background: Rectangle {
                                            radius: 6
                                            color: parent.pressed ? root.primaryColor : root.surfaceLightColor
                                            border.color: Math.abs(speedSlider.value - 1.0) < 0.01 ? root.primaryColor : "transparent"
                                            border.width: 2
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: root.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                    }

                                    Button {
                                        text: "1.25x"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        onClicked: speedSlider.value = 1.25

                                        background: Rectangle {
                                            radius: 6
                                            color: parent.pressed ? root.primaryColor : root.surfaceLightColor
                                            border.color: speedSlider.value === 1.25 ? root.primaryColor : "transparent"
                                            border.width: 2
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: root.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 11
                                        }
                                    }

                                    Button {
                                        text: "1.5x"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        onClicked: speedSlider.value = 1.5

                                        background: Rectangle {
                                            radius: 6
                                            color: parent.pressed ? root.primaryColor : root.surfaceLightColor
                                            border.color: speedSlider.value === 1.5 ? root.primaryColor : "transparent"
                                            border.width: 2
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: root.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 11
                                        }
                                    }

                                    Button {
                                        text: "2.0x"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        onClicked: speedSlider.value = 2.0

                                        background: Rectangle {
                                            radius: 6
                                            color: parent.pressed ? root.primaryColor : root.surfaceLightColor
                                            border.color: speedSlider.value === 2.0 ? root.primaryColor : "transparent"
                                            border.width: 2
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: root.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 11
                                        }
                                    }
                                }
                            }
                        }

                        // Fade In Effect
                        GroupBox {
                            Layout.fillWidth: true
                            Layout.margins: 20

                            background: Rectangle {
                                color: root.surfaceColor
                                radius: 12
                                border.color: root.surfaceLightColor
                                border.width: 1
                            }

                            label: Label {
                                text: qsTr("🎼 Fade In Effect")
                                font.pixelSize: 18
                                font.bold: true
                                color: root.textColor
                                // leftPadding: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 15

                                Label {

                                    font.pixelSize: 12
                                    color: root.textSecondaryColor
                                }

                                CheckBox {
                                    id: fadeInCheck
                                    text: qsTr("Enable Fade In (1 second)")
                                    checked: false

                                    onCheckedChanged: {
                                        audioController.setFadeInEnabled(checked)
                                    }

                                    contentItem: Text {
                                        text: fadeInCheck.text
                                        font.pixelSize: 14
                                        color: root.textColor
                                        leftPadding: fadeInCheck.indicator.width + 10
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Label {
                                    text: fadeInCheck.checked ?
                                        qsTr("✓ Audio will fade in smoothly when you press play") :
                                        qsTr("Audio will start at full volume immediately")
                                    font.pixelSize: 10
                                    color: fadeInCheck.checked ? root.primaryColor : root.textSecondaryColor
                                }
                            }
                        }

                        // Reset Button
                        Button {
                            Layout.alignment: Qt.AlignCenter
                            Layout.topMargin: 10
                            Layout.bottomMargin: 20
                            text: qsTr("🔄 Reset All Effects")
                            implicitWidth: 200
                            implicitHeight: 45

                            onClicked: {
                                gainSlider.value = 1.0
                                balanceSlider.value = 0.0
                                speedSlider.value = 1.0
                                fadeInCheck.checked = false
                                audioController.resetEffects()
                            }

                            background: Rectangle {
                                radius: 22
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

                        Item { Layout.fillHeight: true }
                    }
                }
            }

        }

        // ========== BOTTOM PLAYER CONTROLS ==========
        Rectangle {
            id: bottomControlBar
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: root.surfaceColor
            z: 10

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 2
                color: root.surfaceLightColor
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    // Left: Album art and track info
                    RowLayout {
                        Layout.preferredWidth: 280
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 15

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            color: "#1E1E1E"
                            radius: 8
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: audioController.thumbnailUrl !== "" ?
                                       audioController.thumbnailUrl : "qrc:/assests/default.jpg"
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Label {
                                Layout.fillWidth: true
                                text: audioController.trackTitle || qsTr("No track")
                                font.pixelSize: 16
                                font.bold: true
                                color: root.textColor
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Label {
                                Layout.fillWidth: true
                                text: audioController.trackArtist || qsTr("No artist")
                                font.pixelSize: 13
                                color: root.textSecondaryColor
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }
                    }

                    // Center: Playback controls
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 8

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 25

                            Button {
                                id: prevButton
                                implicitWidth: 40
                                implicitHeight: 40
                                enabled: audioController.duration > 0
                                flat: true

                                contentItem: Label {
                                    text: "⏮"
                                    color: prevButton.enabled ? root.textColor : root.surfaceLightColor
                                    font.pixelSize: 22
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 20
                                    color: prevButton.hovered && prevButton.enabled ?
                                           root.hoverColor : "transparent"

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }

                                onClicked: {
                                    audioController.seek(0)
                                }
                            }

                            Button {
                                id: playPauseButton
                                implicitWidth: 50
                                implicitHeight: 50
                                enabled: audioController.duration > 0

                                onClicked: {
                                    if (audioController.isPlaying) {
                                        audioController.pause()
                                    } else {
                                        audioController.play()
                                    }
                                }

                                background: Rectangle {
                                    radius: 25
                                    color: playPauseButton.enabled ?
                                           (playPauseButton.pressed ? Qt.darker(root.primaryColor, 1.2) :
                                            playPauseButton.hovered ? Qt.lighter(root.primaryColor, 1.1) :
                                            root.primaryColor) : root.surfaceLightColor

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }

                                    SequentialAnimation on scale {
                                        running: audioController.isPlaying
                                        loops: Animation.Infinite
                                        NumberAnimation {
                                            from: 1.0
                                            to: 1.05
                                            duration: 800
                                            easing.type: Easing.InOutQuad
                                        }
                                        NumberAnimation {
                                            from: 1.05
                                            to: 1.0
                                            duration: 800
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }

                                contentItem: Image {
                                    source: audioController.isPlaying ?
                                           "qrc:/assests/pause.png" : "qrc:/assests/play.png"
                                    sourceSize.width: 24
                                    sourceSize.height: 24
                                    fillMode: Image.PreserveAspectFit
                                }
                            }

                            Button {
                                id: nextButton
                                implicitWidth: 40
                                implicitHeight: 40
                                enabled: audioController.duration > 0
                                flat: true

                                contentItem: Label {
                                    text: "⏭"
                                    color: nextButton.enabled ? root.textColor : root.surfaceLightColor
                                    font.pixelSize: 22
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 20
                                    color: nextButton.hovered && nextButton.enabled ?
                                           root.hoverColor : "transparent"

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }

                                onClicked: {
                                    audioController.playNext()
                                }
                            }
                        }
                    }

                    // Right: Volume control
                    RowLayout {
                        Layout.preferredWidth: 180
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 10

                        Image {
                            id: volumeIcon
                            source: "qrc:/assests/volume.png"
                            sourceSize.width: 24
                            sourceSize.height: 24
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Slider {
                            id: volumeSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            from: 0
                            to: 1
                            value: audioController.volume

                            onMoved: {
                                audioController.setVolume(value)
                            }

                            handle: Rectangle {
                                x: volumeSlider.leftPadding + volumeSlider.visualPosition *
                                   (volumeSlider.availableWidth - width)
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: 12
                                implicitHeight: 12
                                radius: 6
                                color: root.textColor
                                visible: volumeSlider.hovered || volumeSlider.pressed
                            }

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
                        }

                        Label {
                            text: Math.round(audioController.volume * 100) + "%"
                            font.pixelSize: 12
                            color: root.textSecondaryColor
                            Layout.preferredWidth: 40
                        }
                    }
                }

                // Progress bar (second row)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        text: formatTime(audioController.position)
                        font.pixelSize: 12
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

                        onPressedChanged: {
                            if (!pressed && enabled) {
                                audioController.seek(value)
                            }
                        }

                        Binding {
                            target: progressSlider
                            property: "value"
                            value: audioController.position
                            when: !progressSlider.pressed
                            restoreMode: Binding.RestoreBinding
                        }

                        handle: Rectangle {
                            x: progressSlider.leftPadding + progressSlider.visualPosition *
                               (progressSlider.availableWidth - width)
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            implicitWidth: 14
                            implicitHeight: 14
                            radius: 7
                            color: root.textColor
                            visible: progressSlider.hovered || progressSlider.pressed

                            Behavior on visible {
                                NumberAnimation { duration: 100 }
                            }
                        }

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

                                Behavior on width {
                                    NumberAnimation { duration: 100 }
                                }
                            }
                        }
                    }

                    Label {
                        text: formatTime(audioController.duration)
                        font.pixelSize: 12
                        color: root.textSecondaryColor
                        Layout.preferredWidth: 45
                    }
                }
            }
        }
    }

    // ========== LOADING INDICATOR ==========
    Rectangle {
        id: loadingOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: audioController.mediaStatus === AudioController.Loading
        z: 1000

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: loadingOverlay.visible

                contentItem: Item {
                    implicitWidth: 64
                    implicitHeight: 64

                    Item {
                        id: busyItem
                        width: 64
                        height: 64
                        opacity: parent.parent.running ? 1 : 0

                        Behavior on opacity {
                            OpacityAnimator { duration: 250 }
                        }

                        RotationAnimator {
                            target: busyItem
                            running: parent.parent.running
                            from: 0
                            to: 360
                            loops: Animation.Infinite
                            duration: 1250
                        }

                        Repeater {
                            id: busyRepeater
                            model: 8

                            Rectangle {
                                x: busyItem.width / 2 - width / 2
                                y: busyItem.height / 2 - height / 2
                                implicitWidth: 8
                                implicitHeight: 8
                                radius: 4
                                color: root.primaryColor
                                transform: [
                                    Translate {
                                        y: -Math.min(busyItem.width, busyItem.height) * 0.5 + 5
                                    },
                                    Rotation {
                                        angle: index / busyRepeater.count * 360
                                        origin.x: 4
                                        origin.y: 4
                                    }
                                ]
                                opacity: 1.0 - index / busyRepeater.count
                            }
                        }
                    }
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Loading audio...")
                font.pixelSize: 16
                color: root.textColor
            }
        }
    }




    // ========== SCAN PROGRESS DIALOG ==========
    // ========== SCAN PROGRESS DIALOG ==========
    Popup {
        id: scanProgressDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 400
        height: 200
        closePolicy: Popup.NoAutoClose

        property int currentValue: 0
        property int totalValue: 100

        background: Rectangle {
            color: root.surfaceColor
            radius: 8
            border.color: root.primaryColor
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Label {
                text: qsTr("Scanning Library")
                font.pixelSize: 18
                font.bold: true
                color: root.textColor
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Scanning for audio files...")
                font.pixelSize: 14
                color: root.textColor
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: scanProgressDialog.totalValue > 0 ? scanProgressDialog.totalValue : 100
                value: scanProgressDialog.currentValue

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
                        width: parent.parent.visualPosition * parent.width
                        height: parent.height
                        radius: 4
                        color: root.primaryColor
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: scanProgressDialog.currentValue + " / " + scanProgressDialog.totalValue + " files"
                font.pixelSize: 12
                color: root.textSecondaryColor
                horizontalAlignment: Text.AlignRight
            }

            Item {
                Layout.fillHeight: true
            }

            Button {
                Layout.alignment: Qt.AlignRight
                text: qsTr("Close")
                implicitWidth: 100
                implicitHeight: 36

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
                }

                onClicked: {
                    scanProgressDialog.close()
                }
            }
        }
    }




    // ========== ERROR NOTIFICATION ==========
    Rectangle {
        id: errorNotification
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 80
        width: Math.min(400, parent.width - 40)
        height: errorColumn.height + 30
        color: root.accentColor
        radius: 8
        visible: false
        z: 1001

        property string errorMessage: ""

        ColumnLayout {
            id: errorColumn
            anchors.centerIn: parent
            width: parent.width - 20
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: "⚠"
                    font.pixelSize: 20
                    color: root.textColor
                }

                Label {
                    Layout.fillWidth: true
                    text: errorNotification.errorMessage
                    font.pixelSize: 14
                    color: root.textColor
                    wrapMode: Text.Wrap
                }

                Button {
                    text: "✕"
                    flat: true

                    onClicked: {
                        errorNotification.visible = false
                    }

                    contentItem: Text {
                        text: parent.text
                        color: root.textColor
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Timer {
            id: errorTimer
            interval: 5000
            running: errorNotification.visible
            onTriggered: {
                errorNotification.visible = false
            }
        }

        function show(message) {
            errorMessage = message
            visible = true
            errorTimer.restart()
        }
    }

    // ========== CONNECTIONS ==========
    Connections {
        target: audioController

        function onMediaStatusChanged() {
            if (audioController.mediaStatus === AudioController.Error) {
                errorNotification.show("Failed to load media")
            } else if (audioController.mediaStatus === AudioController.Loaded) {
                scanProgressDialog.close()
            }
        }
    }

    // ========== KEYBOARD SHORTCUTS ==========
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
        sequence: "Right"
        onActivated: {
            if (audioController.duration > 0) {
                audioController.seek(Math.min(audioController.position + 5000,
                                             audioController.duration))
            }
        }
    }

    Shortcut {
        sequence: "Left"
        onActivated: {
            if (audioController.duration > 0) {
                audioController.seek(Math.max(audioController.position - 5000, 0))
            }
        }
    }

    Shortcut {
        sequence: "Up"
        onActivated: {
            audioController.setVolume(Math.min(audioController.volume + 0.1, 1.0))
        }
    }

    Shortcut {
        sequence: "Down"
        onActivated: {
            audioController.setVolume(Math.max(audioController.volume - 0.1, 0.0))
        }
    }

    Shortcut {
        sequence: "Ctrl+O"
        onActivated: {
            fileDialog.open()
        }
    }

    Shortcut {
        sequence: "Ctrl+L"
        onActivated: {
            playerViewBtn.checked = false
            libraryViewBtn.checked = true
            effectsViewBtn.checked = false
            stackLayout.currentIndex = 1
        }
    }

    Shortcut {
        sequence: "Ctrl+E"
        onActivated: {
            playerViewBtn.checked = false
            libraryViewBtn.checked = false
            effectsViewBtn.checked = true
            stackLayout.currentIndex = 2
        }
    }

    Shortcut {
        sequence: "Ctrl+P"
        onActivated: {
            playerViewBtn.checked = true
            libraryViewBtn.checked = false
            effectsViewBtn.checked = false
            stackLayout.currentIndex = 0
        }
    }

    // ========== COMPONENT COMPLETION ==========
    Component.onCompleted: {
        console.log("FinixPlayer initialized successfully")
        console.log("Keyboard shortcuts:")
        console.log("  Space: Play/Pause")
        console.log("  Left/Right: Seek -5s/+5s")
        console.log("  Up/Down: Volume")
        console.log("  Ctrl+O: Open file")
        console.log("  Ctrl+P: Player view")
        console.log("  Ctrl+L: Library view")
        console.log("  Ctrl+E: Effects view")
    }
}
