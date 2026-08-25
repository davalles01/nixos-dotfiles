import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    spacing: 6
    Repeater {
        model: Hyprland.workspaces
        Rectangle {
            width: modelData.active ? 24 : 10
            height: 10
            radius: 5
            color: modelData.active ? "#89b4fa" : "#45475a"
            Behavior on width { NumberAnimation { duration: 150 } }
        }
    }
}
