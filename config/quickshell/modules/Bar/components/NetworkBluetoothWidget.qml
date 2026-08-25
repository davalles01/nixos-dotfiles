import QtQuick
import QtQuick.Layouts
import "../../../core"

Rectangle {
    id: root

    property var wifiSvc
    property var btSvc
    
    // Referencias a las instancias de los popups
    property var networkPopup
    property var bluetoothPopup

    implicitWidth: mainRow.implicitWidth + 20
    implicitHeight: 28

    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignVCenter

    color: Theme.colors.surface0
    radius: implicitHeight / 2

    RowLayout {
        id: mainRow
        anchors.centerIn: parent
        spacing: 10

        WifiWidget {
            wifiSvc: root.wifiSvc
            popup: root.networkPopup
            otherPopup: root.bluetoothPopup
            Layout.alignment: Qt.AlignVCenter
        }

        // Separador vertical
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 12
            color: Theme.colors.surface1
            Layout.alignment: Qt.AlignVCenter
        }

        BluetoothWidget {
            btSvc: root.btSvc
            popup: root.bluetoothPopup
            otherPopup: root.networkPopup
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
