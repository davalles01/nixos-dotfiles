-- =====================================================
-- Window rules (Lua API)
-- =====================================================

-- Thunar popups (modales) 
hl.window_rule({
    match = {
        class = "^(thunar)$",
        title = "^Rename.*",
    },
    float = true,
    center = true,
    size = {342, 127},
})

-- Nmtui
hl.window_rule({
    match = {
        class = "nmtui-popup",
    },
    float = true,
    center = true,
    size = {800, 900},
})

-- Bluetooth
hl.window_rule({
    match = {
        class = "%.blueman%-manager%-wrapped",
    },
    float = true,
    center = true,
    size = {600, 450},
})
