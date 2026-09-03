import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../core"

Item {
    id: root
    property var wifiSvc
    property var popup
    property var otherPopup

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Component.onCompleted: {
        if (wifiSvc && typeof wifiSvc.updateState === "function") {
            wifiSvc.updateState()
        }
    }

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
            color: (wifiSvc && wifiSvc.powered) 
                   ? (wifiSvc.connected ? Theme.colors.blue : Theme.colors.text) 
                   : Theme.colors.red
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: wifiSvc ? (wifiSvc.powered && wifiSvc.connected && wifiSvc.ssid !== "") : false
            text: wifiSvc ? wifiSvc.ssid : ""
            color: Theme.colors.text
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
