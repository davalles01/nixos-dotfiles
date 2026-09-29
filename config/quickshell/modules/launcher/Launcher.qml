import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../../core"

PanelWindow {
    id: root

    property bool shouldShow: false
    property string query: ""
    property int selectedIndex: 0

    // Configuración para flotar sobre las demás ventanas
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    // Desactiva el tiling
    exclusionMode: ExclusionMode.Ignore

    // Fondo transparente
    color: "transparent"

    // IMPORTANTE: Ocupar toda la pantalla para capturar clics fuera del panel
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: shouldShow || panel.opacity > 0

    // Referencia al selector de fondos
    property var wallpaperWindow: null

    readonly property color cSurface: Theme.colors.base
    readonly property color cSurfaceContainer: Theme.colors.surface0
    readonly property color cSurfaceContainerHigh: Theme.colors.surface1
    readonly property color cPrimary: Theme.colors.blue
    readonly property color cText: Theme.colors.text
    readonly property color cSubText: Theme.colors.subtext0 ?? Theme.colors.overlay0
    readonly property color cBorder: Theme.colors.surface1

    readonly property var terminalCommand: ["kitty"]

    readonly property var actionEntries: [
        {
            id: "action-terminal",
            name: "Open Terminal",
            comment: "Launch your configured terminal",
            glyph: "󰆍",
            type: "action",
            onTriggered: () => Quickshell.execDetached(terminalCommand)
        },
        {
            id: "action-wallpaper",
            name: "Wallpaper Selector",
            comment: "Change your desktop background",
            glyph: "󰸉",
            type: "action",
            onTriggered: () => {
                if (wallpaperWindow) wallpaperWindow.isOpen = true
            }
        },
        {
            id: "action-files",
            name: "Open Files",
            comment: "Open your home directory",
            glyph: "󰉋",
            type: "action",
            onTriggered: () => Quickshell.execDetached(["xdg-open", Quickshell.env("HOME")])
        },
        {
            id: "action-network",
            name: "Network Settings",
            comment: "Open nmtui in terminal",
            glyph: "󰖩",
            type: "action",
            onTriggered: () => Quickshell.execDetached(["kitty", "--class", "nmtui-popup", "nmtui"])
        }
    ]

    readonly property var favoriteApps: {
        const apps = DesktopEntries.applications.values ?? []
        return ["firefox", "org.gnome.Terminal", "code", "thunar"]
            .map(favoriteId => apps.find(entry => entry.id === favoriteId || entry.name.toLowerCase().includes(favoriteId)))
            .filter(entry => !!entry)
    }

    readonly property var appEntries: {
        const apps = DesktopEntries.applications.values ?? []
        const q = query.trim().toLowerCase()
        const favoriteIds = (favoriteApps ?? []).map(entry => entry.id)

        function score(entry) {
            const name = (entry.name ?? "").toLowerCase()
            const genericName = (entry.genericName ?? "").toLowerCase()
            const comment = (entry.comment ?? "").toLowerCase()
            const execString = (entry.execString ?? "").toLowerCase()
            const id = (entry.id ?? "").toLowerCase()
            let rank = 0

            if (!q.length)
                rank = favoriteIds.includes(entry.id) ? 200 : 100
            else if (name === q)
                rank = 1000
            else if (name.startsWith(q))
                rank = 900
            else if (genericName.startsWith(q) || id.startsWith(q))
                rank = 760
            else if (name.includes(q))
                rank = 680
            else if (genericName.includes(q) || comment.includes(q))
                rank = 520
            else if (execString.includes(q))
                rank = 420

            if (favoriteIds.includes(entry.id))
                rank += 90

            return rank
        }

        const filtered = apps
            .map(entry => ({ entry, rank: score(entry) }))
            .filter(item => item.rank > 0)
            .sort((left, right) => {
                if (right.rank !== left.rank)
                    return right.rank - left.rank
                return (left.entry.name ?? "").localeCompare(right.entry.name ?? "")
            })
            .slice(0, 8)
            .map(item => item.entry)

        if (!q.length && filtered.length === 0)
            return (apps ?? []).slice(0, 8)

        return filtered
    }

    readonly property var visibleEntries: {
        const q = query.trim()
        if (q.startsWith(">")) {
            const actionQuery = q.slice(1).trim().toLowerCase()
            return actionEntries.filter(entry => {
                if (!actionQuery.length)
                    return true
                return entry.name.toLowerCase().includes(actionQuery) || entry.comment.toLowerCase().includes(actionQuery)
            })
        }

        if (!q.length && favoriteApps.length > 0)
            return favoriteApps.slice(0, 8)

        return appEntries
    }

    function closeLauncher() {
        shouldShow = false
        query = ""
        selectedIndex = 0
    }

    function openLauncher(optScreen) {
        if (optScreen) {
            screen = optScreen
        }
        shouldShow = true
        selectedIndex = 0
        focusTimer.restart()
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (root.shouldShow) {
                searchField.forceActiveFocus()
            }
        }
    }

    function toggleLauncher(optScreen) {
        if (shouldShow) {
            closeLauncher()
        } else {
            openLauncher(optScreen)
        }
    }

    function launchEntry(entry) {
        if (!entry)
            return

        if (entry.type === "action") {
            entry.onTriggered()
            closeLauncher()
            return
        }

        if (entry.runInTerminal) {
            Quickshell.execDetached({
                command: [...terminalCommand, ...entry.command],
                workingDirectory: entry.workingDirectory
            })
        } else {
            Quickshell.execDetached({
                command: entry.command,
                workingDirectory: entry.workingDirectory
            })
        }

        closeLauncher()
    }

    onShouldShowChanged: {
        if (shouldShow) {
            selectedIndex = 0
            Qt.callLater(() => searchField.forceActiveFocus())
        }
    }

    onVisibleEntriesChanged: {
        if (selectedIndex >= visibleEntries.length)
            selectedIndex = Math.max(0, visibleEntries.length - 1)
    }

    // 1. CAPA EXTERNA: Detecta clics fuera del launcher para cerrarlo
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.closeLauncher()
    }

    // 2. PANEL DEL LAUNCHER
    FocusScope {
        id: panel
        
        // Centrado superior con ancho fijo y alto dinámico
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 45
        width: 500
        height: panelColumn.implicitHeight + 36

        property real revealOffset: shouldShow ? 0 : -20
        scale: shouldShow ? 1.0 : 0.97
        opacity: shouldShow ? 1.0 : 0.0
        focus: root.shouldShow
        transform: Translate { y: panel.revealOffset }

        Keys.onEscapePressed: root.closeLauncher()
        Keys.onDownPressed: root.selectedIndex = Math.min(root.selectedIndex + 1, root.visibleEntries.length - 1)
        Keys.onUpPressed: root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
        Keys.onReturnPressed: root.launchEntry(root.visibleEntries[root.selectedIndex])
        Keys.onEnterPressed: root.launchEntry(root.visibleEntries[root.selectedIndex])

        Behavior on scale {
            NumberAnimation { duration: 240; easing.bezierCurve: [0.22, 1.0, 0.36, 1.0] }
        }

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Behavior on revealOffset {
            NumberAnimation { duration: 260; easing.bezierCurve: [0.05, 0.7, 0.1, 1.0] }
        }

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: root.cSurface
            border.color: root.cBorder
            border.width: 1

            // Absorbe los clics dentro del panel para que NO lleguen al MouseArea externo
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        root.closeLauncher()
                    }
                }
            }

            ColumnLayout {
                id: panelColumn
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 14
                    color: root.cSurfaceContainer
                    border.width: 1
                    border.color: Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.18)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: query.trim().startsWith(">") ? "󰘳" : "󰍉"
                            font.pixelSize: 18
                            color: root.cPrimary
                        }

                        QQC.TextField {
                            id: searchField
                            Layout.fillWidth: true
                            color: root.cText
                            font.pixelSize: 14
                            placeholderText: 'Search apps or type ">" for actions'
                            placeholderTextColor: root.cSubText
                            background: Item {}
                            selectByMouse: true
                            focus: false

                            onTextChanged: {
                                root.query = text
                                root.selectedIndex = 0
                            }
                        }
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(400, listColumn.implicitHeight + 12)
                    clip: true
                    contentWidth: width
                    contentHeight: listColumn.implicitHeight

                    Column {
                        id: listColumn
                        width: panel.width - 36
                        spacing: 8

                        Repeater {
                            model: root.visibleEntries

                            Rectangle {
                                id: delegateRoot
                                required property var modelData
                                required property int index

                                width: listColumn.width
                                height: 50
                                radius: 12
                                color: root.selectedIndex === index
                                    ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.18)
                                    : (hovered.hovered ? root.cSurfaceContainerHigh : root.cSurfaceContainer)
                                border.width: 1
                                border.color: root.selectedIndex === index
                                    ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.34)
                                    : "transparent"

                                HoverHandler { id: hovered }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

                                    Text {
                                        text: delegateRoot.modelData.type === "action"
                                            ? (delegateRoot.modelData.glyph ?? "󰣆")
                                            : ((delegateRoot.modelData.name ?? "?").slice(0, 1).toUpperCase())
                                        font.pixelSize: 16
                                        font.weight: Font.DemiBold
                                        color: root.cPrimary
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            Layout.fillWidth: true
                                            text: delegateRoot.modelData.name ?? "Unknown"
                                            font.pixelSize: 13
                                            font.weight: Font.Medium
                                            color: root.cText
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: delegateRoot.modelData.comment || delegateRoot.modelData.genericName || "Launch"
                                            font.pixelSize: 11
                                            color: root.cSubText
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = delegateRoot.index
                                    onClicked: root.launchEntry(delegateRoot.modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
