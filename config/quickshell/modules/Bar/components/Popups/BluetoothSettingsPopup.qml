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

    property var btSvc
    property var devicesList: []
    property var pairedMacs: ([])

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
        id: checkPairedProc
        command: ["bluetoothctl", "paired-devices"]
        stdout: SplitParser {
            onRead: (data) => {
                let lines = data.trim().split("\n")
                let macs = []
                for (let line of lines) {
                    if (!line) continue
                    let parts = line.split(" ")
                    if (parts.length >= 2) {
                        macs.push(parts[1])
                    }
                }
                root.pairedMacs = macs
                scanBtProc.running = true
            }
        }
    }

    Process {
        id: scanBtProc
        command: ["bluetoothctl", "devices"]
        stdout: SplitParser {
            onRead: (data) => {
                let lines = data.trim().split("\n")
                let parsed = []
                for (let line of lines) {
                    if (!line) continue
                    let parts = line.split(" ")
                    if (parts.length >= 3) {
                        let mac = parts[1]
                        let name = parts.slice(2).join(" ")
                        let isPaired = root.pairedMacs.includes(mac)
                        parsed.push({ 
                            mac: mac, 
                            name: name,
                            paired: isPaired
                        })
                    }
                }
                root.devicesList = parsed
            }
        }
    }

    Timer {
        interval: 5000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: checkPairedProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: contentCard
        width: 320
        height: 420
        focus: true
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 44
        anchors.rightMargin: 12

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
                    text: "Bluetooth"
                    color: Theme.colors.text
                    font.pixelSize: 16
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "󰑐"
                    font.pixelSize: 16
                    color: (scanBtProc.running || checkPairedProc.running) ? Theme.colors.subtext0 : Theme.colors.blue
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: checkPairedProc.running = true
                    }
                }

                Item { Layout.preferredWidth: 8 }

                Text {
                    text: root.btSvc?.powered ? "󰂯" : "󰂲"
                    font.pixelSize: 18
                    color: root.btSvc?.powered ? Theme.colors.blue : Theme.colors.red

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.btSvc) root.btSvc.toggleBt()
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.colors.surface0 }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.devicesList
                spacing: 8

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: 42
                    color: Theme.colors.base
                    radius: 10

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: modelData.paired ? "󰂱" : "󰂯"
                            color: modelData.paired ? Theme.colors.green : Theme.colors.text
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: modelData.name
                                color: Theme.colors.text
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.paired ? "Emparejado" : "No emparejado"
                                color: modelData.paired ? Theme.colors.green : Theme.colors.subtext0
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }
}
