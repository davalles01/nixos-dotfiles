// ThemeTokyoNight.qml
import QtQuick

QtObject {
    id: root

    readonly property QtObject colors: QtObject {
        readonly property color crust: "#16161e"
        readonly property color mantle: "#1a1b26"
        readonly property color base: "#24283b"
        
        readonly property color surface0: "#292e42"
        readonly property color surface1: "#3b4261"
        readonly property color surface2: "#545c7e"
        readonly property color overlay0: "#737aa2"
        
        readonly property color text: "#c0caf5"
        readonly property color subtext0: "#9aa5ce"
        readonly property color subtext1: "#a9b1d6"
        
        readonly property color blue: "#7aa2f7"
        readonly property color red: "#f7768e"
        readonly property color peach: "#ff9e64"
        readonly property color yellow: "#e0af68"
        readonly property color green: "#9ece6a"
        readonly property color lavender: "#bb9af7"
		readonly property color mauve: "#9d7cd8"
        readonly property color sapphire: "#2ac3de"
        readonly property color sky: "#7dcfff"
    }
}
