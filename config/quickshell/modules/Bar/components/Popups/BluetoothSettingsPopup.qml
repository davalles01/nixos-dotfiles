import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

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

    // Obtener lista de dispositivos emparejados
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

    // Obtener todos los dispositivos
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

        color: "#11111b"
        radius: 20
        border.color: "#313244"
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
        }

		// Captura la tecla Escape
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
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "󰑐"
                    font.pixelSize: 16
                    color: (scanBtProc.running || checkPairedProc.running) ? "#a6adc8" : "#89b4fa"
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
                    color: root.btSvc?.powered ? "#89b4fa" : "#f38ba8"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.btSvc) root.btSvc.toggleBt()
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

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
                    color: "#1e1e2e"
                    radius: 10

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: modelData.paired ? "󰂱" : "󰂯"
                            color: modelData.paired ? "#a6e3a1" : "#cdd6f4"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: modelData.name
                                color: "#cdd6f4"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.paired ? "Emparejado" : "No emparejado"
                                color: modelData.paired ? "#a6e3a1" : "#a6adc8"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }
}
