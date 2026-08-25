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

        Text {
            visible: DndService.dndActive
            text: "󰂛"
            color: Theme.colors.red
            Layout.alignment: Qt.AlignVCenter
        }

        Text { 
            text: root.moonIcon + " " + root.brightnessPct + "%"
            color: Theme.colors.yellow 
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: (root.isMuted ? "󰝟 " : "󰕾 ") + root.volume + "%"
            color: root.isMuted ? Theme.colors.red : Theme.colors.green 
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
