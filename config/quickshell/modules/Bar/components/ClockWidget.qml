import QtQuick
import Quickshell
import "../../../core"

Rectangle {
    id: clockWidget
    
    property var launcherInstance
    property var targetScreen: null

    implicitWidth: clockText.implicitWidth + 24
    implicitHeight: clockText.implicitHeight + 12

    radius: height / 2

    color: Theme.colors.base
    border.color: Theme.colors.surface0
    border.width: 1

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "dd MMM - hh:mm")
        color: Theme.colors.text
        font.bold: true
        font.pixelSize: 13

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "dd MMM - hh:mm")
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (launcherInstance && typeof launcherInstance.toggleLauncher === "function") {
                // Pasamos la pantalla explícita vinculada a este widget/barra
                launcherInstance.toggleLauncher(clockWidget.targetScreen)
            }
        }
    }
}
