import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../../../core"
import "../../services"

PanelWindow {
    id: root
    visible: false

    property WifiService wifiSvc
    property BluetoothService btSvc

    property int actualVolume: 0
    property bool isMuted: false

    // --- ACCIONES DEL SISTEMA ---
    Process { id: poweroffProc; command: ["systemctl", "poweroff"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: lockProc; command: ["hyprlock"] }
    Process { id: screenshotProc; command: ["hyprshot", "-m", "region", "--clipboard"] }

    // --- PROCESOS DE CONMUTACIÓN (TOGGLE) ---
    Process { id: toggleWifiProc }
    Process { id: toggleBtProc }

    // --- PROCESOS DE AUDIO Y BRILLO ---
    Process { id: setVolProc }
    Process { id: setBrightnessProc }

    // --- PROCESO MODO NOCHE ---
    Process {
        id: nightModeProc
        function toggle(enableNightMode) {
            let confFile = "$HOME/nixos-dotfiles/config/hypr/conf/shaders.conf"
            let shaderPath = "$HOME/nixos-dotfiles/config/hypr/conf/shaders/blue-light-filter.frag"
            let content = enableNightMode ? `decoration { \n    screen_shader = ${shaderPath} \n}` : ""
            
            let cmd = `echo '${content}' > ${confFile} && hyprctl reload`
            command = ["bash", "-c", cmd]
            running = true
        }
    }

    // Proceso para detectar estado real del Modo Noche
    Process {
        id: checkNightModeProc
        command: ["bash", "-c", "grep -q 'screen_shader' $HOME/nixos-dotfiles/config/hypr/conf/shaders.conf"]
        onExited: (exitCode) => {
            nightModeWidget.isNightMode = (exitCode === 0)
        }
    }

    // --- PROCESO MODO JUEGO ---
    Process {
        id: gameModeProc
        function toggle(enableGameMode) {
            let confFile = "$HOME/nixos-dotfiles/config/hypr/conf/keybinding.conf"
            let targetFile = enableGameMode 
                ? "~/nixos-dotfiles/config/hypr/conf/keybindings/daniConfig-gamemode.conf" 
                : "~/nixos-dotfiles/config/hypr/conf/keybindings/daniConfig.conf"

            let cmd = `sed -i 's|^source = .*|source = ${targetFile}|' ${confFile} && hyprctl reload`
            command = ["bash", "-c", cmd]
            running = true
        }
    }

    // Proceso para detectar estado real del Modo Juego
    Process {
        id: checkGameModeProc
        command: ["bash", "-c", "grep -q 'daniConfig-gamemode.conf' $HOME/nixos-dotfiles/config/hypr/conf/keybinding.conf"]
        onExited: (exitCode) => {
            gameModeWidget.isGameMode = (exitCode === 0)
        }
    }

    // Proceso para sincronizar volumen y estado Mute
    Process {
        id: syncVolProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: (data) => {
                let text = data.trim()
                root.isMuted = text.includes("[MUTED]")

                let parts = text.split(" ")
                if (parts.length >= 2) {
                    let vol = Math.round(parseFloat(parts[1]) * 100)
                    root.actualVolume = vol

                    if (!volSlider.pressed) {
                        volSlider.value = Math.min(vol, 100)
                    }
                }
            }
        }
    }

    Timer {
        interval: 300
        running: root.visible
        repeat: true
        onTriggered: syncVolProc.running = true
    }

    anchors {
        top: true; bottom: true; left: true; right: true
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function toggle() {
        root.visible = !root.visible
    }

    function refreshAllStates() {
        syncVolProc.running = true
        checkNightModeProc.running = true
        checkGameModeProc.running = true
        if (root.wifiSvc && typeof root.wifiSvc.updateState === "function") root.wifiSvc.updateState()
        if (root.btSvc && typeof root.btSvc.updateState === "function") root.btSvc.updateState()
    }

    Component.onCompleted: refreshAllStates()

    property bool showPowerConfirm: false
    property bool showRebootConfirm: false

    onVisibleChanged: {
        if (root.visible) {
            contentCard.forceActiveFocus()
            refreshAllStates()
        } else {
            root.showPowerConfirm = false
            root.showRebootConfirm = false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: contentCard
        width: 340
        height: 620
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 44
        anchors.rightMargin: 12

        color: Theme.colors.crust
        radius: 24
        border.color: Theme.colors.surface1
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
        }

        Keys.onEscapePressed: root.visible = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // --- CABECERA ---
            RowLayout {
                Layout.fillWidth: true

                Column {
                    Text {
                        text: Qt.formatDateTime(new Date(), "hh:mm")
                        color: Theme.colors.text
                        font.pixelSize: 34
                        font.bold: true
                    }
                    Text {
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d").toUpperCase()
                        color: Theme.colors.subtext0
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 16

                    Text {
                        text: "󰌾"
                        font.pixelSize: 20
                        color: Theme.colors.text
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: lockProc.running = true
                        }
                    }
                    Text {
                        text: "󰜉"
                        font.pixelSize: 20
                        color: Theme.colors.text
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showRebootConfirm = true 
                        }
                    }
                    Text {
                        text: "󰐥"
                        font.pixelSize: 20
                        color: Theme.colors.red
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showPowerConfirm = true 
                        }
                    }
                }
            }

            // --- RECUADROS PRINCIPALES ---
            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 10
                Layout.fillWidth: true

                // Wi-Fi
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: root.wifiSvc?.powered ? Theme.colors.peach : Theme.colors.surface0
                    radius: 18

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.wifiSvc) root.wifiSvc.toggleWifi()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: root.wifiSvc?.powered ? (root.wifiSvc?.connected ? "󰤨" : "󰤟") : "󰤮"
                            font.pixelSize: 22
                            color: root.wifiSvc?.powered ? Theme.colors.crust : Theme.colors.text
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: "Wi-Fi"
                                font.bold: true
                                color: root.wifiSvc?.powered ? Theme.colors.crust : Theme.colors.text
                            }

                            Text {
                                text: root.wifiSvc?.powered ? (root.wifiSvc?.connected ? root.wifiSvc?.ssid : "Desconectado") : "Apagado"
                                color: root.wifiSvc?.powered ? Theme.colors.mantle : Theme.colors.subtext0
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Bluetooth
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: root.btSvc?.powered ? Theme.colors.blue : Theme.colors.surface0
                    radius: 18

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.btSvc) root.btSvc.toggleBt()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: root.btSvc?.powered ? (root.btSvc?.connected ? "󰂱" : "󰂯") : "󰂲"
                            font.pixelSize: 22
                            color: root.btSvc?.powered ? Theme.colors.crust : Theme.colors.text
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: "Bluetooth"
                                font.bold: true
                                color: root.btSvc?.powered ? Theme.colors.crust : Theme.colors.text
                            }

                            Text {
                                text: root.btSvc?.powered ? (root.btSvc?.connected ? root.btSvc?.deviceName : "Desconectado") : "Apagado"
                                color: root.btSvc?.powered ? Theme.colors.mantle : Theme.colors.subtext0
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Do Not Disturb
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 65
                    color: DndService.dndActive ? Theme.colors.red : Theme.colors.base; radius: 18
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 10
                        Text { text: DndService.dndActive ? "󰂛" : "󰂚"; font.pixelSize: 22; color: DndService.dndActive ? Theme.colors.crust : Theme.colors.text }
                        Column {
                            Text { text: "Do Not ..."; font.bold: true; color: DndService.dndActive ? Theme.colors.crust : Theme.colors.text }
                            Text { text: DndService.dndActive ? "On" : "Off"; color: DndService.dndActive ? Theme.colors.mantle : Theme.colors.subtext0; font.pixelSize: 11 }
                        }
                    }
                    MouseArea { 
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: DndService.toggle() 
                    }
                }

                // Gaming Mode 
                Rectangle {
                    id: gameModeWidget
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: isGameMode ? Theme.colors.surface0 : Theme.colors.base
                    radius: 18

                    border.color: isGameMode ? Theme.colors.green : "transparent"
                    border.width: 1

                    property bool isGameMode: false

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text { 
                            text: "󰓅"
                            font.pixelSize: 22
                            color: gameModeWidget.isGameMode ? Theme.colors.green : Theme.colors.text
                        }

                        Column {
                            Text { 
                                text: "Gaming"
                                font.bold: true
                                color: Theme.colors.text 
                            }
                            Text { 
                                text: gameModeWidget.isGameMode ? "Perf." : "Bal."
                                color: gameModeWidget.isGameMode ? Theme.colors.green : Theme.colors.subtext0
                                font.pixelSize: 11 
                            }
                        }
                    }

                    MouseArea { 
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            gameModeWidget.isGameMode = !gameModeWidget.isGameMode
                            gameModeProc.toggle(gameModeWidget.isGameMode)
                        }
                    }
                }

                // Modo Noche (Luna)
                Rectangle {
                    id: nightModeWidget
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: isNightMode ? Theme.colors.blue : Theme.colors.base
                    radius: 18

                    property bool isNightMode: false

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: "󰔎"
                            font.pixelSize: 22
                            color: nightModeWidget.isNightMode ? Theme.colors.crust : Theme.colors.text
                        }

                        Column {
                            Text {
                                text: "Night Mode"
                                font.bold: true
                                color: nightModeWidget.isNightMode ? Theme.colors.crust : Theme.colors.text
                            }
                            Text {
                                text: nightModeWidget.isNightMode ? "On" : "Off"
                                color: nightModeWidget.isNightMode ? Theme.colors.mantle : Theme.colors.subtext0
                                font.pixelSize: 11
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            nightModeWidget.isNightMode = !nightModeWidget.isNightMode
                            nightModeProc.toggle(nightModeWidget.isNightMode)
                        }
                    }
                }

                // Screenshot (Capture)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: Theme.colors.base
                    radius: 18

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text { text: "󰄄"; font.pixelSize: 22; color: Theme.colors.text }

                        Column {
                            Text { text: "Capture"; font.bold: true; color: Theme.colors.text }
                            Text { text: "Screen"; color: Theme.colors.subtext0; font.pixelSize: 11 }
                        }
                    }

                    MouseArea { 
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            screenshotProc.running = true
                            root.visible = false
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 5 }

            // --- SLIDERS ---
            RowLayout {
                Layout.fillWidth: true; spacing: 12
                Text { 
                    text: root.isMuted ? "󰝟" : "󰕾"
                    font.pixelSize: 18
                    color: root.isMuted ? Theme.colors.overlay0 : Theme.colors.peach 
                }
                Slider {
                    id: volSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    opacity: root.isMuted ? 0.4 : 1.0

                    onMoved: {
                        let targetVal = (value / 100).toFixed(2)
                        setVolProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", targetVal]
                        setVolProc.running = true
                    }
                }
                Text { 
                    text: root.actualVolume + "%"
                    font.bold: true
                    color: root.isMuted ? Theme.colors.overlay0 : Theme.colors.text
                    Layout.preferredWidth: 40 
                }
            }

            BrightnessService { id: brightSvc }

            RowLayout {
                Layout.fillWidth: true; spacing: 12
                Text { text: "󰃠"; font.pixelSize: 18; color: Theme.colors.yellow }
                Slider {
                    id: brightSlider
                    Layout.fillWidth: true
                    from: 1
                    to: 100
                    value: brightSvc.maxBrightness > 0 ? Math.round((brightSvc.brightness / brightSvc.maxBrightness) * 100) : 50

                    onMoved: {
                        setBrightnessProc.command = ["brightnessctl", "set", Math.round(value) + "%"]
                        setBrightnessProc.running = true
                    }
                }
                Text { 
                    text: Math.round(brightSlider.value) + "%"
                    font.bold: true
                    color: Theme.colors.text
                    Layout.preferredWidth: 40 
                }
            }

            Item { Layout.preferredHeight: 5 }

            // --- ESTADÍSTICAS ---
            RowLayout {
                Layout.fillWidth: true
                
                Column {
                    Layout.fillWidth: true
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "CPU"; font.pixelSize: 10; color: Theme.colors.subtext0; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "10%"; font.pixelSize: 20; color: Theme.colors.text; font.bold: true }
                }
                Rectangle { width: 1; height: 25; color: Theme.colors.surface0 }
                
                Column {
                    Layout.fillWidth: true
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "RAM"; font.pixelSize: 10; color: Theme.colors.subtext0; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "23%"; font.pixelSize: 20; color: Theme.colors.text; font.bold: true }
                }
                Rectangle { width: 1; height: 25; color: Theme.colors.surface0 }
                
                Column {
                    Layout.fillWidth: true
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "DISK"; font.pixelSize: 10; color: Theme.colors.subtext0; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "2%"; font.pixelSize: 20; color: Theme.colors.text; font.bold: true }
                }
            }
        }

        // --- CONFIRMACIONES ---
        Rectangle {
            anchors.fill: parent
            color: Theme.colors.crust
            opacity: 0.95
            radius: 24
            visible: root.showPowerConfirm
            Column {
                anchors.centerIn: parent; spacing: 15
                Text { text: "¿Seguro que quieres apagar?"; color: Theme.colors.text; font.bold: true }
                Row {
                    spacing: 15; anchors.horizontalCenter: parent.horizontalCenter
                    Button { text: "Sí"; onClicked: poweroffProc.running = true }
                    Button { text: "No"; onClicked: root.showPowerConfirm = false }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.colors.crust
            opacity: 0.95
            radius: 24
            visible: root.showRebootConfirm
            Column {
                anchors.centerIn: parent; spacing: 15
                Text { text: "¿Seguro que quieres reiniciar?"; color: Theme.colors.text; font.bold: true }
                Row {
                    spacing: 15; anchors.horizontalCenter: parent.horizontalCenter
                    Button { text: "Sí"; onClicked: rebootProc.running = true }
                    Button { text: "No"; onClicked: root.showRebootConfirm = false }
                }
            }
        }
    }
}
