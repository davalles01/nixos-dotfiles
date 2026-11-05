-- =====================================================
-- Keybindings (Lua API)
-- =====================================================

-- Definición de variables locales
local mainMod = "CTRL"
local terminal = "kitty"
local fileManager = "thunar"
local menu = [[qs ipc call launcher toggleOnScreen $(hyprctl monitors | awk '/^Monitor/ {for(i=1;i<=NF;i++) if($i=="ID" || $i=="(ID") id=$(i+1)} /focused: yes/ {gsub(/[^0-9]/, "", id); print id}')]]

-- Charge solaar configuration
hl.bind(mainMod .. "+ SHIFT + R", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/solaar.sh"))

-- Main Key binds
hl.bind(mainMod .. "+ Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. "+ D", function() hl.dispatch(hl.dsp.window.close()) end)
hl.bind(mainMod .. "+ E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. "+ SHIFT + E", hl.dsp.exec_cmd(fileManager .. " " .. os.getenv("HOME") .. "/Desktop"))
hl.bind("SHIFT + TAB", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.pin())
end, { description = "Toggle floating + pinned" }) -- Activate floating window
hl.bind(mainMod .. "+ R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. "+ P", function() hl.dispatch(hl.dsp.window.pseudo()) end)
hl.bind(mainMod .. "+ J", function() hl.dispatch(hl.dsp.layout("togglesplit")) end)

-- Workspaces overview 
hl.bind(mainMod .. "+ TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))

-- Lock screen
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Hyprshot
hl.bind("+ PRINT", hl.dsp.exec_cmd("hyprshot -m region --clipboard"))

-- Open neovim
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("kitty -- nvim & disown"))

-- Execute Firefox
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("firefox"))

-- Open quickshell Wallpaper Manager
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("quickshell ipc call wallpaper toggle"))

-- Move focus / Cycle next
hl.bind("ALT + TAB", hl.dsp.window.cycle_next())

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. "+ 1", hl.dsp.focus({ workspace = "1" }))
hl.bind(mainMod .. "+ 2", hl.dsp.focus({ workspace = "2" }))
hl.bind(mainMod .. "+ 3", hl.dsp.focus({ workspace = "3" }))
hl.bind(mainMod .. "+ 4", hl.dsp.focus({ workspace = "4" }))
hl.bind(mainMod .. "+ 5", hl.dsp.focus({ workspace = "5" }))
hl.bind(mainMod .. "+ 6", hl.dsp.focus({ workspace = "6" }))
hl.bind(mainMod .. " + ALT + 1", hl.dsp.focus({ workspace = "7" }))
hl.bind(mainMod .. " + ALT + 2", hl.dsp.focus({ workspace = "8" }))
hl.bind(mainMod .. "+ 9", hl.dsp.focus({ workspace = "9" }))
hl.bind(mainMod .. "+ 0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT+ 1", function() hl.dispatch(hl.dsp.window.move({ workspace = "1" })) end)
hl.bind(mainMod .. " + SHIFT+ 2", function() hl.dispatch(hl.dsp.window.move({ workspace = "2" })) end)
hl.bind(mainMod .. " + SHIFT+ 3", function() hl.dispatch(hl.dsp.window.move({ workspace = "3" })) end)
hl.bind(mainMod .. " + SHIFT+ 4", function() hl.dispatch(hl.dsp.window.move({ workspace = "4" })) end)
hl.bind(mainMod .. " + SHIFT+ 5", function() hl.dispatch(hl.dsp.window.move({ workspace = "5" })) end)
hl.bind(mainMod .. " + SHIFT+ 6", function() hl.dispatch(hl.dsp.window.move({ workspace = "6" })) end)
hl.bind(mainMod .. " + SHIFT+ ALT + 1", function() hl.dispatch(hl.dsp.window.move({ workspace = "7" })) end)
hl.bind(mainMod .. " + SHIFT+ +ALT + 2", function() hl.dispatch(hl.dsp.window.move({ workspace = "8" })) end)
hl.bind(mainMod .. " + SHIFT+ 9", function() hl.dispatch(hl.dsp.window.move({ workspace = "9" })) end)
hl.bind(mainMod .. " + SHIFT+ 0", function() hl.dispatch(hl.dsp.window.move({ workspace = "10" })) end)

-- Gestos
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. "+ mouse:274", function() hl.dispatch(hl.dsp.window.drag()) end, { mouse = true })
hl.bind(mainMod .. "+ mouse:273", function() hl.dispatch(hl.dsp.window.resize()) end, { mouse = true })

-- Laptop multimedia keys for volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("quickshell ipc call volume raise"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("quickshell ipc call volume lower"), { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("quickshell ipc call volume toggleMute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Laptop multimedia keys for LCD brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("quickshell ipc call brightness raise"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("quickshell ipc call brightness lower"), { repeating = true, locked = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"), { locked = true })
