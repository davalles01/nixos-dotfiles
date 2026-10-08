import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "core"
import "modules/Bar"
import "modules/Bar/components/Popups"
import "modules/WallpaperSelector"
import "modules/launcher"
import "modules/VolumeOSD"
import "modules/BrightnessOSD"
import "modules/Notifications"

import "./modules/overview/modules/overview" as OverviewModule
import "./modules/overview/services"
import "./modules/overview/common"
import "./modules/overview/common/widgets"

Scope {
    id: rootShell

    property var activeNotifications: []

	// Función global para remover notificaciones manteniendo la reactividad
	function removeNotification(notif) {
		if (notif && typeof notif.dismiss === "function") {
			notif.dismiss();
		}
		// Reasignamos creando un nuevo array filtrado para notificar los cambios a QML
		activeNotifications = activeNotifications.filter(item => item !== notif);
	}

	function clearAllNotifications() {
		for (let i = 0; i < activeNotifications.length; i++) {
			if (activeNotifications[i] && typeof activeNotifications[i].dismiss === "function") {
				activeNotifications[i].dismiss();
			}
		}
		activeNotifications = [];
	}

	NotificationServer {
		id: notifServer
		
		onNotification: (notif) => {
			console.log("[Quickshell] Notificación recibida:", notif.summary);
			notif.tracked = true;
			// Reasignamos el array añadiendo el nuevo elemento al principio
			activeNotifications = [notif, ...activeNotifications];
		}
	}

	ControlCenterPopup {
		id: controlCenter
		notifServer: activeNotifications
		// Pasamos las funciones de callback para borrar
		onClearAllRequested: clearAllNotifications()
		onRemoveRequested: (notif) => removeNotification(notif)
	}

    NotificationToast {
        id: notificationToast
        notifServer: notifServer
    }

    VolumeOSD {          
        id: volumeOSD
    }
    
    BrightnessOSD {          
        id: brightnessOSD
    }

    WallpaperSelector {
        id: wallpaperWin
    }

    Launcher {
        id: appLauncher
        wallpaperWindow: wallpaperWin
    }

    OverviewModule.Overview {
        id: overviewWin
    }

    // IPC para abrir/cerrar el Control Center
    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            controlCenter.toggle()
        }

        function open(): void {
            controlCenter.visible = true
            controlCenter.forceActiveFocus()
        }

        function close(): void {
            controlCenter.visible = false
        }
    }

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

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Item {
                id: wrapper
                required property var modelData

                Bar {
                    screen: wrapper.modelData
                    launcherInstance: appLauncher
                    notifServer: notifServer
                    controlCenterInstance: controlCenter // Pasamos la referencia global hacia la barra
                }
            }
        }
    }
}
