// modules/WallpaperSelector/WallpaperService.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../../core"

QtObject {
    id: root

    property var wallpapers: []
    property string currentWallpaper: ""
    readonly property string wallpaperDir: Quickshell.env("HOME") + "/Wallpapers"
    readonly property string confPath: Quickshell.env("HOME") + "/nixos-dotfiles/config/hypr/hyprpaper.conf"
    readonly property string themeScriptPath: Quickshell.env("HOME") + "/nixos-dotfiles/config/quickshell/scripts/update-theme.sh"

    // Proceso 1: Listar imágenes del directorio
    property Process listProc: Process {
        command: ["bash", "-c", "ls -1 " + root.wallpaperDir + " | grep -E '\\.(png|jpg|jpeg|webp)$'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n").filter(e => e.length > 0)
                root.wallpapers = lines
            }
        }
    }

    // Proceso 2: Leer el fondo actual desde hyprpaper.conf
    property Process readConfProc: Process {
        command: ["bash", "-c", "grep -E '^wallpaper' " + root.confPath + " | cut -d',' -f2 | xargs basename 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var current = text.trim()
                if (current.length > 0) root.currentWallpaper = current
            }
        }
    }

    function refresh() {
        listProc.running = true
        readConfProc.running = true
    }

    // Proceso 3: Cambiar fondo en hyprpaper, actualizar hyprpaper.conf y ejecutar update-theme.sh
    function setWallpaper(fileName) {
        if (!fileName) return
        root.currentWallpaper = fileName

        var fullPath = root.wallpaperDir + "/" + fileName

        // 1. Recarga hyprpaper inmediatamente en todos los monitores
        // 2. Reescribe hyprpaper.conf
        // 3. Ejecuta el script de actualización de colores para Quickshell
        var script = `
            hyprctl hyprpaper reload ",${fullPath}"
            
            cat <<EOF > "${root.confPath}"
preload = ${fullPath}
wallpaper = ,${fullPath}
EOF

            if [ -x "${root.themeScriptPath}" ]; then
                "${root.themeScriptPath}" "${fullPath}"
            fi
        `

        applyProc.command = ["bash", "-c", script]
        applyProc.running = true
    }

    // Al finalizar la ejecución del script en bash, notifica al Singleton Theme para recargar el archivo en caliente
    property Process applyProc: Process {
        onExited: {
            Theme.reloadCurrentTheme()
        }
    }

    Component.onCompleted: refresh()
}
