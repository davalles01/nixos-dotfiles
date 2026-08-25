import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: root
    property var btSvc
    property var popup 
    property var otherPopup

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

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
                if (!btSvc || !btSvc.powered) return "#f38ba8"
                if (btSvc.connected) return "#a6e3a1"
                return "#89b4fa"
            }
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: btSvc ? (btSvc.powered && btSvc.connected) : false
            text: btSvc ? btSvc.deviceName : ""
            color: "#cdd6f4"
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
