import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string jsonPath: Qt.resolvedUrl("colors.json").toString().replace("file://", "")
    property var themeData: null

    // Proceso para leer el JSON de forma limpia y actualizada bajo demanda
    property Process readJsonProc: Process {
        command: ["cat", root.jsonPath]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    if (text.trim().length > 0) {
                        root.themeData = JSON.parse(text)
                    }
                } catch (e) {
                    console.log("Error parseando colors.json: " + e)
                }
            }
        }
    }

    // Función que invoca WallpaperService.qml al terminar el script
    function reloadCurrentTheme() {
        readJsonProc.running = true
    }

    // Cargar los colores al iniciar
    Component.onCompleted: {
        reloadCurrentTheme()
    }

    readonly property string logo: themeData ? themeData.logo : "nixos.svg"

    readonly property QtObject colors: QtObject {
        readonly property color crust: themeData ? themeData.colors.crust : "#131318"
        readonly property color mantle: themeData ? themeData.colors.mantle : "#131318"
        readonly property color base: themeData ? themeData.colors.base : "#131318"

        readonly property color surface0: themeData ? themeData.colors.surface0 : "#1f1f25"
        readonly property color surface1: themeData ? themeData.colors.surface1 : "#29292f"
        readonly property color surface2: themeData ? themeData.colors.surface2 : "#34343a"
        readonly property color overlay0: themeData ? themeData.colors.overlay0 : "#90909a"

        readonly property color text: themeData ? themeData.colors.text : "#e4e1e9"
        readonly property color subtext0: themeData ? themeData.colors.subtext0 : "#c7c5d0"
        readonly property color subtext1: themeData ? themeData.colors.subtext1 : "#90909a"

        readonly property color blue: themeData ? themeData.colors.blue : "#bbc3ff"
        readonly property color red: themeData ? themeData.colors.red : "#ffb4ab"
        readonly property color peach: themeData ? themeData.colors.peach : "#c4c5dd"
        readonly property color yellow: themeData ? themeData.colors.yellow : "#e6bad7"
        readonly property color green: themeData ? themeData.colors.green : "#bbc3ff"
        readonly property color lavender: themeData ? themeData.colors.lavender : "#c4c5dd"
        readonly property color mauve: themeData ? themeData.colors.mauve : "#e6bad7"
        readonly property color sapphire: themeData ? themeData.colors.sapphire : "#bbc3ff"
        readonly property color sky: themeData ? themeData.colors.sky : "#c4c5dd"
    }
}
