pragma Singleton
import QtQuick

QtObject {
    // === COLORES BASE ===
    readonly property color bgPrimary: "#11111b"      // Fondo principal de popups / tarjetas
    readonly property color bgSecondary: "#1e1e2e"    // Fondo de widgets / elementos secundarios
    readonly property color bgHover: "#313244"        // Estado hover / elementos inactivos

    // === BORDES Y LÍNEAS ===
    readonly property color borderPrimary: "#313244"  // Bordes sutiles
    readonly property color borderActive: "#a6e3a1"   // Bordes destacados / activos

    // === TEXTO ===
    readonly property color textPrimary: "#cdd6f4"    // Texto principal
    readonly property color textSecondary: "#a6adc8"  // Subtítulos / texto atenuado
    readonly property color textMuted: "#6c7086"      // Texto deshabilitado / muy secundario
    readonly property color textDark: "#11111b"       // Texto sobre fondos claros

    // === ACCENTOS Y ESTADOS ===
    readonly property color accent: "#89b4fa"         // Color de acento principal (ej. Bluetooth, activos)
    readonly property color danger: "#f38ba8"         // Para apagar, cancelar, DND activo, errores
    readonly property color warning: "#f9e2af"        // Para brillo, alertas
    readonly property color success: "#a6e3a1"        // Para estado activo/modo juego
    readonly property color wifiAccent: "#e86a58"     // Color específico de Wi-Fi / volumen
}
