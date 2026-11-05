#!/usr/bin/env bash

WALLPAPER="$1"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Error: Proporciona una ruta válida para la imagen."
    exit 1
fi

# Ruta donde Quickshell leerá los datos dinámicos en formato JSON
JSON_FILE="$HOME/nixos-dotfiles/config/quickshell/core/Themes/colors.json"

# Generar el JSON completo directamente usando matugen (aislando D-Bus para evitar avisos)
JSON_DATA=$(env -u DBUS_SESSION_BUS_ADDRESS matugen image "$WALLPAPER" -m dark --json hex 2>/dev/null)

if [ -z "$JSON_DATA" ]; then
    echo "Error: Matugen no pudo procesar la imagen."
    exit 1
fi

# Función auxiliar para extraer colores de forma segura con fallback
get_color() {
    local key="$1"
    local fallback="$2"
    local res

    res=$(echo "$JSON_DATA" | jq -r ".colors[\"$key\"].dark // .colors[\"$key\"].default // empty" 2>/dev/null)

    if [[ "$res" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        echo "$res"
    else
        echo "$fallback"
    fi
}

# Extraer colores individuales
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
hex_color="${cSurface0#"#"}"
r=$((16#${hex_color:0:2}))
g=$((16#${hex_color:2:2}))
b=$((16#${hex_color:4:2}))

luminance=$(( (r * 299 + G * 587 + B * 114) / 1000 ))

if [ "$luminance" -gt 160 ]; then
    SELECTED_LOGO="nixos-black.svg"
else
    SELECTED_LOGO="nixos.svg"
fi

# Guardar un JSON estructurado limpio que Quickshell leerá al vuelo
cat <<EOF > "$JSON_FILE"
{
  "logo": "$SELECTED_LOGO",
  "colors": {
    "crust": "$cBase",
    "mantle": "$cBase",
    "base": "$cBase",
    "surface0": "$cSurface0",
    "surface1": "$cSurface1",
    "surface2": "$cSurface2",
    "overlay0": "$cSubtext1",
    "text": "$cText",
    "subtext0": "$cSubtext0",
    "subtext1": "$cSubtext1",
    "blue": "$cPrimary",
    "red": "$cError",
    "peach": "$cSecondary",
    "yellow": "$cTertiary",
    "green": "$cPrimary",
    "lavender": "$cSecondary",
    "mauve": "$cTertiary",
    "sapphire": "$cPrimary",
    "sky": "$cSecondary"
  }
}
EOF

echo "colors.json actualizado correctamente basado en: $WALLPAPER"
