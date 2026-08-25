import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: svc

    property bool powered: false
    property bool connected: false
    property string deviceName: ""
    property bool isChangingState: false

    // Consulta directa por rfkill para saber si el hardware está bloqueado o encendido
    Process {
        id: btStatusProc
        command: ["bash", "-c", "rfkill list bluetooth | grep -i 'soft blocked: yes'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!svc.isChangingState) {
                    // Si grep encuentra 'soft blocked: yes', el bluetooth está apagado
                    svc.powered = (data.trim().length === 0)
                }
            }
        }
    }

    // Consulta el primer dispositivo conectado
    Process {
        id: btDevicesProc
        command: ["bash", "-c", "bluetoothctl info | grep 'Name:'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim()
                if (line.length > 0) {
                    let parts = line.split("Name:")
                    if (parts.length >= 2) {
                        svc.deviceName = parts[1].trim()
                        svc.connected = true
                        return
                    }
                }
                svc.connected = false
                svc.deviceName = ""
            }
        }
    }

    Process { id: toggleProc }

    Timer {
        id: cooldownTimer
        interval: 2000
        repeat: false
        onTriggered: svc.isChangingState = false
    }

    function toggleBt() {
        let targetState = !powered
        
        svc.isChangingState = true
        svc.powered = targetState

        if (!targetState) {
            svc.connected = false
            svc.deviceName = ""
            toggleProc.command = ["bash", "-c", "bluetoothctl power off && rfkill block bluetooth"]
        } else {
            toggleProc.command = ["bash", "-c", "rfkill unblock bluetooth && bluetoothctl power on"]
        }

        toggleProc.running = true
        cooldownTimer.restart()
    }

    // Polling regular cada 3 segundos
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (!svc.isChangingState) {
                if (!btStatusProc.running) btStatusProc.running = true
                if (!btDevicesProc.running && svc.powered) btDevicesProc.running = true
            }
        }
    }
}
