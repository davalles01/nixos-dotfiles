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

        // Opción 1: Llamada sin parámetros desde terminal (qs ipc call launcher toggle)
        function toggle(): void {
            let activeScreen = Quickshell.screens[0]
            appLauncher.toggleLauncher(activeScreen)
        }

        // Opción 2: Llamada especificando el índice del monitor (qs ipc call launcher toggleOnScreen 0)
        function toggleOnScreen(screenIndex: int): void {
            let activeScreen = Quickshell.screens[screenIndex] || Quickshell.screens[0]
            appLauncher.toggleLauncher(activeScreen)
        }

        // Opción 1: Abrir sin parámetros
        function open(): void {
            let activeScreen = Quickshell.screens[0]
            appLauncher.openLauncher(activeScreen)
        }

        // Opción 2: Abrir en un monitor específico
        function openOnScreen(screenIndex: int): void {
            let activeScreen = Quickshell.screens[screenIndex] || Quickshell.screens[0]
            appLauncher.openLauncher(activeScreen)
        }

        function close(): void {
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
