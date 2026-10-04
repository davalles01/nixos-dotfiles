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

    // Temporizador para ocultar el OSD tras 1.5s
    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: root.visible = false
    }

    // Proceso para consultar y actualizar el volumen únicamente bajo demanda
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

                    // Mostrar el OSD y reiniciar el temporizador
                    root.visible = true
                    hideTimer.restart()
                }
            }
        }
    }

    // Handler IPC: Invocado únicamente desde las teclas multimedia
    IpcHandler {
        target: "volume"

        function raise(): void {
            // Sin límite asignado: incrementa libremente
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
            // Tras ejecutar el cambio, leemos el estado actual para sincronizar y mostrar el OSD
            syncVolProc.running = true
        }
    }

    // Posicionamiento en el lateral derecho
    anchors {
        right: true
    }
    margins.right: 20

    width: 56
    height: 240
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

            // 1. Icono de volumen centrado
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.isMuted ? "󰝟" : (root.actualVolume > 50 ? "󰕾" : "󰖀")
                font.pixelSize: 18
                color: root.isMuted ? Theme.colors.subtext1 : Theme.colors.peach
            }

            // 2. Carril de Volumen (Track + Fill)
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
                        
                        // La barra visual mantendrá el llenado completo al llegar o superar el 100%
                        height: parent.height * Math.min(Math.max(root.actualVolume / 100.0, 0.0), 1.0)
                        color: root.isMuted ? Theme.colors.surface2 : Theme.colors.peach
                        radius: 12

                        Behavior on height {
                            NumberAnimation { duration: 80 }
                        }
                    }
                }
            }

            // 3. Texto del porcentaje (muestra el valor numérico real, e.g. 135%)
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.actualVolume + "%"
                font.pixelSize: 11
                font.bold: true
                color: root.isMuted ? Theme.colors.subtext1 : Theme.colors.text
            }
        }
    }
}
