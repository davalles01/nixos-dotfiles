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

    // Propiedades explícitas para garantizar la reactividad en la UI
    readonly property bool isPowered: btSvc ? btSvc.powered : false
    readonly property bool isConnected: btSvc ? btSvc.connected : false
    readonly property string deviceName: btSvc ? (btSvc.deviceName || "") : ""

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Component.onCompleted: {
        if (btSvc && typeof btSvc.updateState === "function") {
            btSvc.updateState()
        }
    }

    // Escuchar actualizaciones directas del servicio Bluetooth
    Connections {
        target: root.btSvc
        ignoreUnknownSignals: true
        
        // Se ejecuta si tu servicio emite señales estándar o al cambiar propiedades
        function onPoweredChanged() { if (root.btSvc && typeof root.btSvc.updateState === "function") root.btSvc.updateState() }
        function onConnectedChanged() { if (root.btSvc && typeof root.btSvc.updateState === "function") root.btSvc.updateState() }
        function onDeviceNameChanged() { if (root.btSvc && typeof root.btSvc.updateState === "function") root.btSvc.updateState() }
    }

    function getBtIcon() {
        if (!root.isPowered) return "󰂲"
        if (root.isConnected) return "󰂱"
        return "󰂯"
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 5

        Text {
            text: root.getBtIcon()
            color: {
                if (!root.isPowered) return Theme.colors.red
                if (root.isConnected) return Theme.colors.green
                return Theme.colors.blue
            }
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.isPowered && root.isConnected
            text: root.deviceName
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
