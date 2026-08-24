import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: root

    readonly property MprisPlayer activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool hasPlayer: activePlayer !== null && activePlayer.trackTitle !== ""
    readonly property bool isPlaying: hasPlayer && activePlayer.playbackState === MprisPlaybackState.Playing

    property real progress: 0
    property real duration: activePlayer?.length ?? 1
    property real progressPercent: duration > 0 ? progress / duration : 0

    implicitWidth: hasPlayer ? contentRow.implicitWidth + 16 : 85
    implicitHeight: 28

    // Alineación explícita para evitar desplazar a otros elementos del Layout
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    Timer {
        interval: 1000
        running: hasPlayer && isPlaying
        repeat: true
        onTriggered: posPollProc.running = true
    }

    Process {
        id: posPollProc
        command: ["playerctl", "position"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseFloat(text.trim())
                if (!isNaN(val) && val >= 0)
                    root.progress = val * 1000000
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        border.color: "#313244"
        border.width: 1

        RowLayout {
            id: noMediaRow
            anchors.centerIn: parent
            spacing: 6
            visible: !root.hasPlayer
            opacity: !root.hasPlayer ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Text {
                text: "󰎇"
                font.pixelSize: 13
                color: "#6c7086"
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "No media"
                font.pixelSize: 10
                font.bold: true
                color: "#6c7086"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
            visible: root.hasPlayer
            opacity: root.hasPlayer ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Item {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    id: vinyl
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    radius: 8
                    color: "#11111b"

                    RotationAnimation on rotation {
                        running: root.isPlaying
                        from: vinyl.rotation
                        to: vinyl.rotation + 360
                        duration: 2500
                        loops: Animation.Infinite
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 5
                        height: 5
                        radius: 2.5
                        color: "#cba6f7"
                    }
                }
            }

            Item {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter
                clip: true

                Text {
                    id: titleText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.activePlayer?.trackTitle || ""
                    color: "#cdd6f4"
                    font.pixelSize: 10
                    font.bold: true

                    readonly property bool needsScroll: implicitWidth > 80
                    x: needsScroll ? 0 : (80 - implicitWidth) / 2

                    SequentialAnimation {
                        running: titleText.needsScroll && root.isPlaying
                        loops: Animation.Infinite

                        PauseAnimation { duration: 2000 }
                        NumberAnimation {
                            target: titleText
                            property: "x"
                            to: -(titleText.implicitWidth + 15)
                            duration: Math.max(1000, titleText.implicitWidth * 30)
                            easing.type: Easing.Linear
                        }
                        PropertyAction {
                            target: titleText
                            property: "x"
                            value: 80
                        }
                        NumberAnimation {
                            target: titleText
                            property: "x"
                            to: 0
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 12
                Layout.alignment: Qt.AlignVCenter
                color: "#45475a"
            }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 3

                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    Layout.alignment: Qt.AlignVCenter
                    radius: 10
                    color: "#cba6f7"

                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "󰏤" : "󰐊"
                        font.pixelSize: 11
                        color: "#11111b"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.activePlayer) root.activePlayer.togglePlaying()
                    }
                }

                Text {
                    text: "󰒵"
                    font.pixelSize: 12
                    color: "#a6adc8"
                    visible: Boolean(root.activePlayer && root.activePlayer.canGoNext)
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.activePlayer) root.activePlayer.next()
                    }
                }
            }

            Item {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 4
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: "#313244"

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Math.min(1, Math.max(0, root.progressPercent))
                        radius: 2
                        color: "#cba6f7"

                        Behavior on width { NumberAnimation { duration: 200 } }
                    }
                }
            }
        }
    }
}
