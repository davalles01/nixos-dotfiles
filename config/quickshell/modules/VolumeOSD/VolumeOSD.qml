import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../core"

PanelWindow {
    id: root
    visible: false

    property int actualVolume: 0
    property bool isMuted: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: root.visible = false
    }

    Process {
        id: syncVolProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: (data) => {
                let text = data.trim()
                if (!text) return

                let muted = text.includes("[MUTED]")
                let parts = text.split(" ")
                
                if (parts.length >= 2) {
                    let vol = Math.round(parseFloat(parts[1]) * 100)
                    root.actualVolume = vol
                    root.isMuted = muted

                    root.visible = true
                    hideTimer.restart()
                }
            }
        }
    }

    IpcHandler {
        target: "volume"

        function raise(): void {
            changeVolProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]
            changeVolProc.running = true
        }

        function lower(): void {
            changeVolProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
            changeVolProc.running = true
        }

        function toggleMute(): void {
            changeVolProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
            changeVolProc.running = true
        }
    }

    Process {
        id: changeVolProc
        onExited: {
            syncVolProc.running = true
        }
    }

    anchors {
        right: true
    }
    margins.right: 20

    // Cambio a implicitWidth / implicitHeight
    implicitWidth: 56
    implicitHeight: 240
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.crust
        radius: 16
        border.color: Theme.colors.surface1
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: root.isMuted ? "󰝟" : (root.actualVolume > 50 ? "󰕾" : "󰖀")
                font.pixelSize: 18
                color: root.isMuted ? Theme.colors.subtext1 : Theme.colors.peach
            }

            Item {
                id: trackContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: Theme.colors.surface0
                    clip: true

                    Rectangle {
                        id: fillBar
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        
                        height: parent.height * Math.min(Math.max(root.actualVolume / 100.0, 0.0), 1.0)
                        color: root.isMuted ? Theme.colors.surface2 : Theme.colors.peach
                        radius: 12

                        Behavior on height {
                            NumberAnimation { duration: 80 }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: root.actualVolume + "%"
                font.pixelSize: 11
                font.bold: true
                color: root.isMuted ? Theme.colors.subtext1 : Theme.colors.text
            }
        }
    }
}
