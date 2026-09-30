#!/usr/bin/env bash

WALLPAPER="$1"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Error: Proporciona una ruta válida para la imagen."
    exit 1
fi

THEME_FILE="$HOME/nixos-dotfiles/config/quickshell/core/Themes/CurrentTheme.qml"

# Generar colores usando matugen
JSON_COLORS=$(matugen image "$WALLPAPER" -m dark --json hex 2>/dev/null)

if [ -z "$JSON_COLORS" ]; then
    echo "Error: Matugen no pudo procesar la imagen."
    exit 1
fi

# Extraer colores del JSON
get_color() {
    local key="$1"
    local fallback="$2"
    local res

    res=$(echo "$JSON_COLORS" | jq -r ".colors[\"$key\"].dark // .colors[\"$key\"].default // empty" 2>/dev/null)

    if [[ "$res" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        echo "$res"
    else
        echo "$fallback"
    fi
}

# Mapeo de colores
cBase=$(get_color 'surface' '#1e1e2e')
cSurface0=$(get_color 'surface_container' '#313244')
cSurface1=$(get_color 'surface_container_high' '#45475a')
cSurface2=$(get_color 'surface_container_highest' '#585b70')

cText=$(get_color 'on_surface' '#cdd6f4')
cSubtext0=$(get_color 'on_surface_variant' '#a6adc8')
cSubtext1=$(get_color 'outline' '#bac2de')

cPrimary=$(get_color 'primary' '#89b4fa')
cError=$(get_color 'error' '#f38ba8')
cSecondary=$(get_color 'secondary' '#f9e2af')
cTertiary=$(get_color 'tertiary' '#cba6f7')

# --- LÓGICA DE SELECCIÓN DE LOGO ---
# Convertir color HEX de surface0/base a RGB y calcular luminosidad (0 - 255)
hex_color="${cSurface0#"#"}"
r=$((16#${hex_color:0:2}))
g=$((16#${hex_color:2:2}))
b=$((16#${hex_color:4:2}))

# Luminosidad percibida = (R * 299 + G * 587 + B * 114) / 1000
luminance=$(( (r * 299 + g * 587 + b * 114) / 1000 ))

# Umbral: si la luminosidad es mayor a 160, el fondo es claro y se usa el logo negro.
if [ "$luminance" -gt 160 ]; then
    SELECTED_LOGO="nixos-black.svg"
else
    SELECTED_LOGO="nixos.svg"
fi

# Escribir CurrentTheme.qml
cat <<EOF > "$THEME_FILE"
import QtQuick

QtObject {
    id: root

    readonly property string logo: "$SELECTED_LOGO"

    readonly property QtObject colors: QtObject {
        readonly property color crust: "$cBase"
        readonly property color mantle: "$cBase"
        readonly property color base: "$cBase"

        readonly property color surface0: "$cSurface0"
        readonly property color surface1: "$cSurface1"
        readonly property color surface2: "$cSurface2"
        readonly property color overlay0: "$cSubtext1"

        readonly property color text: "$cText"
        readonly property color subtext0: "$cSubtext0"
        readonly property color subtext1: "$cSubtext1"

        readonly property color blue: "$cPrimary"
        readonly property color red: "$cError"
        readonly property color peach: "$cSecondary"
        readonly property color yellow: "$cTertiary"
        readonly property color green: "$cPrimary"
        readonly property color lavender: "$cSecondary"
        readonly property color mauve: "$cTertiary"
        readonly property color sapphire: "$cPrimary"
        readonly property color sky: "$cSecondary"
    }
}
EOF

echo "CurrentTheme.qml actualizado correctamente basado en: $WALLPAPER (Logo elegido: $SELECTED_LOGO)"
