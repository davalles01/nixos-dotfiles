import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../services"
import "../../../core"

Rectangle {
    id: root

    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: 28

    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignVCenter

    color: Theme.colors.surface0
    radius: implicitHeight / 2

    property int volume: 0
    property bool isMuted: false

    // Propiedades para el estado del micrófono
    property bool micInUse: false
    property bool micIsMuted: false

    BrightnessService { id: brightSvc }

    property int brightnessPct: brightSvc.maxBrightness > 0 ? Math.round((brightSvc.brightness / brightSvc.maxBrightness) * 100) : 0

    property string moonIcon: {
        if (brightnessPct > 80) return "󰽢"
        if (brightnessPct > 60) return "󰽦"
        if (brightnessPct > 40) return "󰽣"
        if (brightnessPct > 20) return "󰽥"
        return "󰽤"
    }

    // Consulta de Volumen de Salida (Altavoces/Auriculares)
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

    // Consulta de Estado del Micrófono (Uso y Mute)
    Process {
        id: micProc
        command: ["sh", "-c", "
            MIC_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
            MUTED=0
            if echo \"$MIC_INFO\" | grep -q \"\[MUTED\]\"; then MUTED=1; fi
            
            IN_USE=0
            if pw-dump 2>/dev/null | grep -q '\"media.class\": \"Stream/Input/Audio\"'; then IN_USE=1; fi
            
            echo \"$IN_USE $MUTED\"
        "]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(" ")
                if (parts.length >= 2) {
                    root.micInUse = (parts[0] === "1")
                    root.micIsMuted = (parts[1] === "1")
                }
            }
        }
    }

    // Suscriptor de cambios en PipeWire para actualizar volumen y micro en tiempo real
    Process {
        id: volSubscriber
        command: ["pw-mon"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("changed") || data.includes("node") || data.includes("link")) {
                    volProc.running = true
                    micProc.running = true
                }
            }
        }
    }

    Component.onCompleted: {
        volProc.running = true
        micProc.running = true
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 12

        // Icono de No Molestar
        Text {
            visible: DndService.dndActive
            text: "󰂛"
            color: Theme.colors.red
            Layout.alignment: Qt.AlignVCenter
        }

        // Icono del Micrófono (Solo visible cuando está en uso)
        Text {
            visible: root.micInUse
            text: root.micIsMuted ? "󰍭" : "󰍬"
            color: root.micIsMuted ? Theme.colors.red : Theme.colors.peach ?? Theme.colors.maroon
            Layout.alignment: Qt.AlignVCenter
        }

        // Brillo
        Text { 
            text: root.moonIcon + " " + root.brightnessPct + "%"
            color: Theme.colors.yellow 
            Layout.alignment: Qt.AlignVCenter
        }

        // Volumen de salida
        Text {
            text: (root.isMuted ? "󰝟 " : "󰕾 ") + root.volume + "%"
            color: root.isMuted ? Theme.colors.red : Theme.colors.green 
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
