import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../../../core"

PanelWindow {
    id: root
    visible: false

    // Solicitud explícita de foco de teclado a Wayland cuando el popup está visible
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    // Ocupar toda la pantalla para capturar eventos de teclado y clics fuera
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    function toggle() {
        root.visible = !root.visible
        if (root.visible) {
            panel.forceActiveFocus()
        }
    }

    // 1. CAPA EXTERNA: Detecta clics fuera del panel para cerrarlo
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.visible = false
    }

    // 2. PANEL DEL CALENDARIO
    FocusScope {
        id: panel

        // Posicionado justo debajo de la barra central superior
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 48

        width: 280
        height: 340

        focus: root.visible

        // Captura de la tecla Esc
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

            // Absorbe los clics dentro del panel para que NO lo cierren
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        root.visible = false
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Reloj en grande
                Text {
                    id: bigClock
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                    font.pixelSize: 28
                    font.bold: true
                    color: Theme.colors.peach

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: bigClock.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                    }
                }

                // Fecha completa
                Text {
                    id: fullDate
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(new Date(), "dddd, d 'de' MMMM 'de' yyyy")
                    font.pixelSize: 12
                    color: Theme.colors.subtext0

                    Timer {
                        interval: 60000
                        running: true
                        repeat: true
                        onTriggered: fullDate.text = Qt.formatDateTime(new Date(), "dddd, d 'de' MMMM 'de' yyyy")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.colors.surface0
                }

                // Grid del Calendario
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
                        font.pixelSize: 12
                        font.bold: model.today
                        
                        color: model.today ? Theme.colors.crust : Theme.colors.text

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            color: Theme.colors.peach
                            radius: 6
                            visible: model.today
                            z: -1
                        }
                    }
                }
            }
        }
    }
}
