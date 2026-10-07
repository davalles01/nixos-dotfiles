import QtQuick
import "../../../core"

Rectangle {
    id: launcherWidget

    property var launcherInstance
    property var targetScreen: null

    implicitWidth: 32
    implicitHeight: 32
    radius: height / 2

    color: Theme.colors.base
    border.color: Theme.colors.surface0
    border.width: 1

    Text {
        anchors.centerIn: parent
        text: "󰞷" // Icono de terminal de Nerd Fonts
        color: Theme.colors.peach
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (launcherInstance && typeof launcherInstance.toggleLauncher === "function") {
                launcherInstance.toggleLauncher(launcherWidget.targetScreen)
            }
        }
    }
}
