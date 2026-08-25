import QtQuick
import QtQuick.Layouts
import Quickshell
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

    BatteryService { id: batSvc }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: batSvc.icon + " " + batSvc.percentage + "%"
            color: {
                if (batSvc.isCharging) return "#a6e3a1"
                if (batSvc.percentage <= 20) return "#f38ba8"
                return "#cdd6f4"
            }
            font.bold: batSvc.percentage <= 20
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 12
            color: "#45475a"
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
