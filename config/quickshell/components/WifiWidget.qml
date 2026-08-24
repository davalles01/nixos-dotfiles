import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: root
    property var wifiSvc
    property var popup
    property var otherPopup

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    function getWifiIcon() {
        if (!wifiSvc || !wifiSvc.powered) return "󰤮"
        if (!wifiSvc.connected) return "󰤟"
        
        let sig = wifiSvc.signalStrength
        if (sig > 75) return "󰤨"
        if (sig > 50) return "󰤥"
        if (sig > 25) return "󰤢"
        return "󰤟"
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 6

        Text {
            text: root.getWifiIcon()
            color: (wifiSvc && wifiSvc.powered) ? (wifiSvc.connected ? "#89b4fa" : "#cdd6f4") : "#f38ba8"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: wifiSvc ? (wifiSvc.powered && wifiSvc.connected && wifiSvc.ssid !== "") : false
            text: wifiSvc ? wifiSvc.ssid : ""
            color: "#cdd6f4"
            font.pixelSize: 12
            font.bold: true
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
