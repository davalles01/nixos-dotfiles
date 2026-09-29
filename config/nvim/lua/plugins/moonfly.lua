-- lua/plugins/moonfly.lua
return {
  "bluz71/vim-moonfly-colors",
  name = "moonfly",
  lazy = false,
  priority = 1000, -- Carga el tema inmediatamente
  config = function()
    -- Opciones opcionales recomendadas:
    -- vim.g.moonflyTransparent = true -- Si quieres fondo transparente
    -- vim.g.moonflyItalics = true     -- Habilita cursivas para ciertos elementos
    
    -- Cargar el tema
    vim.cmd.colorscheme("moonfly")
  end,
}
