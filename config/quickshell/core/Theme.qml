// Theme.qml (Singleton principal)
pragma Singleton
import QtQuick
import "./Themes"

QtObject {
    id: root

    // 1. Instancias estáticas de temas fijos
    readonly property QtObject mocha: Mocha {}
    readonly property QtObject nord: Nord {}
    readonly property QtObject tokyo: Tokyo {}
    readonly property QtObject latte: Latte {}

    // 2. Cargador dinámico para CurrentTheme.qml
    property Loader themeLoader: Loader {
        source: Qt.resolvedUrl("./Themes/CurrentTheme.qml")
    }

    // 3. Referencia al tema dinámico cargado
    readonly property QtObject dynamicTheme: themeLoader.item ? themeLoader.item : mocha

    // 4. Tema activo (por defecto el dinámico)
    property QtObject currentTheme: dynamicTheme

    // 5. Propiedades expuestas
    readonly property QtObject colors: currentTheme ? currentTheme.colors : mocha.colors
    readonly property string logo: currentTheme && currentTheme.logo ? currentTheme.logo : "nixos-black.svg"

    // 6. Recarga en caliente del archivo CurrentTheme.qml
    function reloadCurrentTheme() {
        const currentSource = themeLoader.source
        themeLoader.source = ""
        // Forzamos la recarga reactiva de la URL
        Qt.callLater(() => {
            themeLoader.source = currentSource
            currentTheme = themeLoader.item ? themeLoader.item : mocha
        })
    }

    // 7. Funciones de selección de tema
    function setTheme(themeName) {
        switch (themeName.toLowerCase()) {
            case "current":
            case "auto":
                reloadCurrentTheme()
                break
            case "nord": currentTheme = nord; break
            case "tokyo": currentTheme = tokyo; break
            case "latte": currentTheme = latte; break
            default: currentTheme = mocha; break
        }
    }

    function cycleTheme() {
        if (currentTheme === dynamicTheme) currentTheme = mocha
        else if (currentTheme === mocha) currentTheme = nord
        else if (currentTheme === nord) currentTheme = tokyo
        else if (currentTheme === tokyo) currentTheme = latte
        else currentTheme = dynamicTheme
    }
}
