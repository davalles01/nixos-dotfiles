// ThemeMocha.qml
import QtQuick

QtObject {
    id: root

    readonly property QtObject colors: QtObject {
        readonly property color crust: "#11111b"
        readonly property color mantle: "#181825"
        readonly property color base: "#1e1e2e"
        
        readonly property color surface0: "#313244"
        readonly property color surface1: "#45475a"
        readonly property color surface2: "#585b70"
        readonly property color overlay0: "#6c7086"
        
        readonly property color text: "#cdd6f4"
        readonly property color subtext0: "#a6adc8"
        readonly property color subtext1: "#bac2de"
        
        readonly property color blue: "#89b4fa"
        readonly property color red: "#f38ba8"
        readonly property color peach: "#fab387"
        readonly property color yellow: "#f9e2af"
        readonly property color green: "#a6e3a1"
        readonly property color lavender: "#b4befe"
		readonly property color mauve: "#cba6f7"
        readonly property color sapphire: "#7dc4e4"
        readonly property color sky: "#91d7e3"
    }
}
