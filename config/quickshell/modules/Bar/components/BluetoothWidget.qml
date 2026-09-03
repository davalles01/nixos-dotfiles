import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../core"

Item {
    id: root
    property var btSvc
    property var popup 
    property var otherPopup

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Component.onCompleted: {
        if (btSvc && typeof btSvc.updateState === "function") {
            btSvc.updateState()
        }
    }

    function getBtIcon() {
        if (!btSvc || !btSvc.powered) return "󰂲"
        if (btSvc.connected) return "󰂱"
        return "󰂯"
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 5

        Text {
            text: root.getBtIcon()
            color: {
                if (!btSvc || !btSvc.powered) return Theme.colors.red
                if (btSvc.connected) return Theme.colors.green
                return Theme.colors.blue
            }
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: btSvc ? (btSvc.powered && btSvc.connected) : false
            text: btSvc ? btSvc.deviceName : ""
            color: Theme.colors.text
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (otherPopup && typeof otherPopup.visible !== "undefined") {
                otherPopup.visible = false
            }
            if (popup) {
                popup.toggle()
            }
        }
    }
}
