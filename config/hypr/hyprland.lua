--  _   _                  _                 _
-- | | | |_   _ _ __  _ __| | __ _ _ __   __| |
-- | |_| | | | | '_ \| '__| |/ _` | '_ \ / _` |
-- |  _  | |_| | |_) | |  | | (_| | | | | (_| |
-- |_| |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|
--        |___/|_|

------------------
---- MONITORS ----
------------------
require("conf/monitor")

------------------
---- COLORS ------ 
------------------
require("colors")

-------------------
---- AUTOSTART ----
-------------------
require("conf/autostart")

-------------------
------ INPUT ------
-------------------
require("conf/input")

-------------------
-- CONFIGURATION --
-------------------
require("conf/window")
require("conf/decoration")
require("conf/layout")
require("conf/workspace")
require("conf/misc")
require("conf/windowrule")
require("conf/animation")
require("conf/shaders")

---------------------
---- KEYBINDINGS ----
---------------------
require("conf.keybinding")

-- Custom

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("qs")
    hl.exec_cmd("/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("~/nixos-dotfiles/config/hypr/scripts/unmute-headphones.sh")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
end)
