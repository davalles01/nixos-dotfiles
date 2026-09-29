-- lua/plugins/onedark.lua
return {
  "navarasu/onedark.nvim",
  priority = 1000, -- Carga el tema antes que el resto de UI
  config = function()
    require("onedark").setup({
      -- Estilos disponibles: 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'
      style = "darker", -- Usa 'darker' o 'deep' para fondos bien oscuros
    })
    require("onedark").load()
  end,
}
