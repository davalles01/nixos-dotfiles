// ThemeLatte.qml
import QtQuick

QtObject {
    id: root

	readonly property string logo: "nixos-black.svg"
	
	readonly property QtObject colors: QtObject {
        readonly property color crust: "#dce0e8"
        readonly property color mantle: "#e6e9ef"
        readonly property color base: "#eff1f5"
        
        readonly property color surface0: "#ccd0da"
        readonly property color surface1: "#bcc0cc"
        readonly property color surface2: "#acb0be"
        readonly property color overlay0: "#9ca0b0"
        
        readonly property color text: "#4c4f69"
        readonly property color subtext0: "#6c6f85"
        readonly property color subtext1: "#5c5f77"
        
        readonly property color blue: "#1e66f5"
        readonly property color red: "#d20f39"
        readonly property color peach: "#fe640b"
        readonly property color yellow: "#df8e1d"
        readonly property color green: "#40a02b"
        readonly property color lavender: "#7287fd"
		readonly property color mauve: "#8839ef"
        readonly property color sapphire: "#209fb5"
        readonly property color sky: "#04a5e5"
    }
}
