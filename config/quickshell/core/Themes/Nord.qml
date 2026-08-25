// ThemeNord.qml
import QtQuick

QtObject {
    id: root

    readonly property QtObject colors: QtObject {
        readonly property color crust: "#242933"
        readonly property color mantle: "#2e3440"
        readonly property color base: "#3b4252"
        
        readonly property color surface0: "#434c5e"
        readonly property color surface1: "#4c566a"
        readonly property color surface2: "#606f8a"
        readonly property color overlay0: "#7b88a1"
        
        readonly property color text: "#eceff4"
        readonly property color subtext0: "#d8dee9"
        readonly property color subtext1: "#e5e9f0"
        
        readonly property color blue: "#81a1c1"
        readonly property color red: "#bf616a"
        readonly property color peach: "#d08770"
        readonly property color yellow: "#ebcb8b"
        readonly property color green: "#a3be8c"
        readonly property color lavender: "#b48ead"
		readonly property color mauve: "#b48ead"
        readonly property color sapphire: "#88c0d0"
        readonly property color sky: "#8fbcbb"
    }
}
