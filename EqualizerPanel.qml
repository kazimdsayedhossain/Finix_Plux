import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: equalizerPanel
    width: 400
    height: 300
    color: "#282828"
    radius: 10

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Label {
            text: "10-Band Equalizer"
            font.pixelSize: 18
            font.bold: true
            color: "#FFFFFF"
        }

        // Preset selector
        ComboBox {
            id: presetCombo
            Layout.fillWidth: true
            model: ["Flat", "Rock", "Jazz", "Classical", "Pop", "Electronic"]

            onCurrentTextChanged: {
                audioController.setEqualizerPreset(currentText)
            }
        }

        // EQ Sliders
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 10
            rowSpacing: 10
            columnSpacing: 5

            Repeater {
                model: 10

                delegate: ColumnLayout {
                    Layout.fillHeight: true
                    spacing: 5

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: [" 32", "64", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"][index]
                        font.pixelSize: 10
                        color: "#B3B3B3"
                 }

                                            Slider {
                                                id: eqSlider
                                                Layout.fillHeight: true
                                                Layout.alignment: Qt.AlignHCenter
                                                orientation: Qt.Vertical
                                                from: -12
                                                to: 12
                                                value: 0
                                                stepSize: 0.5

                                                onValueChanged: {
                                                    audioController.setEqualizerBand(index, value)
                                                }

                                                background: Rectangle {
                                                    x: eqSlider.leftPadding + eqSlider.availableWidth / 2 - width / 2
                                                    y: eqSlider.topPadding
                                                    implicitWidth: 4
                                                    implicitHeight: 200
                                                    width: implicitWidth
                                                    height: eqSlider.availableHeight
                                                    radius: 2
                                                    color: "#4E4E4E"

                                                    Rectangle {
                                                        y: eqSlider.visualPosition * parent.height
                                                        width: parent.width
                                                        height: parent.height - y
                                                        color: "#1DB954"
                                                        radius: 2
                                                    }
                                                }

                                                handle: Rectangle {
                                                    x: eqSlider.leftPadding + eqSlider.availableWidth / 2 - width / 2
                                                    y: eqSlider.topPadding + eqSlider.visualPosition * (eqSlider.availableHeight - height)
                                                    implicitWidth: 16
                                                    implicitHeight: 16
                                                    radius: 8
                                                    color: eqSlider.pressed ? "#1DB954" : "#FFFFFF"
                                                    border.color: "#1DB954"
                                                    border.width: 2
                                                }
                                            }

                                            Label {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: eqSlider.value.toFixed(1) + " dB"
                                                font.pixelSize: 9
                                                color: "#B3B3B3"
                                            }
                                        }
                                    }
                                }

                                // Reset button
                                Button {
                                    Layout.fillWidth: true
                                    text: "Reset to Flat"

                                    onClicked: {
                                        presetCombo.currentIndex = 0
                                        // Reset all sliders programmatically
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.pressed ? "#1DB954" : "#3E3E3E"
                                        border.color: "#1DB954"
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#FFFFFF"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
