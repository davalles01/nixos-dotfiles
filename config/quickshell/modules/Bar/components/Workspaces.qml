// modules/Bar/components/Workspaces.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../../core"

Row {
    spacing: 6
    // NOTA: Se eliminó anchors.verticalCenter para no causar conflicto con el RowLayout contenedor

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: wsItem

            readonly property bool isActive: !!(modelData && modelData.active)
            readonly property bool hasWindows: !!(modelData && modelData.windows && modelData.windows.length > 0)

            width: isActive ? 24 : (hasWindows ? 14 : 10)
            height: 10
            radius: 5

            color: isActive 
                   ? Theme.colors.blue 
                   : (hasWindows ? Theme.colors.surface0 : Theme.colors.surface1)

            Behavior on width { NumberAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}
