import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: svc

    property bool powered: false
    property bool connected: false
    property string ssid: ""
    property int signalStrength: 0

    // Comprobar si la radio Wi-Fi está encendida
    Process {
        id: checkPowerProc
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                svc.powered = (data.trim() === "enabled")
            }
        }
    }

    // Obtener SSID activo y señal (usa ~ como separador para evitar conflictos con nombres de red)
    Process {
        id: activeWifiProc
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes:'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim()
                if (line.length > 0) {
                    let parts = line.split(":")
                    if (parts.length >= 3) {
                        svc.connected = true
                        svc.ssid = parts[1]
                        svc.signalStrength = parseInt(parts[2]) || 0
                        return
                    }
                }
                svc.connected = false
                svc.ssid = ""
                svc.signalStrength = 0
            }
        }
    }

    // Proceso para encender/apagar
    Process { id: toggleProc }

    function toggleWifi() {
        let newState = powered ? "off" : "on"
        svc.powered = !svc.powered // Actualización inmediata (optimista)
        if (!svc.powered) {
            svc.connected = false
            svc.ssid = ""
        }
        toggleProc.command = ["nmcli", "radio", "wifi", newState]
        toggleProc.running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!checkPowerProc.running) checkPowerProc.running = true
            if (!activeWifiProc.running && svc.powered) activeWifiProc.running = true
        }
    }
}
