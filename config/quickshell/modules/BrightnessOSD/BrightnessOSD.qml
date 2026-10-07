import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../core"

PanelWindow {
    id: root
    visible: false

    property int actualBrightness: 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: root.visible = false
    }

    Process {
        id: syncBrightnessProc
        command: ["brightnessctl", "g"]
        stdout: SplitParser {
            onRead: (data) => {
                let current = parseInt(data.trim(), 10)
                if (isNaN(current)) return

                if (maxBrightnessProc.maxVal === 0) {
                    maxBrightnessProc.running = true
                } else {
                    let percent = Math.round((current / maxBrightnessProc.maxVal) * 100)
                    root.actualBrightness = percent
                    root.visible = true
                    hideTimer.restart()
                }
            }
        }
    }

    Process {
        id: maxBrightnessProc
        property int maxVal: 0
        command: ["brightnessctl", "m"]
        stdout: SplitParser {
            onRead: (data) => {
                let max = parseInt(data.trim(), 10)
                if (!isNaN(max) && max > 0) {
                    maxBrightnessProc.maxVal = max
                    syncBrightnessProc.running = true
                }
            }
        }
    }

    IpcHandler {
        target: "brightness"

        function raise(): void {
            changeBrightnessProc.command = ["brightnessctl", "s", "+5%"]
            changeBrightnessProc.running = true
        }

        function lower(): void {
            changeBrightnessProc.command = ["brightnessctl", "s", "5%-"]
            changeBrightnessProc.running = true
        }
    }

    Process {
        id: changeBrightnessProc
        onExited: {
            syncBrightnessProc.running = true
        }
    }

    anchors {
        right: true
    }
    margins.right: 20

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

            // 1. Contenedor rígido para centrado absoluto del icono
            Item {
                Layout.fillWidth: true
                implicitHeight: 28

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
					anchors.horizontalCenterOffset: -3 // Ajusta a 1 o -1 si la tipografía viene desplazada                    
					text: root.actualBrightness > 50 ? "󰃠" : "󰃟"
                    font.pixelSize: 18
                    color: Theme.colors.peach

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // 2. Carril de Brillo
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
                        
                        height: parent.height * Math.min(Math.max(root.actualBrightness / 100.0, 0.0), 1.0)
                        color: Theme.colors.peach
                        radius: 12

                        Behavior on height {
                            NumberAnimation { duration: 80 }
                        }
                    }
                }
            }

            // 3. Texto del Porcentaje
            Item {
                Layout.fillWidth: true
                implicitHeight: 18

                Text {
                    anchors.centerIn: parent
                    text: root.actualBrightness + "%"
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.colors.text

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
