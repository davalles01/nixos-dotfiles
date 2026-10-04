import QtQuick
import Quickshell
import Quickshell.Io
import "core"
import "modules/Bar"
import "modules/WallpaperSelector"
import "modules/launcher"
import "modules/VolumeOSD"

// Submódulos del componente overview con alias en Mayúscula para evitar el error de QML
import "./modules/overview/modules/overview" as OverviewModule
import "./modules/overview/services"
import "./modules/overview/common"
import "./modules/overview/common/widgets"

Scope {
    id: rootShell

	VolumeOSD {         
        id: volumeOSD
    }

    // Instancia del selector de fondos
    WallpaperSelector {
        id: wallpaperWin
    }

    // Instancia del Launcher
    Launcher {
        id: appLauncher
        wallpaperWindow: wallpaperWin
    }

    // Instancia del componente Overview usando el alias
    OverviewModule.Overview {
        id: overviewWin
    }

    // Handlers IPC globales
    IpcHandler {
        target: "theme"

        function set(name: string) { Theme.setTheme(name) }
        function cycle() { Theme.cycleTheme() }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            let activeScreen = Quickshell.screens[0]
            appLauncher.toggleLauncher(activeScreen)
        }

        function toggleOnScreen(screenIndex: int): void {
            let activeScreen = Quickshell.screens[screenIndex] || Quickshell.screens[0]
            appLauncher.toggleLauncher(activeScreen)
        }

        function open(): void {
            let activeScreen = Quickshell.screens[0]
            appLauncher.openLauncher(activeScreen)
        }

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

    // Iterador de monitores
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
