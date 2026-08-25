import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    property int brightness: 100
    property int maxBrightness: 100

    Process {
        id: getBrightnessProc
        command: ["brightnessctl", "g"]
        stdout: SplitParser {
            onRead: data => {
                let val = parseInt(data.trim())
                if (!isNaN(val)) root.brightness = val
            }
        }
    }

    Process {
        id: getMaxBrightnessProc
        command: ["brightnessctl", "m"]
        stdout: SplitParser {
            onRead: data => {
                let val = parseInt(data.trim())
                if (!isNaN(val)) root.maxBrightness = val
            }
        }
    }

    // Escuchador de eventos del kernel de Linux para brillo
    Process {
        id: brightnessMonitor
        command: ["udevadm", "monitor", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("backlight")) {
                    getBrightnessProc.running = true
                }
            }
        }
    }

    // Lectura inicial al cargar
    Component.onCompleted: {
        getBrightnessProc.running = true
        getMaxBrightnessProc.running = true
    }
}
