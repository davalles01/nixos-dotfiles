import QtQuick
import Quickshell
import Quickshell.Io
import "core"
import "modules/Bar"
import "modules/WallpaperSelector"
import "modules/launcher"

Scope {
    id: rootShell

    // Instancia del selector de fondos
    WallpaperSelector {
        id: wallpaperWin
    }

    // Instancia del Launcher
    Launcher {
        id: appLauncher
        wallpaperWindow: wallpaperWin
    }

    // Handlers IPC globales
    IpcHandler {
        target: "theme"

        function set(name: string) { Theme.setTheme(name) }
        function cycle() { Theme.cycleTheme() }
    }

    IpcHandler {
        target: "launcher"

        // Permite recibir el índice o nombre de pantalla desde el IPC
        function toggle(screenIndex) {
            let activeScreen = null
            if (screenIndex !== undefined && Quickshell.screens[screenIndex]) {
                activeScreen = Quickshell.screens[screenIndex]
            } else {
                activeScreen = Quickshell.screens[0]
            }
            appLauncher.toggleLauncher(activeScreen)
        }

        function open(screenIndex) {
            let activeScreen = null
            if (screenIndex !== undefined && Quickshell.screens[screenIndex]) {
                activeScreen = Quickshell.screens[screenIndex]
            } else {
                activeScreen = Quickshell.screens[0]
            }
            appLauncher.openLauncher(activeScreen)
        }

        function close() {
            appLauncher.closeLauncher()
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle() {
            wallpaperWin.isOpen = !wallpaperWin.isOpen
        }

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
                    launcherInstance: appLauncher
                }
            }
        }
    }
}
