// Theme.qml (Singleton principal)
pragma Singleton
import QtQuick
import "./Themes"

QtObject {
    id: root

    // 1. Instanciar los temas
    readonly property QtObject mocha: Mocha {}
    readonly property QtObject nord: Nord {}
    readonly property QtObject tokyo: Tokyo {}
    readonly property QtObject latte: Latte {}

    // 2. Variable con el tema activo
    property QtObject currentTheme: mocha

    // 3. Exponer 'colors' dinámicamente mediante binding
    readonly property QtObject colors: currentTheme ? currentTheme.colors : mocha.colors

    // 4. Funciones de cambio de tema
    function setTheme(themeName) {
        switch (themeName.toLowerCase()) {
            case "nord": currentTheme = nord; break;
            case "tokyo": currentTheme = tokyo; break;
            case "latte": currentTheme = latte; break;
            default: currentTheme = mocha; break;
        }
    }

    function cycleTheme() {
        if (currentTheme === mocha) currentTheme = nord
        else if (currentTheme === nord) currentTheme = tokyo
        else if (currentTheme === tokyo) currentTheme = latte
        else currentTheme = mocha
    }
}
