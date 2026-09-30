import QtQuick

QtObject {
    id: root

    readonly property string logo: "nixos.svg"

    readonly property QtObject colors: QtObject {
        readonly property color crust: "#131318"
        readonly property color mantle: "#131318"
        readonly property color base: "#131318"

        readonly property color surface0: "#1f1f25"
        readonly property color surface1: "#29292f"
        readonly property color surface2: "#34343a"
        readonly property color overlay0: "#90909a"

        readonly property color text: "#e4e1e9"
        readonly property color subtext0: "#c7c5d0"
        readonly property color subtext1: "#90909a"

        readonly property color blue: "#bbc3ff"
        readonly property color red: "#ffb4ab"
        readonly property color peach: "#c4c5dd"
        readonly property color yellow: "#e6bad7"
        readonly property color green: "#bbc3ff"
        readonly property color lavender: "#c4c5dd"
        readonly property color mauve: "#e6bad7"
        readonly property color sapphire: "#bbc3ff"
        readonly property color sky: "#c4c5dd"
    }
}
