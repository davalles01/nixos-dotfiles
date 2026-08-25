import QtQuick
import Quickshell

Rectangle {
    id: clockWidget
    
    // Dimensiones automáticas según el texto + padding
    implicitWidth: clockText.implicitWidth + 24
    implicitHeight: clockText.implicitHeight + 12

    // Radios al 50% de la altura para crear los extremos semicirculares
    radius: height / 2

    // Estilo del contenedor
    color: "#1e1e2e"                 // Fondo oscuro
    border.color: "#313244"          // Borde sutil
    border.width: 1

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "dd MMM - hh:mm")
        color: "#cdd6f4"
        font.bold: true
        font.pixelSize: 13

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "dd MMM - hh:mm")
        }
    }
}
