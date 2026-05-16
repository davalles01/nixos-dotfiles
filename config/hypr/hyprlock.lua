local wallpaper = io.popen("cat ~/nixos-dotfiles/config/hypr/wallpaper.conf"):read("*l")

return {
    source = "colors.conf",

    auth = {
        ["pam:enabled"] = true,
        ["pam:module"] = "hyprlock",

        ["fingerprint:enabled"] = true,
        ["fingerprint:ready_message"] = "(Scan fingerprint to unlock)",
        ["fingerprint:present_message"] = "Scanning fingerprint",
        ["fingerprint:retry_delay"] = 250,
    },

    general = {
        ignore_empty_input = true,
    },

    background = {
        {
            monitor = "",
            path = wallpaper,
        },
    },

    ["input-field"] = {
        {
            monitor = "",
            size = "200, 50",

            dots_size = 0.33,
            dots_spacing = 0.15,
            dots_center = true,
            dots_rounding = -1,

            inner_color = "$primary",
            font_color = "$on_primary",
            font_family = "Fira Semibold",

            outer_color = "$on_primary",
            outline_thickness = 3,

            fade_on_empty = true,
            fade_timeout = 1000,

            placeholder_text = "<i>Input Password...</i>",
            hide_input = false,

            rounding = 10,

            check_color = "$primary",
            fail_color = "$error",
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>",

            capslock_color = -1,
            numlock_color = -1,
            bothlock_color = -1,

            invert_numlock = false,
            swap_font_color = false,

            position = "0, -20",
            halign = "center",
            valign = "center",

            shadow_passes = 10,
            shadow_size = 20,
            shadow_color = "$shadow",
            shadow_boost = 1.6,

			hide_input = false,
			display_capslock = false,
			xray = false,
        },
    },

    label = {
        {
            monitor = "",

            text = 'cmd[update:1000] echo "$TIME"',
            color = "$primary",

            font_size = 70,
            font_family = "Fira Sans Semibold",

            position = "-50, 20",
            halign = "right",
            valign = "bottom",

            shadow_passes = 5,
            shadow_size = 10,
        },

        {
            monitor = "",

            text = "$USER",
            color = "$primary",

            font_size = 20,
            font_family = "Fira Sans Semibold",

            position = "-50, 120",
            halign = "right",
            valign = "bottom",

            shadow_passes = 5,
            shadow_size = 10,
        },
    },

    image = {
        {
            monitor = "",

            path = "$HOME/face.png",
            size = 280,

            rounding = 40,

            border_size = 4,
            border_color = "$primary $on_primary 90deg",

            rotate = 0,

            reload_time = -1,

            position = "0, 200",
            halign = "center",
            valign = "center",

            shadow_passes = 10,
            shadow_size = 20,
            shadow_color = "$shadow",
            shadow_boost = 1.6,
        },
    },
}
