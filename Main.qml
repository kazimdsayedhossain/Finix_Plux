import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.lottieqt 1.0
import com.finix.audioplayer 1.0
import Qt.labs.platform 1.1
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    title: qsTr("Finix Player - Advanced OOP Music Player")

    // ==================== COLOR SCHEME ====================
    readonly property color backgroundColor: "#0A0E27"
    readonly property color surfaceColor: "#1A1F3A"
    readonly property color surfaceLightColor: "#252B4A"
    readonly property color primaryColor: "#3D5AFE"
    readonly property color accentColor: "#FF4081"
    readonly property color textColor: "#E0E6F0"
    readonly property color textSecondaryColor: "#8891A8"

    // ==================== AUDIO CONTROLLER ====================
    AudioController {
        id: audioController
    }

    // ==================== MUSIC LIBRARY ====================
    // MusicLibrary {
    //     id: musicLibrary
    // }

    // ==================== BACKGROUND ====================
    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
    }

    // ==================== MAIN LAYOUT ====================
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ========== LEFT SIDEBAR ==========
        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: root.surfaceColor

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Logo/Title
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "🎵"
                            font.pixelSize: 48
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Finix Player")
                            font.pixelSize: 24
                            font.bold: true
                            color: root.textColor
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("OOP Music Player")
                            font.pixelSize: 11
                            color: root.textSecondaryColor
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    height: 1
                    color: root.surfaceLightColor
                }

                // Navigation Buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    spacing: 8

                    NavigationButton {
                        icon: "🏠"
                        text: qsTr("Home")
                        active: stackView.currentItem === homePage
                        onClicked: stackView.replace(homePage)

                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                    }

                    NavigationButton {
                        icon: "🎚️"
                        text: qsTr("Audio Effects")
                        active: stackView.currentItem === effectsPage
                        onClicked: stackView.replace(effectsPage)

                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                    }

                    NavigationButton {
                        icon: "📚"
                        text: qsTr("Library")
                        active: stackView.currentItem === libraryPage
                        onClicked: stackView.replace(libraryPage)

                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                    }

                    NavigationButton {
                        icon: "⚙️"
                        text: qsTr("Settings")
                        active: stackView.currentItem === settingsPage
                        onClicked: stackView.replace(settingsPage)

                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                    }
                }

                Item { Layout.fillHeight: true }

                // Stats Section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.bottomMargin: 20
                    Layout.preferredHeight: 120
                    color: root.surfaceLightColor
                    radius: 12

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Label {
                            text: qsTr("📊 Statistics")
                            font.pixelSize: 13
                            font.bold: true
                            color: root.textColor
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Label {
                                text: qsTr("Tracks:")
                                font.pixelSize: 11
                                color: root.textSecondaryColor
                            }

                            Label {
                                text: musicLibrary.trackCount
                                font.pixelSize: 11
                                font.bold: true
                                color: root.primaryColor
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Label {
                                text: qsTr("Total Created:")
                                font.pixelSize: 11
                                color: root.textSecondaryColor
                            }

                            Label {
                                text: "Using Static OOP"
                                font.pixelSize: 11
                                font.bold: true
                                color: root.accentColor
                            }
                        }

                        Label {
                            text: qsTr("All 15 OOP Features ✓")
                            font.pixelSize: 9
                            color: "#4CAF50"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // ========== MAIN CONTENT AREA ==========
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Content Stack View
            StackView {
                id: stackView
                Layout.fillWidth: true
                Layout.fillHeight: true
                initialItem: homePage

                // ========== PAGE 1: HOME ==========
                Component {
                    id: homePage

                    Rectangle {
                        color: root.backgroundColor

                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            contentWidth: availableWidth

                            ColumnLayout {
                                width: parent.width
                                spacing: 30

                                // Header
                                Label {
                                    text: qsTr("Welcome to Finix Player")
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: root.textColor
                                    Layout.topMargin: 30
                                    Layout.leftMargin: 30
                                }

                                Label {
                                    text: qsTr("Advanced Object-Oriented Programming Music Player")
                                    font.pixelSize: 14
                                    color: root.textSecondaryColor
                                    Layout.leftMargin: 30
                                }

                                // Now Playing Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 30
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
                                            width: 200
                                            height: 200
                                            radius: 12
                                            color: root.surfaceLightColor

                                            Image {
                                                id: albumArt
                                                anchors.fill: parent
                                                source: audioController.thumbnailUrl || ""
                                                fillMode: Image.PreserveAspectCrop
                                                visible: source != ""
                                                layer.enabled: true
                                                layer.effect: OpacityMask {
                                                    maskSource: Rectangle {
                                                        width: albumArt.width
                                                        height: albumArt.height
                                                        radius: 12
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

                                        // Track Info
                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: audioController.trackTitle || qsTr("No track playing")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                            elide: Text.ElideRight
                                            Layout.maximumWidth: 500
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: audioController.trackArtist || qsTr("Unknown Artist")
                                            font.pixelSize: 14
                                            color: root.textSecondaryColor
                                        }

                                        Item { Layout.fillHeight: true }
                                    }
                                }

                                // Quick Actions
                                GridLayout {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 30
                                    Layout.rightMargin: 30
                                    columns: 3
                                    rowSpacing: 20
                                    columnSpacing: 20

                                    QuickActionCard {
                                        icon: "📁"
                                        title: qsTr("Open File")
                                        description: qsTr("Play local audio file")
                                        onClicked: fileDialog.open()
                                    }

                                    QuickActionCard {
                                        icon: "🎬"
                                        title: qsTr("YouTube")
                                        description: qsTr("Play from YouTube")
                                        onClicked: youtubeDialog.open()
                                    }

                                    QuickActionCard {
                                        icon: "📚"
                                        title: qsTr("Library")
                                        description: qsTr("Browse your music")
                                        onClicked: stackView.replace(libraryPage)
                                    }
                                }

                                // OOP Features Showcase
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 30
                                    Layout.preferredHeight: oopShowcase.height + 40
                                    color: "#1E3A5F"
                                    radius: 12
                                    border.color: root.primaryColor
                                    border.width: 2

                                    ColumnLayout {
                                        id: oopShowcase
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Label {
                                            text: qsTr("🎓 OOP Features Implemented")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        GridLayout {
                                            Layout.fillWidth: true
                                            columns: 3
                                            rowSpacing: 10
                                            columnSpacing: 15

                                            OOPFeatureBadge { text: "✓ Classes & Objects" }
                                            OOPFeatureBadge { text: "✓ Constructors" }
                                            OOPFeatureBadge { text: "✓ Destructors" }
                                            OOPFeatureBadge { text: "✓ Function Overloading" }
                                            OOPFeatureBadge { text: "✓ Operator Overloading" }
                                            OOPFeatureBadge { text: "✓ Friend Functions" }
                                            OOPFeatureBadge { text: "✓ Static Members" }
                                            OOPFeatureBadge { text: "✓ Inheritance" }
                                            OOPFeatureBadge { text: "✓ Polymorphism" }
                                            OOPFeatureBadge { text: "✓ Virtual Functions" }
                                            OOPFeatureBadge { text: "✓ Abstract Classes" }
                                            OOPFeatureBadge { text: "✓ Function Templates" }
                                            OOPFeatureBadge { text: "✓ Class Templates" }
                                            OOPFeatureBadge { text: "✓ Exception Handling" }
                                            OOPFeatureBadge { text: "✓ STL Containers" }
                                        }
                                    }
                                }

                                Item { Layout.preferredHeight: 50 }
                            }
                        }
                    }
                }

                // ========== PAGE 2: AUDIO EFFECTS ==========
                Component {
                    id: effectsPage

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
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 20
                                    Layout.preferredHeight: gainContent.height + 60
                                    color: root.surfaceColor
                                    radius: 12
                                    border.color: root.surfaceLightColor
                                    border.width: 1

                                    ColumnLayout {
                                        id: gainContent
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 20

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: qsTr("🔊 Volume Gain Boost")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: qsTr("Amplify audio beyond 100% volume")
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
                                            Layout.alignment: Qt.AlignHCenter
                                            text: gainSlider.value > 1.0 ?
                                                qsTr("⚠️ Warning: High gain may cause distortion") :
                                                qsTr("Normal audio level")
                                            font.pixelSize: 10
                                            color: gainSlider.value > 1.0 ? "#FFA500" : root.textSecondaryColor
                                        }
                                    }
                                }

                                // Balance/Pan Control
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 20
                                    Layout.preferredHeight: balanceContent.height + 60
                                    color: root.surfaceColor
                                    radius: 12
                                    border.color: root.surfaceLightColor
                                    border.width: 1

                                    ColumnLayout {
                                        id: balanceContent
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 20

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: qsTr("🎚️ Stereo Balance")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: qsTr("Adjust left/right audio balance")
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
                                            Layout.alignment: Qt.AlignHCenter
                                            text: balanceSlider.value < -0.1 ?
                                                qsTr("← Left: " + Math.abs(balanceSlider.value * 100).toFixed(0) + "%") :
                                                balanceSlider.value > 0.1 ?
                                                qsTr("Right: " + (balanceSlider.value * 100).toFixed(0) + "% →") :
                                                qsTr("Center (Balanced)")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                        }
                                    }
                                }

                                // Playback Speed/Pitch
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 20
                                    Layout.preferredHeight: speedContent.height + 60
                                    color: root.surfaceColor
                                    radius: 12
                                    border.color: root.surfaceLightColor
                                    border.width: 1

                                    ColumnLayout {
                                        id: speedContent
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 20

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: qsTr("⏩ Playback Speed")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: qsTr("Change playback speed (affects pitch)")
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
                                                    border.color: Math.abs(speedSlider.value - 0.5) < 0.01 ? root.primaryColor : "transparent"
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
                                                    border.color: Math.abs(speedSlider.value - 0.75) < 0.01 ? root.primaryColor : "transparent"
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
                                                    border.color: Math.abs(speedSlider.value - 1.25) < 0.01 ? root.primaryColor : "transparent"
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
                                                    border.color: Math.abs(speedSlider.value - 1.5) < 0.01 ? root.primaryColor : "transparent"
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
                                                    border.color: Math.abs(speedSlider.value - 2.0) < 0.01 ? root.primaryColor : "transparent"
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
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 20
                                    Layout.preferredHeight: fadeContent.height + 60
                                    color: root.surfaceColor
                                    radius: 12
                                    border.color: root.surfaceLightColor
                                    border.width: 1

                                    ColumnLayout {
                                        id: fadeContent
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: qsTr("🎼 Fade In Effect")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: qsTr("Gradually increase volume when playback starts")
                                            font.pixelSize: 12
                                            color: root.textSecondaryColor
                                        }

                                        CheckBox {
                                            id: fadeInCheck
                                            Layout.alignment: Qt.AlignHCenter
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
                                            Layout.alignment: Qt.AlignHCenter
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

                // ========== PAGE 3: LIBRARY ==========
                Component {
                    id: libraryPage

                    Rectangle {
                        color: root.backgroundColor

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 20

                            // Header
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 20
                                Layout.leftMargin: 30
                                Layout.rightMargin: 30
                                spacing: 20

                                Label {
                                    text: qsTr("Music Library")
                                    font.pixelSize: 28
                                    font.bold: true
                                    color: root.textColor
                                }

                                Item { Layout.fillWidth: true }

                                Button {
                                    text: qsTr("📂 Add Folder")
                                    implicitHeight: 40

                                    onClicked: folderDialog.open()

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
                                        font.pixelSize: 13
                                    }
                                }

                                Button {
                                    text: qsTr("💾 Save Library")
                                    implicitHeight: 40

                                    onClicked: {
                                        if (musicLibrary.saveToFile("library.json")) {
                                            console.log("Library saved successfully")
                                        }
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.pressed ? "#4CAF50" : root.surfaceLightColor
                                        border.color: "#4CAF50"
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: root.textColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 13
                                    }
                                }
                            }

                            // Search Bar
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 30
                                Layout.rightMargin: 30
                                Layout.preferredHeight: 50
                                color: root.surfaceColor
                                radius: 25

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 10

                                    Label {
                                        text: "🔍"
                                        font.pixelSize: 18
                                    }

                                    TextField {
                                        id: searchField
                                        Layout.fillWidth: true
                                        placeholderText: qsTr("Search tracks, artists, albums...")
                                        color: root.textColor
                                        background: Item {}

                                        onTextChanged: {
                                            musicLibrary.searchTracks(text)
                                        }
                                    }
                                }
                            }

                            // Library Stats
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 30
                                Layout.rightMargin: 30
                                Layout.preferredHeight: 80
                                color: root.surfaceColor
                                radius: 12

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    columns: 4
                                    columnSpacing: 30

                                    LibraryStatItem {
                                        icon: "🎵"
                                        label: qsTr("Tracks")
                                        value: musicLibrary.trackCount
                                    }

                                    LibraryStatItem {
                                        icon: "🎤"
                                        label: qsTr("Artists")
                                        value: musicLibrary.artistCount
                                    }

                                    LibraryStatItem {
                                        icon: "💿"
                                        label: qsTr("Albums")
                                        value: musicLibrary.albumCount
                                    }

                                    LibraryStatItem {
                                        icon: "🎸"
                                        label: qsTr("Genres")
                                        value: musicLibrary.genreCount
                                    }
                                }
                            }

                            // Track List
                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 30
                                Layout.rightMargin: 30
                                Layout.bottomMargin: 20
                                clip: true
                                spacing: 8

                                model: musicLibrary.model

                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 70
                                    color: mouseArea.containsMouse ? root.surfaceLightColor : root.surfaceColor
                                    radius: 8

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true

                                        onClicked: {
                                            audioController.openFile(model.path)
                                        }
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
                                            spacing: 5

                                            Label {
                                                text: model.title || "Unknown"
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: root.textColor
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            RowLayout {
                                                spacing: 10

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
                                            Layout.preferredWidth: 60
                                            horizontalAlignment: Text.AlignRight
                                        }

                                        Button {
                                            text: "▶"
                                            implicitWidth: 40
                                            implicitHeight: 40

                                            onClicked: {
                                                audioController.openFile(model.path)
                                            }

                                            background: Rectangle {
                                                radius: 20
                                                color: parent.pressed ? root.primaryColor : "transparent"
                                                border.color: root.primaryColor
                                                border.width: 2
                                            }

                                            contentItem: Text {
                                                text: parent.text
                                                color: root.primaryColor
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                font.pixelSize: 14
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ========== PAGE 4: SETTINGS ==========
                Component {
                    id: settingsPage

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
                                    text: qsTr("Settings & About")
                                    font.pixelSize: 28
                                    font.bold: true
                                    color: root.textColor
                                    Layout.topMargin: 20
                                    Layout.leftMargin: 30
                                }

                                // App Info
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 30
                                    Layout.preferredHeight: appInfoLayout.height + 40
                                    color: root.surfaceColor
                                    radius: 12

                                    ColumnLayout {
                                        id: appInfoLayout
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Label {
                                            text: qsTr("📱 Application Info")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        InfoRow {
                                            label: qsTr("Name:")
                                            value: qsTr("Finix Player")
                                        }

                                        InfoRow {
                                            label: qsTr("Version:")
                                            value: qsTr("1.0.0")
                                        }

                                        InfoRow {
                                            label: qsTr("Framework:")
                                            value: qsTr("Qt 6.10 + C++ OOP")
                                        }

                                        InfoRow {
                                            label: qsTr("Features:")
                                            value: qsTr("15 OOP Concepts Implemented")
                                        }
                                    }
                                }

                                // OOP Features Detail
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 30
                                    Layout.preferredHeight: oopDetailLayout.height + 40
                                    color: root.surfaceColor
                                    radius: 12

                                    ColumnLayout {
                                        id: oopDetailLayout
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Label {
                                            text: qsTr("🎓 OOP Features Implementation")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        OOPFeatureDetail {
                                            number: "1-3"
                                            title: "Classes, Constructors, Destructors"
                                            description: "AudioController, Track, MusicLibrary with proper initialization/cleanup"
                                        }

                                        OOPFeatureDetail {
                                            number: "4"
                                            title: "Function Overloading"
                                            description: "Track::setDuration() with multiple signatures, Track::play() overloads"
                                        }

                                        OOPFeatureDetail {
                                            number: "5"
                                            title: "Operator Overloading"
                                            description: "Track comparison (==, <), increment (++), stream (<<) operators"
                                        }

                                        OOPFeatureDetail {
                                            number: "6"
                                            title: "Friend Functions & Classes"
                                            description: "printTrackDetails() friend function, PlaylistManager friend class"
                                        }

                                        OOPFeatureDetail {
                                            number: "7"
                                            title: "Static Members"
                                            description: "Track::getTotalTracksCreated(), Track::formatDuration()"
                                        }

                                        OOPFeatureDetail {
                                            number: "8-11"
                                            title: "Inheritance & Polymorphism"
                                            description: "AudioEffect base → Equalizer, Reverb, Bass Boost with virtual functions"
                                        }

                                        OOPFeatureDetail {
                                            number: "12-13"
                                            title: "Templates"
                                            description: "CircularBuffer<T> for queue, LRUCache<K,V> for album art cache"
                                        }

                                        OOPFeatureDetail {
                                            number: "14"
                                            title: "Exception Handling"
                                            description: "AudioException hierarchy with try-catch error handling"
                                        }

                                        OOPFeatureDetail {
                                            number: "15"
                                            title: "STL Containers"
                                            description: "std::vector, std::unique_ptr, std::map, std::list"
                                        }
                                    }
                                }

                                // Developer Testing
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 30
                                    Layout.preferredHeight: devTestLayout.height + 40
                                    color: "#673AB7"
                                    opacity: 0.8
                                    radius: 12

                                    ColumnLayout {
                                        id: devTestLayout
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Label {
                                            text: qsTr("🧪 Developer Testing")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: "white"
                                        }

                                        Label {
                                            text: qsTr("Test all OOP features and view console output")
                                            font.pixelSize: 12
                                            color: "white"
                                            opacity: 0.8
                                        }

                                        Button {
                                            Layout.alignment: Qt.AlignLeft
                                            text: qsTr("🧪 Test All OOP Features")
                                            implicitWidth: 250
                                            implicitHeight: 45

                                            onClicked: {
                                                console.log("===== TESTING ALL OOP FEATURES =====")
                                                audioController.testAllOOPFeatures()
                                                console.log("===== TEST COMPLETED - CHECK OUTPUT =====")
                                                testResultLabel.visible = true
                                            }

                                            background: Rectangle {
                                                radius: 8
                                                color: parent.pressed ? "#9C27B0" : "white"
                                            }

                                            contentItem: Text {
                                                text: parent.text
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: parent.pressed ? "white" : "#673AB7"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }

                                        Label {
                                            id: testResultLabel
                                            visible: false
                                            text: qsTr("✓ Tests completed! Check application output/console for results.")
                                            font.pixelSize: 11
                                            color: "#4CAF50"
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                // About
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.margins: 30
                                    Layout.preferredHeight: aboutLayout.height + 40
                                    color: root.surfaceColor
                                    radius: 12

                                    ColumnLayout {
                                        id: aboutLayout
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Label {
                                            text: qsTr("ℹ️ About")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Label {
                                            text: qsTr("Finix Player is an advanced music player demonstrating comprehensive Object-Oriented Programming concepts in C++ and Qt.")
                                            font.pixelSize: 13
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }

                                        Label {
                                            text: qsTr("Features include local file playback, YouTube audio streaming, audio effects, music library management, and more.")
                                            font.pixelSize: 13
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }

                                        Label {
                                            text: qsTr("© 2024 Finix Player. Built with Qt & Modern C++.")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                            Layout.topMargin: 10
                                        }
                                    }
                                }

                                Item { Layout.preferredHeight: 50 }
                            }
                        }
                    }
                }
            }

            // ========== PLAYBACK CONTROLS (BOTTOM BAR) ==========
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: root.surfaceColor
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: -3
                    radius: 10
                    samples: 17
                    color: "#80000000"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    // Progress Bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Label {
                            text: audioController.formattedPosition
                            font.pixelSize: 11
                            color: root.textSecondaryColor
                            Layout.preferredWidth: 50
                        }

                        Slider {
                            id: progressSlider
                            Layout.fillWidth: true
                            from: 0
                            to: audioController.duration
                            value: audioController.position

                            onMoved: {
                                audioController.seek(value)
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
                                    color: root.primaryColor
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                implicitWidth: 14
                                implicitHeight: 14
                                radius: 7
                                color: progressSlider.pressed ? root.primaryColor : root.textColor
                                border.color: root.primaryColor
                                border.width: 2
                            }
                        }

                        Label {
                            text: audioController.formattedDuration
                            font.pixelSize: 11
                            color: root.textSecondaryColor
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // Controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        // Track Info (Left)
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Rectangle {
                                width: 50
                                height: 50
                                radius: 6
                                color: root.surfaceLightColor

                                Image {
                                    anchors.fill: parent
                                    source: audioController.thumbnailUrl || ""
                                    fillMode: Image.PreserveAspectCrop
                                    visible: source != ""
                                }

                                Label {
                                    anchors.centerIn: parent
                                    text: "🎵"
                                    font.pixelSize: 24
                                    visible: audioController.thumbnailUrl === ""
                                }
                            }

                            ColumnLayout {
                                spacing: 2

                                Label {
                                    text: audioController.trackTitle || qsTr("No track")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: root.textColor
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 250
                                }

                                Label {
                                    text: audioController.trackArtist || qsTr("Unknown")
                                    font.pixelSize: 11
                                    color: root.textSecondaryColor
                                }
                            }
                        }

                        // Playback Controls (Center)
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 15

                            RoundButton {
                                text: "⏮"
                                implicitWidth: 40
                                implicitHeight: 40
                                font.pixelSize: 16

                                background: Rectangle {
                                    radius: 20
                                    color: parent.pressed ? root.surfaceLightColor : "transparent"
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: root.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: parent.font.pixelSize
                                }
                            }

                            RoundButton {
                                text: audioController.isPlaying ? "⏸" : "▶"
                                implicitWidth: 50
                                implicitHeight: 50
                                font.pixelSize: 20

                                onClicked: {
                                    if (audioController.isPlaying) {
                                        audioController.pause()
                                    } else {
                                        audioController.play()
                                    }
                                }

                                background: Rectangle {
                                    radius: 25
                                    color: parent.pressed ? Qt.lighter(root.primaryColor, 1.2) : root.primaryColor
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: parent.font.pixelSize
                                }
                            }

                            RoundButton {
                                text: "⏭"
                                implicitWidth: 40
                                implicitHeight: 40
                                font.pixelSize: 16

                                background: Rectangle {
                                    radius: 20
                                    color: parent.pressed ? root.surfaceLightColor : "transparent"
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: root.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: parent.font.pixelSize
                                }
                            }
                        }

                        // Volume Control (Right)
                        RowLayout {
                            Layout.alignment: Qt.AlignRight
                            spacing: 10

                            Label {
                                text: "🔊"
                                font.pixelSize: 18
                            }

                            Slider {
                                id: volumeSlider
                                from: 0
                                to: 1
                                value: 0.5
                                implicitWidth: 120

                                onValueChanged: {
                                    audioController.setVolume(value)
                                }

                                background: Rectangle {
                                    x: volumeSlider.leftPadding
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 120
                                    implicitHeight: 4
                                    width: volumeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: root.surfaceLightColor

                                    Rectangle {
                                        width: volumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: root.primaryColor
                                        radius: 2
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
                                }
                            }

                            Label {
                                text: Math.round(volumeSlider.value * 100) + "%"
                                font.pixelSize: 11
                                color: root.textSecondaryColor
                                Layout.preferredWidth: 40
                            }
                        }
                    }
                }
            }
        }
    }

    // ========== DIALOGS ==========

    FileDialog {
        id: fileDialog
        title: qsTr("Select Audio File")
        nameFilters: ["Audio files (*.mp3 *.flac *.ogg *.wav *.m4a *.aac)", "All files (*)"]
        onAccepted: {
            var path = fileDialog.file.toString().replace("file:///", "")
            audioController.openFile(path)
        }
    }

    FolderDialog {
        id: folderDialog
        title: qsTr("Select Music Folder")
        onAccepted: {
            var path = folderDialog.folder.toString().replace("file:///", "")
            musicLibrary.scanDirectory(path)
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
                font.pixelSize: 20
                font.bold: true
                color: root.textColor
            }

            Label {
                text: qsTr("Enter song name or YouTube URL")
                font.pixelSize: 12
                color: root.textSecondaryColor
            }

            TextField {
                id: youtubeInput
                Layout.fillWidth: true
                placeholderText: qsTr("e.g., Imagine Dragons - Believer")
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
                    implicitHeight: 40

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
                        font.pixelSize: 13
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Play")
                    implicitHeight: 40
                    enabled: youtubeInput.text.length > 0

                    onClicked: {
                        audioController.playYouTubeAudio(youtubeInput.text)
                        youtubeDialog.close()
                        youtubeInput.text = ""
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.enabled ? (parent.pressed ? Qt.lighter(root.primaryColor, 1.2) : root.primaryColor) : root.surfaceLightColor
                    }

                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "white" : root.textSecondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
            }
        }
    }

    // Scan Progress Dialog
    Popup {
        id: scanProgressDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 400
        height: 200
        closePolicy: Popup.NoAutoClose

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
                to: 100
                value: 50
                indeterminate: true

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
                        width: parent.width
                        height: parent.height
                        radius: 4
                        color: root.primaryColor
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Please wait...")
                font.pixelSize: 12
                color: root.textSecondaryColor
                horizontalAlignment: Text.AlignHCenter
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

    // ========== CUSTOM COMPONENTS ==========


        component NavigationButton: Button {
            property string icon: ""
            property bool active: false

            implicitHeight: 50

            background: Rectangle {
                radius: 8
                color: active ? root.primaryColor : (parent.hovered ? root.surfaceLightColor : "transparent")
            }

            contentItem: RowLayout {
                spacing: 15

                Label {
                    text: icon
                    font.pixelSize: 20
                    implicitWidth: 30
                }

                Label {
                    text: parent.parent.text
                    font.pixelSize: 14
                    font.bold: active
                    color: root.textColor
                }
            }
        }

        component QuickActionCard: Rectangle {
            property string icon: ""
            property string title: ""
            property string description: ""
            signal clicked()

            implicitWidth: 200
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
                spacing: 10

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: icon
                    font.pixelSize: 36
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

        component OOPFeatureBadge: Rectangle {
            property string text: ""

            implicitHeight: 35
            color: root.surfaceLightColor
            radius: 6

            Label {
                anchors.centerIn: parent
                text: parent.text
                font.pixelSize: 11
                color: root.textColor
            }
        }

        component LibraryStatItem: ColumnLayout {
            property string icon: ""
            property string label: ""
            property int value: 0

            spacing: 5

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: icon
                font.pixelSize: 24
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: value.toString()
                font.pixelSize: 20
                font.bold: true
                color: root.primaryColor
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: label
                font.pixelSize: 11
                color: root.textSecondaryColor
            }
        }

        component InfoRow: RowLayout {
            property string label: ""
            property string value: ""

            spacing: 10

            Label {
                text: label
                font.pixelSize: 13
                color: root.textSecondaryColor
                implicitWidth: 120
            }

            Label {
                text: value
                font.pixelSize: 13
                font.bold: true
                color: root.textColor
            }
        }

        component OOPFeatureDetail: Item {
            property string number: ""
            property string title: ""
            property string description: ""

            implicitHeight: contentLayout.implicitHeight
            implicitWidth: contentLayout.implicitWidth

            ColumnLayout {
                id: contentLayout
                anchors.fill: parent
                spacing: 5

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.surfaceLightColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 15

                    Rectangle {
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        radius: 25
                        color: root.primaryColor

                        Label {
                            anchors.centerIn: parent
                            text: number
                            font.pixelSize: 14
                            font.bold: true
                            color: "white"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: title
                            font.pixelSize: 14
                            font.bold: true
                            color: root.textColor
                        }

                        Label {
                            text: description
                            font.pixelSize: 12
                            color: root.textSecondaryColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        // Helper function for formatting duration
        function formatDuration(milliseconds) {
            if (milliseconds <= 0) return "0:00"
            var totalSeconds = Math.floor(milliseconds / 1000)
            var minutes = Math.floor(totalSeconds / 60)
            var seconds = totalSeconds % 60
            return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
        }

        // ========== CONNECTIONS ==========
        Connections {
            target: musicLibrary

            function onScanStarted() {
                console.log("Scan started")
            }

            function onScanCompleted(count) {
                console.log("Scan completed. Found", count, "tracks")
                scanProgressDialog.close()
            }

            function onScanProgress(current, total) {
                console.log("Scanning:", current, "/", total)
            }
        }

        // ========== COMPONENT COMPLETION ==========
        Component.onCompleted: {
            console.log("Finix Player initialized with all OOP features")
            console.log("- Classes & Objects ✓")
            console.log("- Constructors & Destructors ✓")
            console.log("- Function & Operator Overloading ✓")
            console.log("- Friend Functions & Classes ✓")
            console.log("- Static Members ✓")
            console.log("- Inheritance & Polymorphism ✓")
            console.log("- Virtual Functions & Abstract Classes ✓")
            console.log("- Templates (Function & Class) ✓")
            console.log("- Exception Handling ✓")
            console.log("- STL Containers ✓")
            console.log("All 15 OOP features implemented!")

            // Try to load saved library
            if (musicLibrary.loadFromFile("library.json")) {
                console.log("Loaded saved library")
            }
        }
    }
