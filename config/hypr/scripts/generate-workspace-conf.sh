#!/run/current-system/sw/bin/bash

# Contar monitores conectados
MONS=$(hyprctl monitors | grep -c "^Monitor")

CONF_FILE="$HOME/nixos-dotfiles/config/hypr/conf/workspace.lua"

if [[ "$MONS" -eq 1 ]]; then
    echo 'require("conf.workspaces.laptop")' > "$CONF_FILE"
elif [[ "$MONS" -eq 3 ]]; then
    echo 'require("conf.workspaces.daniDefault")' > "$CONF_FILE"
else
    # Opción por defecto
    echo 'require("conf.workspaces.daniDefault")' > "$CONF_FILE"
fi
