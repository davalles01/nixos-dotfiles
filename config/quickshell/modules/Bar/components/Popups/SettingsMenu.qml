import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../services"

PanelWindow {
    id: root
    visible: false

    // PROPIEDADES GLOBALES PARA RECIBIR LOS SERVICIOS DESDE SHELL.QML
    property WifiService wifiSvc
    property BluetoothService btSvc

    // Propiedades para rastrear el volumen real y si está silenciado
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

    // --- PROCESO MODO NOCHE (SHADER LUZ AZUL) ---
    Process {
        id: nightModeProc

        function toggle(enableNightMode) {
            let confFile = "$HOME/nixos-dotfiles/config/hypr/conf/shaders.conf"
            let shaderPath = "$HOME/nixos-dotfiles/config/hypr/conf/shaders/blue-light-filter.frag"
			let content = enableNightMode ? `decoration { 
				screen_shader = ${shaderPath} 
			}` : ""
            
            let cmd = `echo '${content}' > ${confFile} && hyprctl reload`
            command = ["bash", "-c", cmd]
            running = true
        }
    }

    // --- PROCESO DE CAMBIO DE MODO (JUEGO - NORMAL) ---
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

    // Timer para consultar el volumen dinámicamente cuando el popup está abierto
    Timer {
        interval: 300
        running: root.visible
        repeat: true
        onTriggered: syncVolProc.running = true
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function toggle() {
        root.visible = !root.visible
    }

    property bool showPowerConfirm: false
    property bool showRebootConfirm: false

    onVisibleChanged: {
        if (root.visible) {
            contentCard.forceActiveFocus()
            syncVolProc.running = true
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

        color: "#11111b"
        radius: 24
        border.color: "#313244"
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
                        color: "#cdd6f4"
                        font.pixelSize: 34
                        font.bold: true
                    }
                    Text {
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d").toUpperCase()
                        color: "#a6adc8"
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
                        color: "#cdd6f4"
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: lockProc.running = true
                        }
                    }
                    Text {
                        text: "󰜉"
                        font.pixelSize: 20
                        color: "#cdd6f4"
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showRebootConfirm = true 
                        }
                    }
                    Text {
                        text: "󰐥"
                        font.pixelSize: 20
                        color: "#f38ba8"
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showPowerConfirm = true 
                        }
                    }
                }
            }

            // --- RECUADROS PRINCIPALES (GRID 2 COLUMNAS) ---
            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 10
                Layout.fillWidth: true

                // Tarjeta Wi-Fi
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: root.wifiSvc?.powered ? "#e86a58" : "#313244"
                    radius: 18

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.wifiSvc) root.wifiSvc.toggleWifi()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: root.wifiSvc?.powered ? (root.wifiSvc?.connected ? "󰤨" : "󰤟") : "󰤮"
                            font.pixelSize: 22
                            color: root.wifiSvc?.powered ? "#11111b" : "#cdd6f4"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: "Wi-Fi"
                                font.bold: true
                                color: root.wifiSvc?.powered ? "#11111b" : "#cdd6f4"
                            }

                            Text {
                                text: root.wifiSvc?.powered ? (root.wifiSvc?.connected ? root.wifiSvc?.ssid : "Desconectado") : "Apagado"
                                color: root.wifiSvc?.powered ? "#313244" : "#a6adc8"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Tarjeta Bluetooth
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: root.btSvc?.powered ? "#89b4fa" : "#313244"
                    radius: 18

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.btSvc) root.btSvc.toggleBt()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: root.btSvc?.powered ? (root.btSvc?.connected ? "󰂱" : "󰂯") : "󰂲"
                            font.pixelSize: 22
                            color: root.btSvc?.powered ? "#11111b" : "#cdd6f4"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: "Bluetooth"
                                font.bold: true
                                color: root.btSvc?.powered ? "#11111b" : "#cdd6f4"
                            }

                            Text {
                                text: root.btSvc?.powered ? (root.btSvc?.connected ? root.btSvc?.deviceName : "Desconectado") : "Apagado"
                                color: root.btSvc?.powered ? "#313244" : "#a6adc8"
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
                    color: DndService.dndActive ? "#f38ba8" : "#1e1e2e"; radius: 18
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 10
                        Text { text: DndService.dndActive ? "󰂛" : "󰂚"; font.pixelSize: 22; color: DndService.dndActive ? "#11111b" : "#cdd6f4" }
                        Column {
                            Text { text: "Do Not ..."; font.bold: true; color: DndService.dndActive ? "#11111b" : "#cdd6f4" }
                            Text { text: DndService.dndActive ? "On" : "Off"; color: DndService.dndActive ? "#313244" : "#a6adc8"; font.pixelSize: 11 }
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
                    color: isGameMode ? "#313244" : "#1e1e2e"
                    radius: 18

                    border.color: isGameMode ? "#a6e3a1" : "transparent"
                    border.width: 1

                    property bool isGameMode: false

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text { 
                            text: "󰓅"
                            font.pixelSize: 22
                            color: gameModeWidget.isGameMode ? "#a6e3a1" : "#cdd6f4"
                        }

                        Column {
                            Text { 
                                text: "Gaming"
                                font.bold: true
                                color: "#cdd6f4" 
                            }
                            Text { 
                                text: gameModeWidget.isGameMode ? "Perf." : "Bal."
                                color: gameModeWidget.isGameMode ? "#a6e3a1" : "#a6adc8"
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
                    color: isNightMode ? "#89b4fa" : "#1e1e2e"
                    radius: 18

                    property bool isNightMode: false

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: "󰔎"
                            font.pixelSize: 22
                            color: nightModeWidget.isNightMode ? "#11111b" : "#cdd6f4"
                        }

                        Column {
                            Text {
                                text: "Night Mode"
                                font.bold: true
                                color: nightModeWidget.isNightMode ? "#11111b" : "#cdd6f4"
                            }
                            Text {
                                text: nightModeWidget.isNightMode ? "On" : "Off"
                                color: nightModeWidget.isNightMode ? "#313244" : "#a6adc8"
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
                    color: "#1e1e2e"
                    radius: 18

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text { text: "󰄄"; font.pixelSize: 22; color: "#cdd6f4" }

                        Column {
                            Text { text: "Capture"; font.bold: true; color: "#cdd6f4" }
                            Text { text: "Screen"; color: "#a6adc8"; font.pixelSize: 11 }
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

            // Slider de Volumen
            RowLayout {
                Layout.fillWidth: true; spacing: 12
                Text { 
                    text: root.isMuted ? "󰝟" : "󰕾"
                    font.pixelSize: 18
                    color: root.isMuted ? "#6c7086" : "#e86a58" 
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
                    color: root.isMuted ? "#6c7086" : "#cdd6f4"
                    Layout.preferredWidth: 40 
                }
            }

            // Servicio de Brillo
            BrightnessService { id: brightSvc }

            // Slider de Brillo
            RowLayout {
                Layout.fillWidth: true; spacing: 12
                Text { text: "󰃠"; font.pixelSize: 18; color: "#f9e2af" }
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
                    color: "#cdd6f4"
                    Layout.preferredWidth: 40 
                }
            }

            Item { Layout.preferredHeight: 5 }

            // --- ESTADÍSTICAS ---
            RowLayout {
                Layout.fillWidth: true
                
                Column {
                    Layout.fillWidth: true
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "CPU"; font.pixelSize: 10; color: "#a6adc8"; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "10%"; font.pixelSize: 20; color: "#cdd6f4"; font.bold: true }
                }
                Rectangle { width: 1; height: 25; color: "#313244" }
                
                Column {
                    Layout.fillWidth: true
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "RAM"; font.pixelSize: 10; color: "#a6adc8"; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "23%"; font.pixelSize: 20; color: "#cdd6f4"; font.bold: true }
                }
                Rectangle { width: 1; height: 25; color: "#313244" }
                
                Column {
                    Layout.fillWidth: true
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "DISK"; font.pixelSize: 10; color: "#a6adc8"; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "2%"; font.pixelSize: 20; color: "#cdd6f4"; font.bold: true }
                }
            }
        }

        // --- CONFIRMACIÓN APAGAR ---
        Rectangle {
            anchors.fill: parent
            color: "#11111bcc"
            radius: 24
            visible: root.showPowerConfirm
            Column {
                anchors.centerIn: parent; spacing: 15
                Text { text: "¿Seguro que quieres apagar?"; color: "#cdd6f4"; font.bold: true }
                Row {
                    spacing: 15; anchors.horizontalCenter: parent.horizontalCenter
                    Button { text: "Sí"; onClicked: poweroffProc.running = true }
                    Button { text: "No"; onClicked: root.showPowerConfirm = false }
                }
            }
        }

        // --- CONFIRMACIÓN REINICIAR ---
        Rectangle {
            anchors.fill: parent
            color: "#11111bcc"
            radius: 24
            visible: root.showRebootConfirm
            Column {
                anchors.centerIn: parent; spacing: 15
                Text { text: "¿Seguro que quieres reiniciar?"; color: "#cdd6f4"; font.bold: true }
                Row {
                    spacing: 15; anchors.horizontalCenter: parent.horizontalCenter
                    Button { text: "Sí"; onClicked: rebootProc.running = true }
                    Button { text: "No"; onClicked: root.showRebootConfirm = false }
                }
            }
        }
    }
}
