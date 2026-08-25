import QtQuick
import QtQuick.Layouts
import Quickshell
import "components"
import "components/Popups"
import "services"

PanelWindow {
    id: topBar
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 40
    color: "#00000000"

    // Servicios independientes
    WifiService { id: wifiService }
    BluetoothService { id: btService }

    // Popups
    SettingsMenu {
        id: settingsPopup
        wifiSvc: wifiService
        btSvc: btService
    }

    NetworkSettingsPopup {
        id: networkPopup
        wifiSvc: wifiService
    }

    BluetoothSettingsPopup {
        id: bluetoothPopup
        btSvc: btService
    }

    // Lado Izquierdo: Workspaces y MediaWidget
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16

        Workspaces {
            Layout.alignment: Qt.AlignVCenter
        }

        MediaWidget {
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // Centro: Reloj
    ClockWidget {
        anchors.centerIn: parent
    }

    // Lado Derecho: Controles del sistema
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        NetworkBluetoothWidget {
            Layout.alignment: Qt.AlignVCenter
            wifiSvc: wifiService
            btSvc: btService
            networkPopup: networkPopup
            bluetoothPopup: bluetoothPopup
        }
        BrightnessVolumeWidget {
            Layout.alignment: Qt.AlignVCenter
        }
        PowerSettingsWidget {
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
