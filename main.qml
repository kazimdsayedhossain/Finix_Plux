import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import com.finix.audioplayer 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    minimumWidth: 1200
    minimumHeight: 700
    title: qsTr("Finix Player - Modern Audio Experience")
    color: "#0F0F23" // Deep space background

    // ==================== INNOVATIVE DESIGN SYSTEM ====================
    QtObject {
        id: design

        // Cosmic Color Palette
        readonly property color background: "#0F0F23"
        readonly property color surface: "#1A1A2E"
        readonly property color surfaceElevated: "#16213E"
        readonly property color surfaceOverlay: "#0F3460"
        readonly property color accent: "#7C3AED"
        readonly property color accentBright: "#9333EA"
        readonly property color success: "#48BB78"
        readonly property color warning: "#ED8936"
        readonly property color error: "#FC8181"

        // Text Hierarchy
        readonly property color textPrimary: "#F7FAFC"
        readonly property color textSecondary: "#A0AEC0"
        readonly property color textMuted: "#718096"

        // Gradients
        readonly property var primaryGradient: Gradient {
            GradientStop { position: 0.0; color: design.accent }
            GradientStop { position: 1.0; color: design.accentBright }
        }

        readonly property var surfaceGradient: Gradient {
            GradientStop { position: 0.0; color: design.surface }
            GradientStop { position: 0.7; color: design.surfaceElevated }
        }

        // Spacing & Radius
        readonly property int space: 16
        readonly property int spaceHalf: 8
        readonly property int spaceDouble: 32
        readonly property int radius: 16
        readonly property int radiusSmall: 8
        readonly property int radiusLarge: 24

        // Typography
        readonly property int fontSize: 14
        readonly property int fontSizeLarge: 18
        readonly property int fontSizeTitle: 24
        readonly property int fontSizeHeading: 32
        readonly property int fontSizeDisplay: 48

        // Shadows
        readonly property int shadowOffset: 4
        readonly property real shadowOpacity: 0.3
    }

    // ==================== AUDIO CONTROLLER ====================
    AudioController {
        id: audioController
    }

    // ==================== LIBRARY MODEL ====================
    LibraryModel {
        id: libraryModel
    }

    // Library Model Connections
    Connections {
        target: libraryModel
        function onScanProgressChanged(current, total) {
            scanProgressDialog.currentProgress = current
            scanProgressDialog.totalProgress = total

            // Close dialog when scan is complete
            if (current >= total && total > 0) {
                scanCloseTimer.start()
            }
        }

        function onStatsChanged() {
            updateLibraryQueue()
        }
    }

    // Audio Controller Connections for UI updates
    Connections {
        target: audioController
        function onTrackTitleChanged() {
            // Close scan dialog when a track starts playing
            if (scanProgressDialog && scanProgressDialog.opened) {
                scanProgressDialog.close()
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

    // ==================== UTILITY FUNCTIONS ====================
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

    function updateLibraryQueue() {
        var trackPaths = []
        var count = libraryModel.totalTracks

        for (var i = 0; i < count; i++) {
            var path = libraryModel.getTrackPath(i)
            if (path && path !== "") {
                trackPaths.push(path)
            }
        }

        // Update the controller's library queue
        audioController.updateLibraryQueue(trackPaths)
        console.log("Updated library queue with", trackPaths.length, "tracks")
    }

    // ==================== CUSTOM ICON COMPONENT ====================
    component NeonIcon: Canvas {
        property string iconName: ""
        property color glowColor: design.accent
        property real size: 24

        width: size
        height: size

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = glowColor;
            ctx.lineWidth = 2;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.shadowColor = glowColor;
            ctx.shadowBlur = 8;

            switch (iconName) {
                case "music":
                    ctx.beginPath();
                    ctx.arc(8, 6, 3, 0, Math.PI * 2);
                    ctx.moveTo(11, 6);
                    ctx.lineTo(11, 18);
                    ctx.lineTo(5, 14);
                    ctx.stroke();
                    break;

                case "play":
                    ctx.beginPath();
                    ctx.moveTo(6, 4);
                    ctx.lineTo(18, 12);
                    ctx.lineTo(6, 20);
                    ctx.closePath();
                    ctx.fillStyle = glowColor;
                    ctx.fill();
                    break;

                case "pause":
                    ctx.fillStyle = glowColor;
                    ctx.fillRect(6, 4, 4, 16);
                    ctx.fillRect(14, 4, 4, 16);
                    break;

                case "previous":
                    ctx.beginPath();
                    ctx.moveTo(16, 4);
                    ctx.lineTo(8, 12);
                    ctx.lineTo(16, 20);
                    ctx.moveTo(4, 4);
                    ctx.lineTo(4, 20);
                    ctx.stroke();
                    break;

                case "next":
                    ctx.beginPath();
                    ctx.moveTo(8, 4);
                    ctx.lineTo(16, 12);
                    ctx.lineTo(8, 20);
                    ctx.moveTo(20, 4);
                    ctx.lineTo(20, 20);
                    ctx.stroke();
                    break;

                case "folder":
                    ctx.beginPath();
                    ctx.rect(4, 8, 16, 10);
                    ctx.moveTo(4, 8);
                    ctx.lineTo(8, 8);
                    ctx.lineTo(10, 6);
                    ctx.lineTo(16, 6);
                    ctx.lineTo(18, 8);
                    ctx.stroke();
                    break;

                case "youtube":
                    ctx.fillStyle = glowColor;
                    ctx.fillRect(4, 6, 16, 12);
                    ctx.fillStyle = design.background;
                    ctx.beginPath();
                    ctx.moveTo(8, 9);
                    ctx.lineTo(16, 12);
                    ctx.lineTo(8, 15);
                    ctx.closePath();
                    ctx.fill();
                    break;

                case "library":
                    ctx.strokeRect(5, 4, 6, 16);
                    ctx.strokeRect(11, 4, 6, 16);
                    ctx.strokeRect(17, 4, 4, 16);
                    break;

                case "effects":
                    ctx.beginPath();
                    ctx.moveTo(4, 12);
                    ctx.lineTo(6, 8);
                    ctx.lineTo(8, 16);
                    ctx.lineTo(10, 6);
                    ctx.lineTo(12, 14);
                    ctx.lineTo(14, 10);
                    ctx.lineTo(16, 18);
                    ctx.lineTo(18, 8);
                    ctx.lineTo(20, 12);
                    ctx.stroke();
                    break;

                case "equalizer":
                    ctx.beginPath();
                    ctx.moveTo(4, 16);
                    ctx.lineTo(4, 12);
                    ctx.lineTo(6, 12);
                    ctx.lineTo(6, 8);
                    ctx.lineTo(8, 8);
                    ctx.lineTo(8, 16);
                    ctx.moveTo(10, 16);
                    ctx.lineTo(10, 6);
                    ctx.lineTo(12, 6);
                    ctx.lineTo(12, 16);
                    ctx.moveTo(14, 16);
                    ctx.lineTo(14, 10);
                    ctx.lineTo(16, 10);
                    ctx.lineTo(16, 4);
                    ctx.lineTo(18, 4);
                    ctx.lineTo(18, 16);
                    ctx.stroke();
                    break;

                case "settings":
                    ctx.beginPath();
                    ctx.arc(12, 12, 8, 0, Math.PI * 2);
                    ctx.moveTo(12, 6);
                    ctx.lineTo(12, 8);
                    ctx.moveTo(18, 12);
                    ctx.lineTo(16, 12);
                    ctx.moveTo(12, 18);
                    ctx.lineTo(12, 16);
                    ctx.moveTo(6, 12);
                    ctx.lineTo(8, 12);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.arc(12, 12, 3, 0, Math.PI * 2);
                    ctx.stroke();
                    break;

                case "search":
                    ctx.beginPath();
                    ctx.arc(9, 9, 6, 0, Math.PI * 2);
                    ctx.moveTo(15, 15);
                    ctx.lineTo(19, 19);
                    ctx.stroke();
                    break;

                case "save":
                    ctx.strokeRect(5, 6, 14, 12);
                    ctx.strokeRect(7, 4, 10, 4);
                    ctx.fillRect(8, 14, 8, 2);
                    break;

                case "close":
                    ctx.beginPath();
                    ctx.moveTo(8, 8);
                    ctx.lineTo(16, 16);
                    ctx.moveTo(16, 8);
                    ctx.lineTo(8, 16);
                    ctx.stroke();
                    break;

                default:
                    ctx.beginPath();
                    ctx.arc(width/2, height/2, width/2 - 1, 0, Math.PI * 2);
                    ctx.stroke();
            }
        }

        // Force repaint when iconName changes
        onIconNameChanged: {
            requestPaint();
        }
    }

    // ==================== MAIN CONTENT AREA ====================
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: design.background }
            GradientStop { position: 1.0; color: "#1a1a2e" }
        }

        // ==================== TOP NAVIGATION ====================
        Rectangle {
            id: topNav
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 80
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.margins: design.space

                // App Title
                Item {
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Label {
                            text: "FINIX"
                            font.pixelSize: design.fontSizeDisplay
                            font.bold: true
                            color: design.accentBright
                            font.letterSpacing: 2
                        }

                        Label {
                            text: "AUDIO EXPERIENCE"
                            font.pixelSize: design.fontSize
                            color: design.textMuted
                            font.letterSpacing: 1
                        }
                    }
                }

                // Navigation Pills
                RowLayout {
                    spacing: design.spaceHalf

                    Repeater {
                        model: [
                            { name: "home", label: "Home", icon: "music" },
                            { name: "effects", label: "Effects", icon: "effects" },
                            { name: "discovery", label: "Discovery", icon: "search" },
                            { name: "library", label: "Library", icon: "library" },
                            { name: "about", label: "About", icon: "settings" }
                        ]

                        Rectangle {
                            width: 120
                            height: 50
                            radius: design.radius
                            gradient: stackView.currentItem?.objectName === modelData.name ?
                                     design.primaryGradient : null
                            color: stackView.currentItem?.objectName === modelData.name ?
                                   "transparent" : Qt.rgba(design.surfaceOverlay.r, design.surfaceOverlay.g, design.surfaceOverlay.b, 0.5)
                            border.width: stackView.currentItem?.objectName === modelData.name ? 2 : 0
                            border.color: design.accentBright

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: design.spaceHalf

                                NeonIcon {
                                    iconName: modelData.icon
                                    size: 20
                                    glowColor: stackView.currentItem?.objectName === modelData.name ?
                                              design.textPrimary : design.accentBright
                                }

                                Label {
                                    text: modelData.label
                                    font.pixelSize: design.fontSize
                                    font.bold: stackView.currentItem?.objectName === modelData.name
                                    color: design.textPrimary
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData.name === "home") stackView.replace(homePage)
                                    else if (modelData.name === "library") stackView.replace(libraryPage)
                                    else if (modelData.name === "effects") stackView.replace(effectsPage)
                                    else if (modelData.name === "discovery") stackView.replace(discoveryPage)
                                    else if (modelData.name === "about") stackView.replace(aboutPage)
                                }
                            }
                        }
                    }
                }

            }
        }

        // ==================== MAIN CONTENT ====================
        Item {
            anchors.top: topNav.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: bottomPlayer.top
            anchors.margins: design.space

            StackView {
                id: stackView
                anchors.fill: parent
                initialItem: homePage

                // ==================== HOME PAGE ====================
                Component {
                    id: homePage

                    Flickable {
                        objectName: "home"
                        contentHeight: homeLayout.height + design.spaceDouble
                        contentWidth: width
                        clip: true

                        ColumnLayout {
                            id: homeLayout
                            width: parent.width
                            spacing: design.spaceDouble

                            // Hero Section
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 300
                                radius: design.radiusLarge
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: Qt.rgba(design.accent.r, design.accent.g, design.accent.b, 0.3) }
                                    GradientStop { position: 1.0; color: Qt.rgba(design.accentBright.r, design.accentBright.g, design.accentBright.b, 0.1) }
                                }
                                border.width: 1
                                border.color: design.accent

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: design.spaceDouble
                                    spacing: design.spaceDouble

                                    // Welcome Text
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: design.space

                                        Label {
                                            text: "Welcome to Finix Player"
                                            font.pixelSize: design.fontSizeHeading
                                            font.bold: true
                                            color: design.textPrimary
                                        }

                                        Label {
                                            text: "Experience audio like never before with professional-grade effects and seamless playback."
                                            font.pixelSize: design.fontSizeLarge
                                            color: design.textSecondary
                                            wrapMode: Text.WordWrap
                                            Layout.maximumWidth: 400
                                        }

                                        // Quick Stats
                                        RowLayout {
                                            spacing: design.spaceDouble

                                            Rectangle {
                                                width: 80
                                                height: 60
                                                color: design.surface
                                                radius: design.radius
                                                border.width: 1
                                                border.color: design.surfaceElevated

                                                ColumnLayout {
                                                    anchors.centerIn: parent
                                                    spacing: 2

                                                    Label {
                                                        text: libraryModel.totalTracks
                                                        font.pixelSize: design.fontSizeLarge
                                                        font.bold: true
                                                        color: design.accentBright
                                                        Layout.alignment: Qt.AlignHCenter
                                                    }

                                                    Label {
                                                        text: "Tracks"
                                                        font.pixelSize: design.fontSize
                                                        color: design.textMuted
                                                        Layout.alignment: Qt.AlignHCenter
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                width: 80
                                                height: 60
                                                color: design.surface
                                                radius: design.radius
                                                border.width: 1
                                                border.color: design.surfaceElevated

                                                ColumnLayout {
                                                    anchors.centerIn: parent
                                                    spacing: 2

                                                    Label {
                                                        text: libraryModel.totalArtists
                                                        font.pixelSize: design.fontSizeLarge
                                                        font.bold: true
                                                        color: design.success
                                                        Layout.alignment: Qt.AlignHCenter
                                                    }

                                                    Label {
                                                        text: "Artists"
                                                        font.pixelSize: design.fontSize
                                                        color: design.textMuted
                                                        Layout.alignment: Qt.AlignHCenter
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Now Playing Preview
                                    Rectangle {
                                        Layout.preferredWidth: 300
                                        Layout.fillHeight: true
                                        color: design.surface
                                        radius: design.radius
                                        border.width: 1
                                        border.color: design.surfaceElevated
                                        visible: audioController.duration > 0

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: design.space
                                            spacing: design.space

                                            Label {
                                                text: "🎵 Now Playing"
                                                font.pixelSize: design.fontSizeLarge
                                                font.bold: true
                                                color: design.textPrimary
                                            }

                                            // Album Art
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 120
                                                radius: design.radius
                                                color: design.surfaceElevated

                                                Image {
                                                    anchors.fill: parent
                                                    source: audioController.thumbnailUrl || ""
                                                    fillMode: Image.PreserveAspectFit
                                                    smooth: true
                                                    visible: source !== ""
                                                }

                                                NeonIcon {
                                                    anchors.centerIn: parent
                                                    iconName: "music"
                                                    size: 48
                                                    glowColor: design.accentBright
                                                    visible: !parent.children[0].visible
                                                }
                                            }

                                            Label {
                                                text: {
                                                    var fullTitle = audioController.trackTitle || "No track playing";
                                                    var words = fullTitle.split(" ");
                                                    if (words.length > 3) {
                                                        return words.slice(0, 3).join(" ") + "...";
                                                    }
                                                    return fullTitle;
                                                }
                                                font.pixelSize: design.fontSize
                                                font.bold: true
                                                color: design.textPrimary
                                                elide: Text.ElideRight
                                                wrapMode: Text.WordWrap
                                                maximumLineCount: 2
                                            }

                                            Label {
                                                text: audioController.trackArtist || "Unknown Artist"
                                                font.pixelSize: design.fontSize
                                                color: design.textSecondary
                                                elide: Text.ElideRight
                                                wrapMode: Text.WordWrap
                                                maximumLineCount: 1
                                            }
                                        }
                                    }
                                }
                            }

                            // Quick Actions Grid
                            Label {
                                text: "Quick Actions"
                                font.pixelSize: design.fontSizeTitle
                                font.bold: true
                                color: design.textPrimary
                                Layout.leftMargin: design.space
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 4
                                rowSpacing: design.space
                                columnSpacing: design.space
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space

                                ActionTile {
                                    icon: "Folder"
                                    title: "Open File"
                                    description: "Play local audio files"
                                    onClicked: fileDialog.open()
                                }

                                ActionTile {
                                    icon: "YouTube"
                                    title: "YouTube"
                                    description: "Stream from YouTube"
                                    onClicked: youtubeDialog.open()
                                }

                                ActionTile {
                                    icon: "Library"
                                    title: "Library"
                                    description: "Browse your music"
                                    onClicked: stackView.replace(libraryPage)
                                }

                                ActionTile {
                                    icon: "Effects"
                                    title: "Effects"
                                    description: "Audio customization"
                                    onClicked: stackView.replace(effectsPage)
                                }
                            }

                            Item { Layout.preferredHeight: design.space }
                        }
                    }
                }

                // ==================== EFFECTS PAGE ====================
                Component {
                    id: effectsPage

                    Flickable {
                        objectName: "effects"
                        contentHeight: effectsLayout.height + design.spaceDouble
                        contentWidth: width
                        clip: true

                        ColumnLayout {
                            id: effectsLayout
                            width: parent.width
                            spacing: design.spaceDouble

                            // Header
                            Label {
                                text: "Audio Effects Control Center"
                                font.pixelSize: design.fontSizeHeading
                                font.bold: true
                                color: design.textPrimary
                                Layout.leftMargin: design.space
                            }

                            // Effects Grid
                            GridLayout {
                                id: effectsGrid
                                Layout.fillWidth: true
                                columns: 2
                                rowSpacing: 20
                                columnSpacing: 20
                                Layout.leftMargin: design.spaceDouble
                                Layout.rightMargin: design.spaceDouble

                                // Volume Amplification Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 200
                                    radius: design.radius
                                    color: design.surface
                                    border.width: 1
                                    border.color: design.surfaceElevated

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: design.space
                                        spacing: 10

                                        // Title
                                        Label {
                                            text: "Volume Amplification"
                                            font.pixelSize: design.fontSizeTitle
                                            font.bold: true
                                            color: design.textPrimary
                                            Layout.alignment: Qt.AlignLeft
                                        }

                                        // Subtitle
                                        Label {
                                            text: "Boost audio beyond 100% volume"
                                            font.pixelSize: design.fontSize
                                            color: design.textSecondary
                                            Layout.alignment: Qt.AlignLeft
                                            wrapMode: Text.WordWrap
                                        }

                                        // Control
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: design.space
                                            Layout.alignment: Qt.AlignVCenter

                                            Label {
                                                text: "Gain:"
                                                font.pixelSize: design.fontSize
                                                color: design.textSecondary
                                                Layout.preferredWidth: 50
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
                                                    color: design.surfaceElevated

                                                    Rectangle {
                                                        width: gainSlider.visualPosition * parent.width
                                                        height: parent.height
                                                        color: gainSlider.value > 1.0 ? design.warning : design.accentBright
                                                        radius: 3
                                                    }
                                                }

                                                handle: Rectangle {
                                                    x: gainSlider.leftPadding + gainSlider.visualPosition * (gainSlider.availableWidth - width)
                                                    y: gainSlider.topPadding + gainSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 20
                                                    implicitHeight: 20
                                                    radius: 10
                                                    color: gainSlider.pressed ? design.accentBright : design.surface
                                                    border.color: gainSlider.value > 1.0 ? design.warning : design.accentBright
                                                    border.width: 3
                                                }
                                            }

                                            Label {
                                                text: Math.round(gainSlider.value * 100) + "%"
                                                font.pixelSize: design.fontSizeLarge
                                                font.bold: true
                                                color: gainSlider.value > 1.0 ? design.warning : design.textPrimary
                                                Layout.preferredWidth: 60
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        // Description
                                        Label {
                                            text: gainSlider.value > 1.0 ? "⚠️ High gain may cause distortion" : "Normal amplification level"
                                            font.pixelSize: design.fontSize
                                            color: gainSlider.value > 1.0 ? design.warning : design.textSecondary
                                            Layout.alignment: Qt.AlignLeft
                                        }
                                    }
                                }

                                // Stereo Balance Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 200
                                    radius: design.radius
                                    color: design.surface
                                    border.width: 1
                                    border.color: design.surfaceElevated

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: design.space
                                        spacing: 10

                                        // Title
                                        Label {
                                            text: "Stereo Balance"
                                            font.pixelSize: design.fontSizeTitle
                                            font.bold: true
                                            color: design.textPrimary
                                            Layout.alignment: Qt.AlignLeft
                                        }

                                        // Subtitle
                                        Label {
                                            text: "Adjust left/right channel balance"
                                            font.pixelSize: design.fontSize
                                            color: design.textSecondary
                                            Layout.alignment: Qt.AlignLeft
                                            wrapMode: Text.WordWrap
                                        }

                                        // Status
                                        Label {
                                            text: balanceSlider.value === 0 ? "Perfect balance" :
                                                  balanceSlider.value < 0 ? "Left: " + Math.abs(Math.round(balanceSlider.value * 100)) + "%" :
                                                  "Right: " + Math.round(balanceSlider.value * 100) + "%"
                                            font.pixelSize: design.fontSize
                                            color: design.textSecondary
                                            font.bold: true
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        // Control
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: design.spaceHalf
                                            Layout.alignment: Qt.AlignVCenter

                                            Label {
                                                text: "Balance:"
                                                font.pixelSize: design.fontSize
                                                color: design.textSecondary
                                                Layout.preferredWidth: 60
                                            }

                                            Label {
                                                text: "L"
                                                font.pixelSize: design.fontSizeLarge
                                                font.bold: true
                                                color: design.textPrimary
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
                                                    color: design.surfaceElevated

                                                    Rectangle {
                                                        x: balanceSlider.value < 0 ?
                                                           parent.width / 2 + (balanceSlider.value * parent.width / 2) :
                                                           parent.width / 2
                                                        width: Math.abs(balanceSlider.value * parent.width / 2)
                                                        height: parent.height
                                                        color: design.accentBright
                                                        radius: 3
                                                    }

                                                    Rectangle {
                                                        x: parent.width / 2 - 1
                                                        y: -2
                                                        width: 2
                                                        height: parent.height + 4
                                                        color: design.textSecondary
                                                    }
                                                }

                                                handle: Rectangle {
                                                    x: balanceSlider.leftPadding + balanceSlider.visualPosition * (balanceSlider.availableWidth - width)
                                                    y: balanceSlider.topPadding + balanceSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 20
                                                    implicitHeight: 20
                                                    radius: 10
                                                    color: balanceSlider.pressed ? design.accentBright : design.surface
                                                    border.color: design.accentBright
                                                    border.width: 3
                                                }
                                            }

                                            Label {
                                                text: "R"
                                                font.pixelSize: design.fontSizeLarge
                                                font.bold: true
                                                color: design.textPrimary
                                                Layout.preferredWidth: 20
                                            }
                                        }
                                    }
                                }

                                // Playback Speed Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 200
                                    radius: design.radius
                                    color: design.surface
                                    border.width: 1
                                    border.color: design.surfaceElevated

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: design.space
                                        spacing: 10

                                        // Title
                                        Label {
                                            text: "Playback Speed"
                                            font.pixelSize: design.fontSizeTitle
                                            font.bold: true
                                            color: design.textPrimary
                                            Layout.alignment: Qt.AlignLeft
                                        }

                                        // Subtitle
                                        Label {
                                            text: "Control playback tempo"
                                            font.pixelSize: design.fontSize
                                            color: design.textSecondary
                                            Layout.alignment: Qt.AlignLeft
                                            wrapMode: Text.WordWrap
                                        }

                                        // Control
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: design.space
                                            Layout.alignment: Qt.AlignVCenter

                                            Label {
                                                text: "Speed:"
                                                font.pixelSize: design.fontSize
                                                color: design.textSecondary
                                                Layout.preferredWidth: 50
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
                                                    color: design.surfaceElevated

                                                    Rectangle {
                                                        width: speedSlider.visualPosition * parent.width
                                                        height: parent.height
                                                        color: design.accentBright
                                                        radius: 3
                                                    }
                                                }

                                                handle: Rectangle {
                                                    x: speedSlider.leftPadding + speedSlider.visualPosition * (speedSlider.availableWidth - width)
                                                    y: speedSlider.topPadding + speedSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 20
                                                    implicitHeight: 20
                                                    radius: 10
                                                    color: speedSlider.pressed ? design.accentBright : design.surface
                                                    border.color: design.accentBright
                                                    border.width: 3
                                                }
                                            }

                                            Label {
                                                text: speedSlider.value.toFixed(2) + "x"
                                                font.pixelSize: design.fontSizeLarge
                                                font.bold: true
                                                color: design.textPrimary
                                                Layout.preferredWidth: 60
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        // Speed Buttons Row
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: design.space
                                            Layout.alignment: Qt.AlignHCenter

                                            Repeater {
                                                model: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

                                                Rectangle {
                                                    Layout.preferredWidth: 55
                                                    Layout.preferredHeight: 36
                                                    radius: design.radiusSmall
                                                    color: Math.abs(speedSlider.value - modelData) < 0.01 ? design.accentBright : design.surfaceElevated
                                                    border.width: 1
                                                    border.color: design.surfaceOverlay

                                                    Label {
                                                        anchors.centerIn: parent
                                                        text: modelData.toFixed(2) + "x"
                                                        font.pixelSize: design.fontSize
                                                        font.bold: Math.abs(speedSlider.value - modelData) < 0.01
                                                        color: Math.abs(speedSlider.value - modelData) < 0.01 ? design.background : design.textPrimary
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        onClicked: {
                                                            speedSlider.value = modelData
                                                            audioController.setPlaybackRate(modelData)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Fade In Effect Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 200
                                    radius: design.radius
                                    color: design.surface
                                    border.width: 1
                                    border.color: design.surfaceElevated

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: design.space
                                        spacing: 10

                                        // Title
                                        Label {
                                            text: "Fade In Effect"
                                            font.pixelSize: design.fontSizeTitle
                                            font.bold: true
                                            color: design.textPrimary
                                            Layout.alignment: Qt.AlignLeft
                                        }

                                        // Subtitle
                                        Label {
                                            text: "Smooth volume transition on play"
                                            font.pixelSize: design.fontSize
                                            color: design.textSecondary
                                            Layout.alignment: Qt.AlignLeft
                                            wrapMode: Text.WordWrap
                                        }

                                        // Control
                                        Rectangle {
                                            Layout.alignment: Qt.AlignHCenter
                                            Layout.preferredWidth: 60
                                            Layout.preferredHeight: 60
                                            radius: 30
                                            color: audioController.fadeInEnabled ? design.accentBright : design.surfaceElevated
                                            border.width: 3
                                            border.color: audioController.fadeInEnabled ? design.accentBright : design.surfaceOverlay

                                            Label {
                                                anchors.centerIn: parent
                                                text: audioController.fadeInEnabled ? "✓" : ""
                                                font.pixelSize: design.fontSizeLarge
                                                font.bold: true
                                                color: design.background
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: audioController.setFadeInEnabled(!audioController.fadeInEnabled)
                                            }
                                        }

                                        // Description
                                        Label {
                                            text: audioController.fadeInEnabled ? "Fade in enabled (1 second)" : "Fade in disabled"
                                            font.pixelSize: design.fontSize
                                            color: audioController.fadeInEnabled ? design.accentBright : design.textSecondary
                                            Layout.alignment: Qt.AlignLeft
                                        }
                                    }
                                }
                            }

                            Item { Layout.preferredHeight: design.space }

                            // Reset Button
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: design.spaceDouble
                                width: 200
                                height: 50
                                radius: design.radius
                                gradient: design.primaryGradient
                                border.width: 2
                                border.color: design.accentBright

                                Label {
                                    anchors.centerIn: parent
                                    text: "🔄 Reset All Effects"
                                    font.pixelSize: design.fontSizeLarge
                                    font.bold: true
                                    color: design.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        audioController.resetEffects()
                                        gainSlider.value = 1.0
                                        balanceSlider.value = 0.0
                                        speedSlider.value = 1.0
                                    }
                                }
                            }
                        }
                    }
                }

