import QtQuick
import Quickshell
import Quickshell.Io
import "core"
import "modules/Bar"
// import "modules/Notifications" <-- Listo para añadir más módulos

Scope {
    id: rootShell

    // Handler IPC para cambiar el tema desde la consola
    IpcHandler {
        target: "theme"

        // Comando: quickshell ipc call theme set <nombre>
        function set(name: string) {
            Theme.setTheme(name)
        }

        // Comando: quickshell ipc call theme cycle
        function cycle() {
            Theme.cycleTheme()
        }
    }

    // Módulo de la barra principal
    Bar {}

    // Módulo de notificaciones
    // NotificationCenter {}
    // OSD {}
}
