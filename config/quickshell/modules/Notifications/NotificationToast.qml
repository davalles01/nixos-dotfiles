import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../../core"

PanelWindow {
    id: toastWindow
    property var notifServer: null

    visible: toastModel.count > 0

    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    implicitWidth: 360
    implicitHeight: toastColumn.implicitHeight + 20
    color: "transparent"

    ListModel {
        id: toastModel
    }

    Connections {
        target: notifServer

        function onNotification(notif) {
            notif.tracked = true
            // Extraemos los datos como tipos primitivos (strings) para que ListModel los preserve
            toastModel.append({
                "appName": notif.appName || "Sistema",
                "summary": notif.summary || "",
                "body": notif.body || ""
            })
        }
    }

    ColumnLayout {
        id: toastColumn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12
        width: 340
        spacing: 8

        Repeater {
            model: toastModel

            delegate: Rectangle {
                id: toastCard
                required property int index
                required property string appName
                required property string summary
                required property string body

                Layout.fillWidth: true
                implicitHeight: cardLayout.implicitHeight + 16
                radius: 12
                color: Theme.colors.crust
                border.color: Theme.colors.surface1
                border.width: 1

                Timer {
                    interval: 5000
                    running: true
                    repeat: false
                    onTriggered: toastModel.remove(toastCard.index)
                }

                ColumnLayout {
                    id: cardLayout
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: toastCard.appName
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
                                onClicked: toastModel.remove(toastCard.index)
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: toastCard.summary
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.colors.text
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: toastCard.body
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
