import QtQuick
import QtQuick.Layouts
import Quickshell
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

    BatteryService { id: batSvc }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: batSvc.icon + " " + batSvc.percentage + "%"
            color: {
                if (batSvc.isCharging) return Theme.colors.green
                if (batSvc.percentage <= 20) return Theme.colors.red
                return Theme.colors.text
            }
            font.bold: batSvc.percentage <= 20
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 12
            color: Theme.colors.surface1
            Layout.alignment: Qt.AlignVCenter
        }

        Image {
            source: Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/nixos-dotfiles/config/icons/nixos.svg")
            sourceSize.width: 16
            sourceSize.height: 16
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (typeof settingsPopup !== "undefined") {
                settingsPopup.toggle()
            }
        }
    }
}
