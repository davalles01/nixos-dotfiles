--    ___       __           __           __
--   / _ |__ __/ /____  ___ / /____ _____/ /_
--  / __ / // / __/ _ \(_-</ __/ _ `/ __/ __/
-- /_/ |_\_,_/\__/\___/___/\__/\_,_/_/  \__/

hl.on("hyprland.start", function()

	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Restart portals so they catch the environment
    hl.exec_cmd("systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland xdg-desktop-portal")

    hl.exec_cmd("~/nixos-dotfiles/config/hypr/scripts/gtk.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste")
    hl.exec_cmd("~/nixos-dotfiles/config/hypr/scripts/cleanup.sh")
    hl.exec_cmd("~/nixos-dotfiles/config/hypr/scripts/generate-workspace-conf.sh") -- Generate Workspace configuration
    hl.exec_cmd("~/nixos-dotfiles/config/hypr/scripts/solaar.sh") -- Load Solaar configuration
end)
