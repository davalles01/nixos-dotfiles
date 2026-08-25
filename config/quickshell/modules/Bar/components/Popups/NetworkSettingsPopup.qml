import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../../../core"

PanelWindow {
    id: root
    visible: false

    property var wifiSvc
    property var networksList: []

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function toggle() {
        root.visible = !root.visible
    }

    Process {
        id: scanWifiProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        stdout: SplitParser {
            onRead: (data) => {
                let lines = data.trim().split("\n")
                let parsed = []
                for (let line of lines) {
                    if (!line) continue
                    let parts = line.split(":")
                    if (parts.length >= 2 && parts[1] !== "") {
                        parsed.push({
                            inUse: parts[0] === "*",
                            ssid: parts[1],
                            signal: parseInt(parts[2]) || 0,
                            security: parts[3] || "Abierta"
                        })
                    }
                }
                root.networksList = parsed
            }
        }
    }

    Timer {
        interval: 4000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: scanWifiProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: contentCard
        width: 320
        height: 440
        focus: true
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 44
        anchors.rightMargin: 50

        color: Theme.colors.crust
        radius: 20
        border.color: Theme.colors.surface0
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
        }

        Keys.onEscapePressed: (event) => {
            root.visible = false
            event.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Redes Wi-Fi"
                    color: Theme.colors.text
                    font.pixelSize: 16
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "󰑐"
                    font.pixelSize: 16
                    color: scanWifiProc.running ? Theme.colors.subtext0 : Theme.colors.blue
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: scanWifiProc.running = true
                    }
                }

                Item { Layout.preferredWidth: 8 }

                Text {
                    text: root.wifiSvc?.powered ? "󰤨" : "󰤮"
                    font.pixelSize: 18
                    color: root.wifiSvc?.powered ? Theme.colors.green : Theme.colors.red

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.wifiSvc) root.wifiSvc.toggleWifi()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 48
                color: Theme.colors.base
                radius: 12
                border.color: root.wifiSvc?.connected ? Theme.colors.blue : Theme.colors.surface0
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        text: root.wifiSvc?.connected ? "󰤨" : "󰤮"
                        font.pixelSize: 18
                        color: root.wifiSvc?.connected ? Theme.colors.blue : Theme.colors.red
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            text: "Conectado a"
                            color: Theme.colors.subtext0
                            font.pixelSize: 10
                        }

                        Text {
                            text: (root.wifiSvc && root.wifiSvc.connected && root.wifiSvc.ssid !== "") 
                                  ? root.wifiSvc.ssid 
                                  : "Sin conexión"
                            color: Theme.colors.text
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.colors.surface0 }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.networksList
                spacing: 8

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: 42
                    color: modelData.inUse ? Theme.colors.surface0 : Theme.colors.base
                    radius: 10

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: modelData.inUse ? "󰤨" : "󰤢"
                            color: modelData.inUse ? Theme.colors.blue : Theme.colors.text
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: modelData.ssid
                                color: Theme.colors.text
                                font.bold: modelData.inUse
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.security
                                color: Theme.colors.subtext0
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            visible: modelData.inUse
                            text: "󰄬"
                            color: Theme.colors.green
                        }
                    }
                }
            }
        }
    }
}
