import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../../core"

Row {
    spacing: 6
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: wsItem

            // Propiedades de estado
            readonly property bool isActive: modelData.active
            readonly property bool hasWindows: modelData.windows && modelData.windows.length > 0

            // Ancho: 24 si está activo, 14 si tiene ventanas (ocupado), 10 si está vacío
            width: isActive ? 24 : (hasWindows ? 14 : 10)
            height: 10
            radius: 5
            anchors.verticalCenter: parent.verticalCenter

            // Fondo: Color primario relleno si está activo, surface0/subtext si está ocupado, surface1 si está vacío
            color: isActive 
                   ? Theme.colors.blue 
                   : (hasWindows ? Theme.colors.surface0 : Theme.colors.surface1)

            Behavior on width { NumberAnimation { duration: 150 } }

            // Cambiar de workspace al hacer clic
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}
