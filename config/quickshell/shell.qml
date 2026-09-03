import QtQuick
import Quickshell
import Quickshell.Io
import "core"
import "modules/Bar"
import "modules/WallpaperSelector"

Scope {
    id: rootShell

    // Instancia del selector de fondos
    WallpaperSelector {
        id: wallpaperWin
    }

    // Handlers IPC globales
    IpcHandler {
        target: "theme"

        function set(name: string) { Theme.setTheme(name) }
        function cycle() { Theme.cycleTheme() }
    }

    IpcHandler {
        target: "wallpaper"

        // Comando: quickshell ipc call wallpaper toggle
        function toggle() {
            wallpaperWin.isOpen = !wallpaperWin.isOpen
        }

        // Comando: quickshell ipc call wallpaper open
        function open() {
            wallpaperWin.isOpen = true
        }
    }

    // Iterador de monitores con enlace estricto de pantalla
    Variants {
        model: Quickshell.screens

        delegate: Component {
            Item {
                id: wrapper
                required property var modelData

                Bar {
                    screen: wrapper.modelData
                }
            }
        }
    }
}
