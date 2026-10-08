import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../../../core"

PanelWindow {
    id: root
    visible: false

    // Recibe el array de notificaciones desde shell.qml
    property var notifServer: []

    // Señales para notificar acciones a shell.qml sin romper los bindings
    signal clearAllRequested()
    signal removeRequested(var notif)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    readonly property var notifList: root.notifServer ? root.notifServer : []

    function toggle() {
        root.visible = !root.visible
        if (root.visible) {
            panel.forceActiveFocus()
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.visible = false
    }

    FocusScope {
        id: panel

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 52

        implicitWidth: 640
        implicitHeight: 380

        focus: root.visible

        Keys.onEscapePressed: (event) => {
            root.visible = false
            event.accepted = true
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.colors.crust
            radius: 16
            border.color: Theme.colors.surface1
            border.width: 1

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        root.visible = false
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 18

                // Columna Izquierda (Reloj y Calendario)
                ColumnLayout {
                    Layout.preferredWidth: 280
                    Layout.fillHeight: true
                    spacing: 8

                    Text {
                        id: bigClock
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                        font.pixelSize: 26
                        font.bold: true
                        color: Theme.colors.peach

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: bigClock.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                        }
                    }

                    Text {
                        id: fullDate
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDateTime(new Date(), "dddd, d 'de' MMMM")
                        font.pixelSize: 12
                        color: Theme.colors.subtext0

                        Timer {
                            interval: 60000
                            running: true
                            repeat: true
                            onTriggered: fullDate.text = Qt.formatDateTime(new Date(), "dddd, d 'de' MMMM")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.colors.surface0
                    }

                    MonthGrid {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        month: new Date().getMonth()
                        year: new Date().getFullYear()

                        delegate: Text {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: model.month === parent.month ? 1.0 : 0.3
                            text: model.day
                            font.pixelSize: 11
                            font.bold: model.today
                            color: model.today ? Theme.colors.crust : Theme.colors.text

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                color: Theme.colors.peach
                                radius: 6
                                visible: model.today
                                z: -1
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    implicitWidth: 1
                    color: Theme.colors.surface0
                }

                // Columna Derecha (Notificaciones)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Notificaciones"
                            font.pixelSize: 14
                            font.bold: true
                            color: Theme.colors.text
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            visible: root.notifList.length > 0
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: 13
                            color: clearArea.containsMouse ? Theme.colors.surface1 : Theme.colors.surface0

                            Text {
                                anchors.centerIn: parent
                                text: "󰎟"
                                font.pixelSize: 12
                                color: Theme.colors.red
                            }

                            MouseArea {
                                id: clearArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.clearAllRequested()
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.notifList.length === 0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰂜"
                                font.pixelSize: 48
                                color: Theme.colors.overlay0
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No tienes notificaciones"
                                font.pixelSize: 13
                                color: Theme.colors.subtext0
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.notifList.length > 0
                        clip: true
                        contentWidth: width
                        contentHeight: notifColumn.implicitHeight

                        ColumnLayout {
                            id: notifColumn
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: root.notifList

                                delegate: Rectangle {
                                    id: notifCard
                                    required property var modelData

                                    Layout.fillWidth: true
                                    implicitHeight: cardContent.implicitHeight + 16
                                    radius: 10
                                    color: Theme.colors.surface0
                                    border.color: Theme.colors.surface1
                                    border.width: 1

                                    ColumnLayout {
                                        id: cardContent
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 4

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: (notifCard.modelData && notifCard.modelData.appName) || "Sistema"
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: Theme.colors.peach
                                                elide: Text.ElideRight
                                            }

                                            Item { Layout.fillWidth: true }

                                            Text {
                                                text: "󰅖"
                                                font.pixelSize: 12
                                                color: Theme.colors.subtext0

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: root.removeRequested(notifCard.modelData)
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: (notifCard.modelData && notifCard.modelData.summary) || ""
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: Theme.colors.text
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: (notifCard.modelData && notifCard.modelData.body) || ""
                                            font.pixelSize: 11
                                            color: Theme.colors.subtext0
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                            visible: text.length > 0
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} 
