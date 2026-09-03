-- Usa tabuladores reales, no espacios
vim.opt.expandtab = false   -- No convertir TAB a espacios
vim.opt.tabstop = 4         -- Un TAB = 4 espacios visuales
vim.opt.shiftwidth = 4      -- Indentación automática = 4 espacios (1 tab)
vim.opt.softtabstop = 4     -- Al presionar TAB = 4 espacios, o 1 tab

-- Números de línea y relativos
vim.opt.number = true           -- Muestra el número absoluto de la línea actual
vim.opt.relativenumber = true   -- Otras líneas muestran la distancia en líneas

-- Copiar al portapapeles al usar yank o delete
vim.opt.clipboard = "unnamedplus"

-- Remapeo forzado en Modo Visual para Ctrl+C
vim.keymap.set("v", "<C-c>", function()
    vim.cmd('normal! "+y')
end, { noremap = true, silent = true })
