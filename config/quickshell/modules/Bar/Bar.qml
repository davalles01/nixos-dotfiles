// modules/Bar/Bar.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "components"
import "components/Popups"
import "services"

PanelWindow {
    id: topBar

    property var launcherInstance
    property var notifServer: null
    property var controlCenterInstance: null // Recibido desde shell.qml

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

    // Lado Izquierdo: Workspaces, MediaWidget y LauncherWidget
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

        LauncherWidget {
            Layout.alignment: Qt.AlignVCenter
            launcherInstance: topBar.launcherInstance
            targetScreen: topBar.screen
        }
    }

    // Centro: Reloj
    ClockWidget {
        anchors.centerIn: parent
        controlCenterPopup: topBar.controlCenterInstance // Enlazamos correctamente con la instancia global
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
