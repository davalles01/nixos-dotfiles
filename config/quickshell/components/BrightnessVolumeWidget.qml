import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../services"

Rectangle {
    id: root

    // Dimensiones implícitas dinámicas
    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: 28

    // Propiedades para comunicar el tamaño al RowLayout superior
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignVCenter

    color: "#313244"
    radius: implicitHeight / 2

    property int volume: 0
    property bool isMuted: false

    BrightnessService { id: brightSvc }

    property int brightnessPct: brightSvc.maxBrightness > 0 ? Math.round((brightSvc.brightness / brightSvc.maxBrightness) * 100) : 0

    property string moonIcon: {
        if (brightnessPct > 80) return "󰽢"
        if (brightnessPct > 60) return "󰽦"
        if (brightnessPct > 40) return "󰽣"
        if (brightnessPct > 20) return "󰽥"
        return "󰽤"
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                let text = data.trim()
                root.isMuted = text.includes("[MUTED]")
                let parts = text.split(" ")
                if (parts.length >= 2) {
                    let val = parseFloat(parts[1])
                    if (!isNaN(val)) root.volume = Math.round(val * 100)
                }
            }
        }
    }

    Process {
        id: volSubscriber
        command: ["pw-mon"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("changed") || data.includes("node")) volProc.running = true
            }
        }
    }

    Component.onCompleted: volProc.running = true

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 12

        // Icono DND si está activo
        Text {
            visible: DndService.dndActive
            text: "󰂛"
            color: "#f38ba8"
            Layout.alignment: Qt.AlignVCenter
        }

        // Brillo
        Text { 
            text: root.moonIcon + " " + root.brightnessPct + "%"
            color: "#f9e2af" 
            Layout.alignment: Qt.AlignVCenter
        }

        // Volumen
        Text {
            text: (root.isMuted ? "󰝟 " : "󰕾 ") + root.volume + "%"
            color: root.isMuted ? "#f38ba8" : "#a6e3a1" 
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
