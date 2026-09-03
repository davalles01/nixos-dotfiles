// modules/WallpaperSelector/WallpaperSelector.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../core"

PanelWindow {
    id: win

    property bool isOpen: false
    visible: isOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WallpaperService { id: wpSvc }

    // Al abrir, refresca la lista y da el foco a la ventana para capturar ESC
    onIsOpenChanged: {
        if (isOpen) {
            wpSvc.refresh()
            mainContainer.forceActiveFocus()
        }
    }

    // Fondo oscurecido (clic fuera para cerrar)
    Rectangle {
        anchors.fill: parent
        color: "#80000000"

        MouseArea {
            anchors.fill: parent
            onClicked: win.isOpen = false
        }
    }

    // Ventana Contenedora Central
    Rectangle {
        id: mainContainer
        anchors.centerIn: parent
        width: 720
        height: 520
        radius: 16
        color: Theme.colors.base
        border.color: Theme.colors.surface0
        border.width: 2
        focus: true

        // Captura global de tecla ESC para la ventana
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                win.isOpen = false
                event.accepted = true
            }
        }

        // Evitar que los clics internos cierren la ventana
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Cabecera
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "󰸉  Wallpaper Selector"
                    color: Theme.colors.text
                    font.pixelSize: 18
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "ESC para salir"
                    color: Theme.colors.subtext0
                    font.pixelSize: 11
                }
            }

            // Grid de 3 columnas
            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                focus: true

                cellWidth: grid.width / 3
                cellHeight: 180

                model: wpSvc.wallpapers

                // Tecla Enter para aplicar selección activa en el Grid
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Select) {
                        if (currentIndex >= 0 && currentIndex < wpSvc.wallpapers.length) {
                            wpSvc.setWallpaper(wpSvc.wallpapers[currentIndex])
                            win.isOpen = false
                        }
                        event.accepted = true
                    }
                }

                delegate: Item {
                    id: delegateItem
                    width: grid.cellWidth
                    height: grid.cellHeight

                    property string fileName: modelData
                    property bool isCurrent: wpSvc.currentWallpaper === fileName
                    property bool isFocused: GridView.isCurrentItem

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 8
                        radius: 12
                        
                        color: isFocused ? Theme.colors.surface0 : Theme.colors.mantle
                        border.color: isCurrent ? Theme.colors.mauve : (isFocused ? Theme.colors.blue : Theme.colors.surface1)
                        border.width: isCurrent ? 3 : (isFocused ? 2 : 1)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            // Miniatura de la imagen
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                clip: true
                                color: Theme.colors.crust

                                Image {
                                    anchors.fill: parent
                                    source: Qt.resolvedUrl("file://" + wpSvc.wallpaperDir + "/" + fileName)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }

                                // Badge "Activo"
                                Rectangle {
                                    visible: isCurrent
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 6
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: Theme.colors.mauve

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        color: Theme.colors.crust
                                        font.bold: true
                                        font.pixelSize: 12
                                    }
                                }
                            }

                            // Nombre del archivo
                            Text {
                                Layout.fillWidth: true
                                text: fileName
                                color: isCurrent ? Theme.colors.mauve : Theme.colors.text
                                font.pixelSize: 11
                                font.bold: isCurrent || isFocused
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Interacción con Ratón
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: grid.currentIndex = index
                            onClicked: {
                                wpSvc.setWallpaper(fileName)
                                win.isOpen = false
                            }
                        }
                    }
                }
            }
        }
    }
}
