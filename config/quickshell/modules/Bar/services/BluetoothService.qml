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

        // Iniciar la verificación en cadena para evitar condiciones de carrera
        btShowProc.running = false
        btShowProc.running = true
    }

    // Devuelve "1" si está encendido y "0" si está apagado
    Process {
        id: btShowProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 1 || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                if (!svc.isChangingState) {
                    let val = data.trim()
                    svc.powered = (val === "1")
                    
                    if (!svc.powered) {
                        svc.connected = false
                        svc.deviceName = ""
                    } else {
                        // Solo consultamos la conexión si la antena está encendida
                        btConnProc.running = false
                        btConnProc.running = true
                    }
                }
            }
        }
    }

    // Consulta de dispositivo conectado con fallback explícito ("DISCONNECTED")
    Process {
        id: btConnProc
        command: ["bash", "-c", "bluetoothctl info | grep 'Name:' || echo 'DISCONNECTED'"]
        stdout: SplitParser {
            onRead: data => {
                if (!svc.powered) {
                    svc.connected = false
                    svc.deviceName = ""
                    return
                }

                let line = data.trim()
                if (line.length > 0 && line !== "DISCONNECTED") {
                    let parts = line.split("Name:")
                    if (parts.length >= 2) {
                        let name = parts[1].trim()
                        if (name.length > 0) {
                            svc.deviceName = name
                            svc.connected = true
                            return
                        }
                    }
                }

                // Si no hay respuesta de nombre o dice DISCONNECTED, forzamos la desconexión
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
