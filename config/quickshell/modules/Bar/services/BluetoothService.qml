import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: svc

    property bool powered: false
    property bool connected: false
    property string deviceName: ""
    property bool isChangingState: false

    function updateState() {
        if (svc.isChangingState) return;

        // Reiniciar procesos para forzar una lectura limpia
        btShowProc.running = false
        btShowProc.running = true

        btConnProc.running = false
        btConnProc.running = true
    }

    // Devuelve "1" si está encendido y "0" si está apagado
    // Garantiza que onRead SIEMPRE reciba respuesta
    Process {
        id: btShowProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 1 || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                if (!svc.isChangingState) {
                    let val = data.trim()
                    svc.powered = (val === "1")
                    
                    // Si se acaba de apagar, limpiar datos de conexión inmediatamente
                    if (!svc.powered) {
                        svc.connected = false
                        svc.deviceName = ""
                    }
                }
            }
        }
    }

    // Consulta de dispositivo conectado
    Process {
        id: btConnProc
        command: ["bash", "-c", "bluetoothctl info | grep 'Name:'"]
        stdout: SplitParser {
            onRead: data => {
                if (!svc.powered) {
                    svc.connected = false
                    svc.deviceName = ""
                    return
                }

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
        interval: 1500
        repeat: false
        onTriggered: {
            svc.isChangingState = false
            svc.updateState()
        }
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

    // Polling regular cada 2 segundos
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: svc.updateState()
    }
}
