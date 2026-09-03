// modules/WallpaperSelector/WallpaperService.qml
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var wallpapers: []
    property string currentWallpaper: ""
    readonly property string wallpaperDir: Quickshell.env("HOME") + "/Wallpapers"
    readonly property string confPath: Quickshell.env("HOME") + "/nixos-dotfiles/config/hypr/hyprpaper.conf"

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

    // Proceso 3: Cambiar fondo instantáneamente en hyprpaper y actualizar hyprpaper.conf
    function setWallpaper(fileName) {
        if (!fileName) return
        root.currentWallpaper = fileName

        var fullPath = root.wallpaperDir + "/" + fileName

        // Comando Bash que recarga hyprpaper inmediatamente en todos los monitores (",/ruta")
        // y reescribe hyprpaper.conf
        var script = `
            hyprctl hyprpaper reload ",${fullPath}"
            
            cat <<EOF > "${root.confPath}"
preload = ${fullPath}
wallpaper = ,${fullPath}
EOF
        `

        applyProc.command = ["bash", "-c", script]
        applyProc.running = true
    }

    property Process applyProc: Process {}

    Component.onCompleted: refresh()
}
