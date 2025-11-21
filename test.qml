import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.lottieqt 1.0
import com.finix.audioplayer 1.0
import Qt.labs.platform 1.0    // Using Qt.labs.platform for FileDialog

ApplicationWindow {
    id: root
    width: 600
    height: 400
    minimumWidth: 480
    minimumHeight: 350
    visible: true
    title: qsTr("Finix Audio Player")

    readonly property color primaryColor        : "#1DB954"
    readonly property color backgroundColor     : "#121212"
    readonly property color surfaceColor        : "#282828"
    readonly property color textColor           : "#FFFFFF"
    readonly property color textSecondaryColor  : "#B3B3B3"
    readonly property color accentColor         : "#BD2E2E"

    background: Image {
        id: backgroundImage
        source: "qrc:/assests/background.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.6

        Rectangle {
            anchors.fill: parent
            color: root.backgroundColor
            opacity: 0.85
        }
    }

    AudioController {
        id: audioController
    }

    function formatTime(milliseconds) {
        if (milliseconds <= 0 || isNaN(milliseconds))
            return "0:00"
        var totalSeconds = Math.floor(milliseconds / 1000)
        var minutes = Math.floor(totalSeconds / 60)
        var seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: bottomControlBar.top
            margins: 20
        }
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: youtubeSearchField
                Layout.fillWidth: true
                placeholderText: qsTr("Search YouTube link or title…")
                font.pixelSize: 14
                color: root.textColor
                placeholderTextColor: root.textSecondaryColor
                selectByMouse: true

                background: Rectangle {
                    implicitWidth: youtubeSearchField.implicitWidth
                    implicitHeight: youtubeSearchField.implicitHeight
                    radius: 8
                    color: root.surfaceColor
                    border.color: youtubeSearchField.activeFocus ? root.accentColor : "#3E3E3E"
                    border.width: youtubeSearchField.activeFocus ? 2 : 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }

                Keys.onReturnPressed: {
                    if (text.trim() !== "")
                        audioController.playYouTubeAudio(text)
                }

                leftPadding: 15
                rightPadding: 15
                topPadding: 10
                bottomPadding: 10
            }

            Button {
                id: playYoutubeButton
                text: qsTr("Play YouTube")
                implicitWidth: 130
                implicitHeight: 44
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
                    implicitWidth: playYoutubeButton.implicitWidth
                    implicitHeight: playYoutubeButton.implicitHeight
                    radius: 8
                    color: playYoutubeButton.enabled ?
                               (playYoutubeButton.down ?
                                    Qt.darker(root.accentColor, 1.2) :
                                    playYoutubeButton.hovered ?
                                        Qt.lighter(root.accentColor, 1.1) :
                                        root.accentColor)
                             : "#3E3E3E"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            Button {
                id: openFileButton
                text: qsTr("Open File")
                implicitWidth: 130
                implicitHeight: 44

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
                    implicitWidth: openFileButton.implicitWidth
                    implicitHeight: openFileButton.implicitHeight
                    radius: 8
                    color: openFileButton.down ? "#3E3E3E"
                         : openFileButton.hovered ? "#404040"
                         : root.surfaceColor
                    border.color: "#4E4E4E"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

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
                    } else {
                        console.warn("FileDialog accepted but no file property set")
                    }
                }
                onRejected: {
                    console.log("File selection cancelled")
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: center_box
                anchors.fill: parent
                color: "transparent"
                radius: 10
                border.color: audioController.duration > 0 ? root.accentColor : "#2E2E2E"
                border.width: 2

                Behavior on border.color { ColorAnimation { duration: 300 } }

                // --- Lottie Animation (Visualizer) ---
                    Rectangle{
                        // anchors.horizontalCenter: center_box.horizontalCenter
                        // anchors.verticalCenter: center_box.verticalCenter
                        anchors.top:center_box.top
                        anchors.topMargin: 20
                        anchors.left: center_box.left
                        anchors.leftMargin: 16

                        color: "transparent"
                        width: 50
                        height: 50
                        // opacity: .2



                        Item {
                            id: visualizerContainer1
                             // ✅ centers this item inside the border
                            width: 400                     // controls the visible animation size
                            height: 300
                            visible: audioController.duration > 0

                            LottieAnimation {
                                id: visualizer1
                                 anchors.fill: parent
                                source: "qrc:/assests/animation.json"
                                loops: LottieAnimation.Infinite
                                autoPlay: false

                                // 🔥 Highest possible quality rendering
                                quality: LottieAnimation.HighQuality
                                // renderMode: LottieAnimation.RenderModeHardware // Use GPU if supported

                                onStatusChanged: {
                                    if (status === LottieAnimation.Error)
                                        console.error("Failed to load animation:", source)
                                }

                                // Smooth edges
                                antialiasing: true

                                // Automatically play or pause based on audio playback
                                Connections {
                                    target: audioController
                                    onIsPlayingChanged: {
                                        if (audioController.isPlaying) {
                                            visualizer1.play()
                                        } else {
                                            visualizer1.pause()
                                        }
                                    }
                                }
                            }

                        }

                    }



                    Rectangle{
                        // anchors.horizontalCenter: center_box.horizontalCenter
                        // anchors.verticalCenter: center_box.verticalCenter
                        anchors.top:center_box.top
                        anchors.topMargin: 20
                        anchors.left: center_box.left
                        anchors.leftMargin: 184

                        color: "transparent"
                        width: 50
                        height: 50
                        // opacity: .2



                        Item {
                            id: visualizerContainer2
                             // ✅ centers this item inside the border
                            width: 400                     // controls the visible animation size
                            height: 300
                            visible: audioController.duration > 0

                            LottieAnimation {
                                id: visualizer2
                                 anchors.fill: parent
                                source: "qrc:/assests/animation.json"
                                loops: LottieAnimation.Infinite
                                autoPlay: false

                                // 🔥 Highest possible quality rendering
                                quality: LottieAnimation.HighQuality
                                // renderMode: LottieAnimation.RenderModeHardware // Use GPU if supported

                                onStatusChanged: {
                                    if (status === LottieAnimation.Error)
                                        console.error("Failed to load animation:", source)
                                }

                                // Smooth edges
                                antialiasing: true

                                // Automatically play or pause based on audio playback
                                Connections {
                                    target: audioController
                                    onIsPlayingChanged: {
                                        if (audioController.isPlaying) {
                                            visualizer2.play()
                                        } else {
                                            // visualizer2.pause()
                                        }
                                    }
                                }
                            }

                        }

                    }



                    Rectangle{
                        // anchors.horizontalCenter: center_box.horizontalCenter
                        // anchors.verticalCenter: center_box.verticalCenter
                        anchors.top:center_box.top
                        anchors.topMargin: 20
                        anchors.left: center_box.left
                        anchors.leftMargin: 349

                        color: "transparent"
                        width: 50
                        height: 50
                        // opacity: .2



                        Item {
                            id: visualizerContainer3
                             // ✅ centers this item inside the border
                            width: 400                     // controls the visible animation size
                            height: 300
                            visible: audioController.duration > 0

                            LottieAnimation {
                                id: visualizer3
                                 anchors.fill: parent
                                source: "qrc:/assests/animation.json"
                                loops: LottieAnimation.Infinite
                                autoPlay: false

                                // 🔥 Highest possible quality rendering
                                quality: LottieAnimation.HighQuality
                                // renderMode: LottieAnimation.RenderModeHardware // Use GPU if supported

                                onStatusChanged: {
                                    if (status === LottieAnimation.Error)
                                        console.error("Failed to load animation:", source)
                                }

                                // Smooth edges
                                antialiasing: true

                                // Automatically play or pause based on audio playback
                                Connections {
                                    target: audioController
                                    onIsPlayingChanged: {
                                        if (audioController.isPlaying) {
                                            visualizer3.play()
                                        } else {
                                            visualizer3.pause()
                                        }
                                    }
                                }
                            }

                        }

                    }





                ColumnLayout {
                    anchors.centerIn: parent
                    visible: audioController.duration <= 0
                    spacing: 20

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: "qrc:/assests/app_icon_full.png"
                        sourceSize.width: 80
                        sourceSize.height: 80
                        opacity: 0.5
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No audio loaded")
                        font.pixelSize: 18
                        font.bold: true
                        color: root.textSecondaryColor
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Search YouTube or open an audio file")
                        font.pixelSize: 14
                        color: root.textSecondaryColor
                    }
                }



                // --- No Audio Loaded Placeholder (Overlay) ---
                ColumnLayout {
                    anchors.centerIn: parent
                    // FIX: Only visible when no audio is loaded
                    visible: false // <-- MODIFIED (was: audioController.duration <= 0)
                    spacing: 20

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: "qrc:/assests/app_icon_full.png"
                        sourceSize.width: 80
                        sourceSize.height: 80
                        opacity: 0.5
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No audio loaded")
                        font.pixelSize: 18
                        font.bold: true
                        color: root.textSecondaryColor
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Search YouTube or open an audio file")
                        font.pixelSize: 14
                        color: root.textSecondaryColor
                    }
                }
            }
        }
    }

    Rectangle {
        id: bottomControlBar
        height: 110
        width: parent.width
        anchors.bottom: parent.bottom
        color: root.surfaceColor

        Rectangle {
            width: parent.width
            height: 1
            color: "#3E3E3E"
        }

        RowLayout {
            anchors.margins: 15
            anchors.fill: parent
            spacing: 20

            RowLayout {
                Layout.preferredWidth: 240
                Layout.alignment: Qt.AlignVCenter
                spacing: 12

                Rectangle {
                    width: 64
                    height: 64
                    color: "#1E1E1E"
                    radius: 6
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: audioController.thumbnailUrl !== "" ? audioController.thumbnailUrl : "qrc:/assests/default.jpg"
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        Layout.fillWidth: true
                        text: audioController.trackTitle || qsTr("No track")
                        font.pixelSize: 15
                        font.bold: true
                        color: root.textColor
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Label {
                        Layout.fillWidth: true
                        text: audioController.currentTrackName !== "" ? audioController.currentTrackName : qsTr("No artist")
                        font.pixelSize: 13
                        color: root.textSecondaryColor
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 600
                spacing: 8

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        id: prevButton
                        implicitWidth: 32
                        implicitHeight: 32
                        flat: true
                        enabled: audioController.duration > 0

                        contentItem: Label {
                            text: "⏮"
                            color: prevButton.enabled ? root.textSecondaryColor : "#3E3E3E"
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle { color: "transparent" }

                        onClicked: {
                            audioController.seek(0)
                        }
                    }

                    Button {
                        id: playPauseButton
                        implicitWidth: 42
                        implicitHeight: 42
                        enabled: audioController.duration > 0

                        onClicked: {
                            if (audioController.isPlaying) {
                                audioController.pause()
                            } else {
                                audioController.play()
                            }
                        }

                        background: Rectangle {
                            radius: width / 2
                            color: playPauseButton.enabled ? root.textColor : "#3E3E3E"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        contentItem: Image {
                            source: audioController.isPlaying ? "qrc:/assests/pause.png" : "qrc:/assests/play.png"
                            sourceSize.width: 22
                            sourceSize.height: 22
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Button {
                        id: nextButton
                        implicitWidth: 32
                        implicitHeight: 32
                        flat: true
                        enabled: audioController.duration > 0

                        contentItem: Label {
                            text: "⏭"
                            color: nextButton.enabled ? root.textSecondaryColor : "#3E3E3E"
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle { color: "transparent" }

                        onClicked: {
                            // optional next-track logic
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 600
                    spacing: 8

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
                            x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            implicitWidth: 14
                            implicitHeight: 14
                            radius: width / 2
                            color: root.textColor
                            visible: progressSlider.hovered || progressSlider.pressed
                        }

                        background: Rectangle {
                            x: progressSlider.leftPadding
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 4
                            width: progressSlider.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: "#4E4E4E"

                            Rectangle {
                                width: progressSlider.visualPosition * parent.width
                                height: parent.height
                                radius: 2
                                color: root.textColor
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

            RowLayout {
                Layout.preferredWidth: 150
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: 8

                Image {
                    id: volumeIcon
                    source: audioController.volume > 0.001 ? "qrc:/assests/volume.png" : "qrc:/assests/volume.png"
                    sourceSize.width: 20
                    sourceSize.height: 20
                    Layout.alignment: Qt.AlignVCenter
                }

                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    from: 0
                    to: 1
                    value: audioController.volume
                    onMoved: audioController.setVolume(value)

                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: width / 2
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
                        color: "#4E4E4E"

                        Rectangle {
                            width: volumeSlider.visualPosition * parent.width
                            height: parent.height
                            radius: 2
                            color: root.textSecondaryColor
                        }
                    }
                }
            }
        }
    }
}
