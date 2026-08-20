#!/run/current-system/sw/bin/bash

# Contar monitores conectados
MONS=$(hyprctl monitors | grep -c "^Monitor")

WORKSPACES_DIR="$HOME/nixos-dotfiles/config/hypr/conf/workspaces"
CONF_FILE="$HOME/nixos-dotfiles/config/hypr/conf/workspace.conf"

if [[ "$MONS" -eq 1 ]]; then
    echo "source = $WORKSPACES_DIR/laptop.conf" > "$CONF_FILE"
elif [[ "$MONS" -eq 3 ]]; then
    echo "source = $WORKSPACES_DIR/daniDefault.conf" > "$CONF_FILE"
else
    # Opción por defecto
    echo "source = $WORKSPACES_DIR/daniDefault.conf" > "$CONF_FILE"
fi
