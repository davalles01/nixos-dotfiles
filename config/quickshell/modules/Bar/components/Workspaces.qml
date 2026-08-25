import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../../core"

Row {
    spacing: 6
    Repeater {
        model: Hyprland.workspaces
        Rectangle {
            width: modelData.active ? 24 : 10
            height: 10
            radius: 5
            color: modelData.active ? Theme.colors.blue : Theme.colors.surface1
            Behavior on width { NumberAnimation { duration: 150 } }
        }
    }
}