// ==================== DISCOVERY PAGE ====================

                // ==================== DISCOVERY PAGE - REPLACE IN main.qml ====================
                // Find the discoveryPage Component in your main.qml and replace the entire delegate section

                Component {
                    id: discoveryPage

                    Flickable {
                        objectName: "discovery"
                        contentHeight: discoveryLayout.height + design.spaceDouble
                        contentWidth: width
                        clip: true

                        ColumnLayout {
                            id: discoveryLayout
                            width: parent.width
                            spacing: design.spaceDouble

                            // Header Section
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                spacing: design.spaceHalf

                                Label {
                                    text: "Discover New Music"
                                    font.pixelSize: design.fontSizeHeading
                                    font.bold: true
                                    color: design.textPrimary
                                }

                                Label {
                                    text: "AI-powered recommendations based on your listening history"
                                    font.pixelSize: design.fontSize
                                    color: design.textSecondary
                                }

                                Label {
                                    text: "▶ Play any YouTube song from Home to get personalized recommendations"
                                    font.pixelSize: design.fontSize
                                    color: design.accentBright
                                    font.italic: true
                                    Layout.topMargin: design.spaceHalf
                                }
                            }

                            // Recommendations List Section
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 600
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                visible: audioController.recommendationManager.count > 0

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: design.space

                                    // Section Header
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: design.space

                                        Label {
                                            text: "🎵"
                                            font.pixelSize: design.fontSizeTitle
                                        }

                                        Label {
                                            text: "Recommended Songs"
                                            font.pixelSize: design.fontSizeTitle
                                            font.bold: true
                                            color: design.textPrimary
                                        }

                                        Item { Layout.fillWidth: true }

                                        Label {
                                            text: audioController.recommendationManager.count + " available"
                                            font.pixelSize: design.fontSize
                                            color: design.textSecondary
                                        }
                                    }

                                    // Scrollable Recommendations Container
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        radius: design.radius
                                        color: design.surface
                                        border.width: 1
                                        border.color: design.surfaceElevated

                                        ListView {
                                            id: recommendationsListView
                                            anchors.fill: parent
                                            anchors.margins: design.space
                                            clip: true
                                            spacing: design.space
                                            model: audioController.recommendationManager.recommendations


                                            // Recommendation Card Delegate - UPDATED FOR REAL THUMBNAILS
                                            delegate: Rectangle {
                                                width: recommendationsListView.width - design.space * 2
                                                height: 100
                                                radius: design.radius
                                                color: recMouse.containsMouse ? design.surfaceElevated : design.surface
                                                border.width: 2
                                                border.color: recMouse.containsMouse ? design.accentBright : design.surfaceOverlay


                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: design.space
                                                    spacing: design.space

                                                    // Thumbnail with loading states - UPDATED
                                                    Rectangle {
                                                        Layout.preferredWidth: 80
                                                        Layout.preferredHeight: 80
                                                        radius: design.radiusSmall
                                                        clip: true

                                                        // Dynamic gradient background (shown when loading or no thumbnail)
                                                        gradient: Gradient {
                                                            GradientStop {
                                                                position: 0.0
                                                                color: {
                                                                    var colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F", "#BB8FCE"];
                                                                    return colors[index % colors.length];
                                                                }
                                                            }
                                                            GradientStop {
                                                                position: 1.0
                                                                color: {
                                                                    var colors = ["#C44569", "#26547C", "#06A77D", "#FF7F50", "#56A3A6", "#F39C12", "#8E44AD"];
                                                                    return colors[index % colors.length];
                                                                }
                                                            }
                                                        }

                                                        border.width: 2
                                                        border.color: {
                                                            var colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F", "#BB8FCE"];
                                                            return Qt.lighter(colors[index % colors.length], 1.3);
                                                        }

                                                        // Real thumbnail image (priority display)
                                                        Image {
                                                            id: thumbImage
                                                            anchors.fill: parent
                                                            source: modelData.thumbnailUrl || ""
                                                            fillMode: Image.PreserveAspectCrop
                                                            smooth: true
                                                            asynchronous: true
                                                            cache: true
                                                            visible: status === Image.Ready

                                                            // Fade in animation when loaded
                                                            opacity: 0
                                                            Behavior on opacity {
                                                                NumberAnimation { duration: 300 }
                                                            }

                                                            onStatusChanged: {
                                                                if (status === Image.Ready) {
                                                                    opacity = 1.0
                                                                }
                                                            }
                                                        }

                                                        // Loading indicator
                                                        BusyIndicator {
                                                            anchors.centerIn: parent
                                                            width: 40
                                                            height: 40
                                                            running: thumbImage.status === Image.Loading
                                                            visible: running
                                                        }

                                                        // Fallback music visualization (shown when no thumbnail or error)
                                                        ColumnLayout {
                                                            anchors.centerIn: parent
                                                            spacing: 8
                                                            visible: thumbImage.status !== Image.Ready &&
                                                                    thumbImage.status !== Image.Loading &&
                                                                    (modelData.thumbnailUrl === "" || thumbImage.status === Image.Error)

                                                            // Large music note
                                                            Label {
                                                                Layout.alignment: Qt.AlignHCenter
                                                                text: "♫"
                                                                font.pixelSize: 40
                                                                font.bold: true
                                                                color: "white"
                                                                style: Text.Outline
                                                                styleColor: Qt.rgba(0, 0, 0, 0.4)
                                                            }

                                                            // Mini equalizer bars
                                                            RowLayout {
                                                                Layout.alignment: Qt.AlignHCenter
                                                                spacing: 4

                                                                Repeater {
                                                                    model: 4
                                                                    Rectangle {
                                                                        width: 5
                                                                        height: 6 + (index * 3)
                                                                        radius: 2
                                                                        color: "white"
                                                                        opacity: 0.9
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }

                                                    // Song Info Section
                                                    ColumnLayout {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        spacing: 6

                                                        Label {
                                                            text: modelData.title || "Unknown Title"
                                                            font.pixelSize: design.fontSizeLarge
                                                            font.bold: true
                                                            color: design.textPrimary
                                                            elide: Text.ElideRight
                                                            Layout.fillWidth: true
                                                            wrapMode: Text.NoWrap
                                                        }

                                                        Label {
                                                            text: modelData.artist || "Unknown Artist"
                                                            font.pixelSize: design.fontSize
                                                            color: design.textSecondary
                                                            elide: Text.ElideRight
                                                            Layout.fillWidth: true
                                                        }

                                                        Label {
                                                            text: "Search: " + (modelData.searchQuery || "No query")
                                                            font.pixelSize: design.fontSize - 2
                                                            color: design.textMuted
                                                            elide: Text.ElideRight
                                                            Layout.fillWidth: true
                                                        }
                                                    }

                                                    // Play Button
                                                    Rectangle {
                                                        Layout.preferredWidth: 60
                                                        Layout.preferredHeight: 60
                                                        radius: 30
                                                        gradient: Gradient {
                                                            GradientStop { position: 0.0; color: design.accent }
                                                            GradientStop { position: 1.0; color: design.accentBright }
                                                        }
                                                        border.width: 2
                                                        border.color: design.accentBright

                                                        Label {
                                                            anchors.centerIn: parent
                                                            text: "▶"
                                                            font.pixelSize: 24
                                                            color: design.textPrimary
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            audioController.playRecommendedSong(index);
                                        }
                                                        }
                                                    }
                                                }

                                                // Hover effect
                                                MouseArea {
                                                    id: recMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    propagateComposedEvents: true
                                                    onClicked: function(mouse) {
                                                        mouse.accepted = false;
                                                    }
                                                }
                                            }

                                            // Custom Scrollbar
                                            ScrollBar.vertical: ScrollBar {
                                                policy: ScrollBar.AsNeeded

                                                background: Rectangle {
                                                    color: design.surfaceElevated
                                                    radius: 4
                                                    implicitWidth: 8
                                                }

                                                contentItem: Rectangle {
                                                    implicitWidth: 8
                                                    radius: 4
                                                    color: design.accentBright
                                                    opacity: parent.pressed ? 1.0 : 0.7
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Empty State - shown when no recommendations
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 400
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                radius: design.radius
                                color: design.surface
                                border.width: 1
                                border.color: design.surfaceElevated
                                visible: audioController.recommendationManager.count === 0

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: design.spaceDouble
                                    width: parent.width * 0.7

                                    // Large search icon
                                    Label {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "🔍"
                                        font.pixelSize: 80
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: "No Recommendations Yet"
                                        font.pixelSize: design.fontSizeTitle
                                        font.bold: true
                                        color: design.textPrimary
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: "Play YouTube songs from the Home page to discover new music. After 10 seconds of playback, we'll automatically find 7 similar tracks you might enjoy!"
                                        font.pixelSize: design.fontSize
                                        color: design.textSecondary
                                        wrapMode: Text.WordWrap
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Rectangle {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.topMargin: design.space
                                        width: 220
                                        height: 50
                                        radius: design.radius
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: design.accent }
                                            GradientStop { position: 1.0; color: design.accentBright }
                                        }
                                        border.width: 2
                                        border.color: design.accentBright

                                        Label {
                                            anchors.centerIn: parent
                                            text: "🎬 Search YouTube Music"
                                            font.pixelSize: design.fontSizeLarge
                                            font.bold: true
                                            color: design.textPrimary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                stackView.replace(homePage);
                                                youtubeDialog.open();
                                            }
                                        }
                                    }
                                }
                            }

                            // Bottom Spacer
                            Item {
                                Layout.preferredHeight: design.space
                            }
                        }

                        // Monitor recommendation changes
                        Connections {
                            target: audioController.recommendationManager
                            function onRecommendationsChanged() {
                                console.log("=== QML: recommendationsChanged signal received ===");
                                console.log("New count:", audioController.recommendationManager.count);
                            }
                        }
                    }
                }

                // ==================== LIBRARY PAGE ====================
                Component {
                    id: libraryPage

                    Flickable {
                        objectName: "library"
                        contentHeight: libraryLayout.height + design.spaceDouble
                        contentWidth: width
                        clip: true

                        ColumnLayout {
                            id: libraryLayout
                            width: parent.width
                            spacing: design.spaceDouble

                            // Header
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                spacing: design.space

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: design.spaceHalf

                                    Label {
                                        text: "Music Library"
                                        font.pixelSize: design.fontSizeHeading
                                        font.bold: true
                                        color: design.textPrimary
                                    }

                                    Label {
                                        text: "Your complete music collection"
                                        font.pixelSize: design.fontSize
                                        color: design.textSecondary
                                    }
                                }

                                RowLayout {
                                    spacing: design.space

                                    Rectangle {
                                        width: 140
                                        height: 45
                                        radius: design.radius
                                        gradient: design.primaryGradient
                                        border.width: 1
                                        border.color: design.accentBright

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: design.spaceHalf

                                            NeonIcon {
                                                iconName: "save"
                                                size: 18
                                                glowColor: design.textPrimary
                                            }

                                            Label {
                                                text: "Save Playlist"
                                                font.pixelSize: design.fontSize
                                                color: design.textPrimary
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: savePlaylistDialog.open()
                                            enabled: libraryModel.totalTracks > 0
                                        }
                                    }

                                    Rectangle {
                                        width: 140
                                        height: 45
                                        radius: design.radius
                                        color: design.surface
                                        border.width: 1
                                        border.color: design.surfaceElevated

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: design.spaceHalf

                                            NeonIcon {
                                                iconName: "folder"
                                                size: 18
                                                glowColor: design.accentBright
                                            }

                                            Label {
                                                text: "Add Folder"
                                                font.pixelSize: design.fontSize
                                                color: design.textPrimary
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: folderDialog.open()
                                        }
                                    }
                                }
                            }

                            // Search Bar
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                height: 60
                                radius: design.radiusLarge
                                color: design.surface
                                border.width: 2
                                border.color: design.surfaceElevated

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: design.space

                                    NeonIcon {
                                        iconName: "search"
                                        size: 24
                                        glowColor: design.accentBright
                                    }

                                    TextField {
                                        id: searchField
                                        Layout.fillWidth: true
                                        placeholderText: qsTr("Search tracks, artists, albums...")
                                        color: design.textPrimary
                                        font.pixelSize: design.fontSizeLarge
                                        background: Item {}
                                        onTextChanged: libraryModel.search(text)
                                    }

                                    Label {
                                        text: libraryModel.totalTracks + " tracks"
                                        font.pixelSize: design.fontSize
                                        color: design.textSecondary
                                        visible: searchField.text === ""
                                    }
                                }
                            }

                            // Stats Cards
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                Layout.bottomMargin: design.spaceDouble
                                spacing: design.space

                                StatCard {
                                    title: "Total Tracks"
                                    value: libraryModel.totalTracks.toString()
                                    accentColor: "#06B6D4"
                                    backgroundColor: "#673AB7"
                                }

                                StatCard {
                                    title: "Artists"
                                    value: libraryModel.totalArtists.toString()
                                    accentColor: design.success
                                    backgroundColor: "#2196F3"
                                }

                                StatCard {
                                    title: "Albums"
                                    value: libraryModel.totalAlbums.toString()
                                    accentColor: design.warning
                                    backgroundColor: "#00BCD4"
                                }

                                StatCard {
                                    title: "Duration"
                                    value: formatDuration(libraryModel.totalDuration)
                                    accentColor: design.error
                                    backgroundColor: "#4CAF50"
                                }
                            }

                            // Track List
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 400
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                radius: design.radius
                                color: design.surface
                                border.width: 1
                                border.color: design.surfaceElevated

                                ListView {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    clip: true
                                    spacing: 2
                                    model: libraryModel

                                    delegate: Rectangle {
                                        width: ListView.view.width
                                        height: 70
                                        radius: design.radiusSmall
                                        color: trackMouse.containsMouse ? design.surfaceElevated : design.surface

                                        MouseArea {
                                            id: trackMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onDoubleClicked: {
                                                audioController.setLibraryPlaybackMode(true)
                                                audioController.playFromLibraryIndex(index)
                                            }
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: design.space
                                            spacing: design.space

                                            Label {
                                                text: (index + 1).toString()
                                                font.pixelSize: design.fontSizeLarge
                                                color: design.textSecondary
                                                Layout.preferredWidth: 40
                                                horizontalAlignment: Text.AlignRight
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 50
                                                Layout.preferredHeight: 50
                                                radius: design.radius
                                                color: design.surfaceElevated

                                                Image {
                                                    anchors.fill: parent
                                                    anchors.margins: 2
                                                    source: model.albumArt || ""
                                                    fillMode: Image.PreserveAspectCrop
                                                    smooth: true
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 4

                                                Label {
                                                    Layout.fillWidth: true
                                                    text: model.title || "Unknown"
                                                    font.pixelSize: design.fontSizeLarge
                                                    font.bold: true
                                                    color: design.textPrimary
                                                    elide: Text.ElideRight
                                                }

                                                RowLayout {
                                                    spacing: design.space

                                                    Label {
                                                        text: model.artist || "Unknown Artist"
                                                        font.pixelSize: design.fontSize
                                                        color: design.textSecondary
                                                    }

                                                    Label {
                                                        text: "•"
                                                        font.pixelSize: design.fontSize
                                                        color: design.textMuted
                                                    }

                                                    Label {
                                                        text: model.album || "Unknown Album"
                                                        font.pixelSize: design.fontSize
                                                        color: design.textSecondary
                                                    }
                                                }
                                            }

                                            Label {
                                                text: formatDuration(model.duration)
                                                font.pixelSize: design.fontSize
                                                color: design.textSecondary
                                                Layout.preferredWidth: 60
                                                horizontalAlignment: Text.AlignRight
                                            }

                                            Rectangle {
                                                width: 45
                                                height: 45
                                                radius: design.radius
                                                color: design.accentBright
                                                border.width: 2
                                                border.color: design.accent

                                                NeonIcon {
                                                    anchors.centerIn: parent
                                                    iconName: "play"
                                                    size: 18
                                                    glowColor: design.background
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        audioController.setLibraryPlaybackMode(true)
                                                        audioController.playFromLibraryIndex(index)
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                        background: Rectangle {
                                            color: design.surfaceElevated
                                            radius: 2
                                        }
                                        contentItem: Rectangle {
                                            implicitWidth: 6
                                            radius: 3
                                            color: design.accentBright
                                        }
                                    }
                                }
                            }

                            Item { Layout.preferredHeight: design.space }
                        }
                    }
                }


                // ==================== ABOUT PAGE ====================
                Component {
                    id: aboutPage

                    Flickable {
                        objectName: "about"
                        contentHeight: aboutContent.height + design.spaceDouble
                        contentWidth: width
                        clip: true

                        ColumnLayout {
                            id: aboutContent
                            width: parent.width
                            spacing: design.spaceDouble

                            // Header
                            Label {
                                text: "About Finix Player"
                                font.pixelSize: design.fontSizeHeading
                                font.bold: true
                                color: design.textPrimary
                                Layout.leftMargin: design.space
                            }

                            // App Info Card
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                implicitHeight: 200
                                radius: design.radius
                                color: design.surface
                                border.width: 1
                                border.color: design.surfaceElevated

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: design.space
                                    spacing: design.space

                                    Label {
                                        text: "📱 Application Information"
                                        font.pixelSize: design.fontSizeTitle
                                        font.bold: true
                                        color: design.textPrimary
                                    }

                                    GridLayout {
                                        columns: 2
                                        rowSpacing: design.space
                                        columnSpacing: design.spaceDouble

                                        Label { text: "Name:"; color: design.textSecondary; font.pixelSize: design.fontSize }
                                        Label { text: "Finix Player"; color: design.textPrimary; font.bold: true; font.pixelSize: design.fontSize }

                                        Label { text: "Version:"; color: design.textSecondary; font.pixelSize: design.fontSize }
                                        Label { text: "1.0.1"; color: design.textPrimary; font.bold: true; font.pixelSize: design.fontSize }

                                        Label { text: "Framework:"; color: design.textSecondary; font.pixelSize: design.fontSize }
                                        Label { text: "Qt 6.10 + C++17"; color: design.textPrimary; font.bold: true; font.pixelSize: design.fontSize }
                                    }
                                }
                            }

                            // Developer Info
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                implicitHeight: 180
                                radius: design.radius
                                color: design.surface
                                border.width: 1
                                border.color: design.surfaceElevated

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: design.space
                                    spacing: design.space

                                    Label {
                                        text: "👨‍💻 Developer"
                                        font.pixelSize: design.fontSizeTitle
                                        font.bold: true
                                        color: design.textPrimary
                                    }

                                    GridLayout {
                                        columns: 2
                                        rowSpacing: design.space
                                        columnSpacing: design.spaceDouble

                                        Label { text: "Developer:"; color: design.textSecondary; font.pixelSize: design.fontSize }
                                        Label { text: "Kazi MD. Sayed Hossain"; color: design.textPrimary; font.bold: true; font.pixelSize: design.fontSize }

                                        Label { text: "Email:"; color: design.textSecondary; font.pixelSize: design.fontSize }
                                        Label { text: "kazimdsayedhossain@outlook.com"; color: design.accentBright; font.bold: true; font.pixelSize: design.fontSize }

                                        Label { text: "Location:"; color: design.textSecondary; font.pixelSize: design.fontSize }
                                        Label { text: "Khulna, Bangladesh"; color: design.textPrimary; font.bold: true; font.pixelSize: design.fontSize }
                                    }
                                }
                            }

                            // Features
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                implicitHeight: 250
                                radius: design.radius
                                color: design.surface
                                border.width: 1
                                border.color: design.surfaceElevated

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: design.space
                                    spacing: design.space

                                    Label {
                                        text: "✨ Features"
                                        font.pixelSize: design.fontSizeTitle
                                        font.bold: true
                                        color: design.textPrimary
                                    }

                                    ColumnLayout {
                                        spacing: design.spaceHalf

                                        FeatureItem { text: "Local audio file playback (MP3, FLAC, OGG, WAV, M4A, AAC)" }
                                        FeatureItem { text: "YouTube audio streaming with search" }
                                        FeatureItem { text: "Real-time audio effects (Gain, Balance, Speed, Fade In)" }
                                        FeatureItem { text: "Music library with search and metadata" }
                                        FeatureItem { text: "Modern user interface with dark theme" }
                                    }
                                }
                            }

                            // Keyboard Shortcuts
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: design.space
                                Layout.rightMargin: design.space
                                implicitHeight: 200
                                radius: design.radius
                                color: design.surface
                                border.width: 1
                                border.color: design.surfaceElevated

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: design.space
                                    spacing: design.space

                                    Label {
                                        text: "⌨️ Keyboard Shortcuts"
                                        font.pixelSize: design.fontSizeTitle
                                        font.bold: true
                                        color: design.textPrimary
                                    }

                                    GridLayout {
                                        columns: 2
                                        rowSpacing: design.space
                                        columnSpacing: design.spaceDouble

                                        Label { text: "Space"; color: design.accentBright; font.bold: true; font.pixelSize: design.fontSize }
                                        Label { text: "Play/Pause"; color: design.textPrimary; font.pixelSize: design.fontSize }

                                        Label { text: "Ctrl+O"; color: design.accentBright; font.bold: true; font.pixelSize: design.fontSize }
                                        Label { text: "Open File"; color: design.textPrimary; font.pixelSize: design.fontSize }

                                        Label { text: "Ctrl+L"; color: design.accentBright; font.bold: true; font.pixelSize: design.fontSize }
                                        Label { text: "Open Library"; color: design.textPrimary; font.pixelSize: design.fontSize }

                                        Label { text: "↑/↓"; color: design.accentBright; font.bold: true; font.pixelSize: design.fontSize }
                                        Label { text: "Volume Up/Down"; color: design.textPrimary; font.pixelSize: design.fontSize }
                                    }
                                }
                            }

                            Item { Layout.preferredHeight: design.space }
                        }
                    }
                }
            }
        }

        // ==================== BOTTOM PLAYER ====================
        Rectangle {
            id: bottomPlayer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 120
            color: design.surface
            border.width: 1
            border.color: design.surfaceElevated

            RowLayout {
                anchors.fill: parent
                anchors.margins: design.space
                spacing: design.space

                // Track Info - FIXED: Set maximum width
                RowLayout {
                    Layout.preferredWidth: 300
                    Layout.maximumWidth: 300
                    spacing: design.space

                    Rectangle {
                        width: 70
                        height: 70
                        radius: design.radius
                        color: design.surfaceElevated

                        Image {
                            anchors.fill: parent
                            anchors.margins: 3
                            source: audioController.thumbnailUrl || ""
                            fillMode: Image.PreserveAspectCrop
                            visible: source !== ""
                        }

                        NeonIcon {
                            anchors.centerIn: parent
                            iconName: "music"
                            size: 30
                            glowColor: design.accentBright
                            visible: !parent.children[0].visible
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Label {
                            text: {
                                var fullTitle = audioController.trackTitle || "No track playing";
                                var words = fullTitle.split(" ");
                                if (words.length > 3) {
                                    return words.slice(0, 3).join(" ") + "...";
                                }
                                return fullTitle;
                            }
                            font.pixelSize: design.fontSizeLarge
                            font.bold: true
                            color: design.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: audioController.trackArtist || "Unknown Artist"
                            font.pixelSize: design.fontSize
                            color: design.textSecondary
                            elide: Text.ElideRight
                        }
                    }
                }

                // Playback Controls - FIXED: Set fixed width
                RowLayout {
                    Layout.preferredWidth: 160
                    Layout.alignment: Qt.AlignVCenter
                    spacing: design.spaceHalf

                    ControlButton {
                        icon: "previous"
                        enabled: audioController.duration > 0
                        onClicked: {
                            if (audioController.libraryPlaybackEnabled) {
                                audioController.playPreviousInLibrary()
                            } else {
                                audioController.seek(0)
                            }
                        }
                    }

                    ControlButton {
                        id: playPauseButton
                        icon: audioController.isPlaying ? "pause" : "play"
                        primary: true
                        enabled: audioController.duration > 0
                        onClicked: {
                            if (audioController.isPlaying) {
                                audioController.pause()
                            } else {
                                audioController.play()
                            }
                        }
                    }

                    ControlButton {
                        icon: "next"
                        enabled: audioController.libraryPlaybackEnabled
                        onClicked: {
                            if (audioController.libraryPlaybackEnabled) {
                                audioController.playNextInLibrary()
                            }
                        }
                    }
                }

                // Progress Bar Section - FIXED: Reduced label widths
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 400
                    spacing: design.spaceHalf

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: design.spaceHalf  // Reduced spacing

                        Label {
                            text: formatDuration(audioController.position)
                            font.pixelSize: design.fontSize
                            color: design.textSecondary
                            Layout.preferredWidth: 40  // Reduced from 50
                            horizontalAlignment: Text.AlignRight
                        }

                        Slider {
                            id: progressSlider
                            Layout.fillWidth: true
                            from: 0
                            to: audioController.duration > 0 ? audioController.duration : 100
                            value: seekSliderValue
                            enabled: audioController.duration > 0

                            property real seekSliderValue: audioController.position
                            property bool seeking: false

                            onPressedChanged: {
                                if (!pressed && seeking) {
                                    audioController.seek(value)
                                    seeking = false
                                }
                            }

                            onMoved: {
                                seeking = true
                                seekSliderValue = value
                            }

                            Connections {
                                target: audioController
                                function onPositionChanged() {
                                    if (!progressSlider.seeking) {
                                        progressSlider.seekSliderValue = audioController.position
                                    }
                                }
                            }

                            background: Rectangle {
                                x: progressSlider.leftPadding
                                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 6
                                width: progressSlider.availableWidth
                                height: implicitHeight
                                radius: 3
                                color: design.surfaceElevated

                                Rectangle {
                                    width: progressSlider.visualPosition * parent.width
                                    height: parent.height
                                    radius: 3
                                    color: design.accent
                                }
                            }

                            handle: Rectangle {
                                x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: progressSlider.pressed ? design.accentBright : design.surface
                                border.color: design.accentBright
                                border.width: 2
                                visible: progressSlider.hovered || progressSlider.pressed
                            }
                        }

                        Label {
                            text: formatDuration(audioController.duration)
                            font.pixelSize: design.fontSize
                            color: design.textSecondary
                            Layout.preferredWidth: 40  // Reduced from 50
                            horizontalAlignment: Text.AlignLeft
                        }
                    }

                    // Library Mode Indicator
                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 2
                        color: design.accentBright
                        visible: audioController.libraryPlaybackEnabled

                        SequentialAnimation on opacity {
                            running: audioController.libraryPlaybackEnabled
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
                            NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                        }
                    }
                }

                // Volume Control - FIXED: Set fixed width
                RowLayout {
                    Layout.preferredWidth: 180
                    Layout.alignment: Qt.AlignVCenter
                    spacing: design.spaceHalf

                    NeonIcon {
                        iconName: "volume"
                        size: 20
                        glowColor: audioController.volume > 0.01 ? design.textPrimary : design.textMuted
                    }

                    Slider {
                        id: volumeSlider
                        from: 0
                        to: 1
                        value: audioController.volume
                        Layout.preferredWidth: 120
                        onMoved: audioController.setVolume(value)

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            implicitWidth: 100
                            implicitHeight: 4
                            width: volumeSlider.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: design.surfaceElevated

                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height
                                radius: 2
                                color: design.accentBright
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            implicitWidth: 14
                            implicitHeight: 14
                            radius: 7
                            color: volumeSlider.pressed ? design.accentBright : design.surface
                            border.color: design.accentBright
                            border.width: 2
                            visible: volumeSlider.hovered || volumeSlider.pressed
                        }
                    }

                    Label {
                        text: Math.round(volumeSlider.value * 100) + "%"
                        font.pixelSize: design.fontSize
                        color: design.textSecondary
                        Layout.preferredWidth: 40
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
        width: 550
        height: 220
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: design.radiusLarge
            color: design.surface
            border.width: 2
            border.color: design.accentBright
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: design.spaceDouble
            spacing: design.space

            Label {
                text: qsTr("🎬 Play from YouTube")
                font.pixelSize: design.fontSizeTitle
                font.bold: true
                color: design.textPrimary
            }

            TextField {
                id: youtubeInput
                Layout.fillWidth: true
                placeholderText: qsTr("Enter song name or YouTube URL...")
                font.pixelSize: design.fontSizeLarge
                color: design.textPrimary

                background: Rectangle {
                    radius: design.radius
                    color: design.surfaceElevated
                    border.color: youtubeInput.focus ? design.accentBright : design.surfaceOverlay
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
                spacing: design.space

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
        width: 450
        height: 200
        modal: true
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            radius: design.radiusLarge
            color: design.surface
            border.width: 2
            border.color: design.accentBright
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: design.spaceDouble
            spacing: design.space

            Label {
                text: qsTr("🔄 Loading YouTube Audio")
                font.pixelSize: design.fontSizeTitle
                font.bold: true
                color: design.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: youtubeLoadingDialog.opened
            }

            Label {
                text: qsTr("Please wait while we load your audio...")
                font.pixelSize: design.fontSizeLarge
                color: design.textSecondary
                Layout.alignment: Qt.AlignHCenter
            }
        }

        Connections {
            target: audioController
            function onIsPlayingChanged() {
                if (audioController.isPlaying) {
                    youtubeLoadingDialog.close()
                }
            }
        }

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
        width: 520
        height: 280
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: design.radiusLarge
            color: design.surface
            border.width: 2
            border.color: design.accentBright
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: design.spaceDouble
            spacing: design.space

            Label {
                text: qsTr("💾 Save Playlist")
                font.pixelSize: design.fontSizeTitle
                font.bold: true
                color: design.textPrimary
            }

            Label {
                text: qsTr("Enter a name for your playlist (will be saved as M3U)")
                font.pixelSize: design.fontSize
                color: design.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            TextField {
                id: playlistNameInput
                Layout.fillWidth: true
                placeholderText: qsTr("My Favorite Songs")
                font.pixelSize: design.fontSizeLarge
                color: design.textPrimary

                background: Rectangle {
                    radius: design.radius
                    color: design.surfaceElevated
                    border.color: playlistNameInput.focus ? design.accentBright : design.surfaceOverlay
                    border.width: 2
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: design.space

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
                    onClicked: {
                        var playlistName = playlistNameInput.text.trim()
                        if (playlistName.length > 0) {
                            if (!playlistName.toLowerCase().endsWith(".m3u")) {
                                playlistName += ".m3u"
                            }

                            var appDir = Qt.application.arguments[0]
                            var lastSlash = Math.max(appDir.lastIndexOf('/'), appDir.lastIndexOf('\\'))
                            if (lastSlash > 0) {
                                appDir = appDir.substring(0, lastSlash)
                            }

                            var fullPath = appDir + "/" + playlistName

                            console.log("Saving playlist to:", fullPath)

                            var success = libraryModel.saveAsM3UPlaylist(fullPath)

                            savePlaylistDialog.close()
                            playlistNameInput.text = ""

                            if (success) {
                                saveConfirmationPopup.savedPath = fullPath
                                saveConfirmationPopup.open()
                            } else {
                                saveErrorPopup.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // Save Confirmation Popup
    Popup {
        id: saveConfirmationPopup
        anchors.centerIn: Overlay.overlay
        width: 480
        height: 220
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property string savedPath: ""

        background: Rectangle {
            radius: design.radiusLarge
            color: design.surface
            border.width: 2
            border.color: design.success
        }

        ColumnLayout {
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: design.space
            spacing: design.space

            Label {
                text: "✅"
                font.pixelSize: 48
                color: design.success
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Playlist saved successfully!")
                font.pixelSize: design.fontSizeTitle
                font.bold: true
                color: design.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Saved to: %1").arg(saveConfirmationPopup.savedPath)
                font.pixelSize: design.fontSize
                color: design.textSecondary
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Open Folder")
                implicitHeight: 36

                onClicked: {
                    Qt.openUrlExternally("file:///" + saveConfirmationPopup.savedPath.substring(0, saveConfirmationPopup.savedPath.lastIndexOf('/')))
                    saveConfirmationPopup.close()
                }

                background: Rectangle {
                    radius: design.radius
                    color: parent.down ? design.accentBright : design.surfaceElevated
                    border.color: design.accentBright
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: design.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: design.fontSize
                }
            }
        }

        Timer {
            interval: 5000
            running: saveConfirmationPopup.opened
            onTriggered: saveConfirmationPopup.close()
        }
    }

    // Save Error Popup
    Popup {
        id: saveErrorPopup
        anchors.centerIn: Overlay.overlay
        width: 420
        height: 180
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: design.radiusLarge
            color: design.surface
            border.width: 2
            border.color: design.error
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: design.space

            Label {
                text: "❌"
                font.pixelSize: 48
                color: design.error
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Failed to save playlist")
                font.pixelSize: design.fontSizeTitle
                font.bold: true
                color: design.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Please check file permissions and try again")
                font.pixelSize: design.fontSize
                color: design.textSecondary
                Layout.alignment: Qt.AlignHCenter
            }
        }

        Timer {
            interval: 3000
            running: saveErrorPopup.opened
            onTriggered: saveErrorPopup.close()
        }
    }

    // Scan Progress Dialog
    Popup {
        id: scanProgressDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 450
        height: 240
        closePolicy: Popup.CloseOnEscape

        property int currentProgress: 0
        property int totalProgress: 0

        background: Rectangle {
            radius: design.radiusLarge
            color: design.surface
            border.width: 2
            border.color: design.accentBright
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: design.spaceDouble
            spacing: design.space

            Label {
                text: qsTr("📂 Scanning Library")
                font.pixelSize: design.fontSizeTitle
                font.bold: true
                color: design.textPrimary
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Scanning for audio files in the selected directory...")
                font.pixelSize: design.fontSize
                color: design.textSecondary
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
                    color: design.surfaceElevated
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
                        color: design.accentBright
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: scanProgressDialog.totalProgress > 0 ?
                      qsTr("Found %1 of %2 tracks").arg(scanProgressDialog.currentProgress).arg(scanProgressDialog.totalProgress) :
                      qsTr("Initializing scan...")
                font.pixelSize: design.fontSize
                color: design.textSecondary
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
    component ActionTile: Rectangle {
        property string icon: ""
        property string title: ""
        property string description: ""
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: 140
        radius: design.radius
        color: tileMouse.containsMouse ? design.surfaceElevated : design.surface
        border.width: tileMouse.containsMouse ? 2 : 1
        border.color: tileMouse.containsMouse ? design.accentBright : design.surfaceOverlay

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: design.space

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: icon
                font.pixelSize: 36
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: title
                font.pixelSize: design.fontSizeLarge
                font.bold: true
                color: design.textPrimary
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: description
                font.pixelSize: design.fontSize
                color: design.textSecondary
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    component StatCard: Rectangle {
        property string title: ""
        property string value: ""
        property color accentColor: design.accentBright
        property color backgroundColor: design.surface

        Layout.fillWidth: true
        implicitHeight: 80
        radius: design.radius
        color: backgroundColor
        border.width: 1
        border.color: design.surfaceElevated

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0

            Label {
                text: value
                font.pixelSize: design.fontSizeDisplay - 2
                font.bold: true
                color: "black"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: title
                font.pixelSize: design.fontSize
                color: "black"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    component ControlButton: Rectangle {
        property string icon: ""
        property bool primary: false
        signal clicked()

        implicitWidth: primary ? 60 : 48
        implicitHeight: primary ? 60 : 48
        radius: primary ? 30 : 24
        gradient: primary ? design.primaryGradient : null
        color: primary ? "transparent" : (buttonMouse.containsMouse ? design.surfaceElevated : design.surface)
        border.width: primary ? 0 : 1
        border.color: primary ? design.accentBright : design.surfaceOverlay

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        NeonIcon {
            id: buttonIcon
            anchors.centerIn: parent
            iconName: parent.icon
            size: primary ? 24 : 20
            glowColor: primary ? design.textPrimary : design.accentBright

            // Force repaint when icon changes
            onIconNameChanged: {
                requestPaint()
            }
        }
    }

    component DialogButton: Rectangle {
        property string text: ""
        property bool primary: false
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: 48
        radius: design.radius
        gradient: primary ? design.primaryGradient : null
        color: primary ? "transparent" : (dialogMouse.containsMouse ? design.surfaceElevated : design.surface)
        border.width: primary ? 2 : 1
        border.color: primary ? design.accentBright : design.surfaceOverlay

        MouseArea {
            id: dialogMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        Label {
            anchors.centerIn: parent
            text: parent.text
            font.pixelSize: design.fontSizeLarge
            font.bold: primary
            color: primary ? design.textPrimary : design.textPrimary
        }
    }

    component EffectPanel: Rectangle {
        property string title: ""
        property string description: ""
        default property alias content: contentLayout.data

        Layout.fillWidth: true
        radius: design.radius
        color: design.surface
        border.width: 1
        border.color: design.surfaceElevated

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: design.space
            spacing: design.space

            // Header section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: design.spaceHalf

                Label {
                    text: title
                    font.pixelSize: design.fontSizeTitle
                    font.bold: true
                    color: design.textPrimary
                }

                Label {
                    text: description
                    font.pixelSize: design.fontSize
                    color: design.textSecondary
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: parent.width
                }
            }

            // Content section
            ColumnLayout {
                id: contentLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: design.space
            }
        }
    }

    component FeatureItem: RowLayout {
        property string text: ""

        Layout.fillWidth: true
        spacing: design.spaceHalf

        Label {
            text: "•"
            font.pixelSize: design.fontSize
            color: design.accentBright
        }

        Label {
            text: parent.text
            font.pixelSize: design.fontSize
            color: design.textSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
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
        sequences: ["Up", "Volume Up"]
        onActivated: {
            volumeSlider.value = Math.min(volumeSlider.value + 0.05, 1.0)
            audioController.setVolume(volumeSlider.value)
        }
    }

    Shortcut {
        sequences: ["Down", "Volume Down"]
        onActivated: {
            volumeSlider.value = Math.max(volumeSlider.value - 0.05, 0.0)
            audioController.setVolume(volumeSlider.value)
        }
    }

    Component.onCompleted: {
        console.log("Finix Player - Original Design - Initialized")
    }

}
