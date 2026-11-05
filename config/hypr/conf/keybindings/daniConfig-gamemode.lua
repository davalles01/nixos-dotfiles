-- Hyprshot
hl.bind("+ PRINT", hl.dsp.exec_cmd("hyprshot -m region --clipboard"))

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
