import QtQuick
import Quickshell
import "modules/Bar"
// import "modules/Notifications" <-- Listo para añadir más módulos

Scope {
    id: rootShell

    // Módulo de la barra principal
    Bar {}

    // Módulo de notificaciones
    // NotificationCenter {}
    // OSD {}
}
