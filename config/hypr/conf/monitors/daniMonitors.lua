-- =====================================================
-- Monitor Setup
-- name: "Dani Monitors"
-- =====================================================

-- monitor = ,preferred,auto,1 (Comentado como en tu original)
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.monitor({
    output = "desc:Lenovo Group Limited E24-30 VNAAYRVX",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "desc:Lenovo Group Limited E24-30 VNAAYFXP",
    mode = "1920x1080@60",
    position = "1920x0",
    scale = 1,
})

hl.monitor({
    output = "eDP-1",
    mode = "1920x1200@60",
    position = "3840x0",
    scale = 1,
})
