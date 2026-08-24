import QtQuick
import Quickshell
import Quickshell.Services.UPower

Scope {
    id: root

    // UPower.displayDevice representa la batería principal o agregada del sistema
    property var device: UPower.displayDevice

    // Porcentaje de 0 a 100
    property int percentage: Math.round((device?.percentage ?? 1) * 100)
    
    // Indica si el portátil está conectado a la corriente / cargando
    property bool isCharging: device?.state === UPowerDeviceState.Charging || device?.state === UPowerDeviceState.FullyCharged

    // Icono dinámico según el porcentaje y el estado de carga
    property string icon: {
        if (isCharging) {
            if (percentage >= 95) return "󰂅"
            if (percentage >= 80) return "󰂋"
            if (percentage >= 60) return "󰂉"
            if (percentage >= 40) return "󰂈"
            if (percentage >= 20) return "󰂆"
            return "󰢜" // Carga crítica
        } else {
            if (percentage >= 95) return "󰁹"
            if (percentage >= 80) return "󰂀"
            if (percentage >= 60) return "󰁾"
            if (percentage >= 40) return "󰁼"
            if (percentage >= 20) return "󰁺"
            return "󰂎" // Batería muy baja
        }
    }
}
