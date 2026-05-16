return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate", -- Se asegura de que los parsers estén siempre actualizados
  event = { "BufReadPost", "BufNewFile" }, -- Carga Treesitter al abrir/crear archivos
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    -- Puedes activar más módulos aquí si quieres
    -- rainbow = { enable = true }, -- Ejemplo: paréntesis en color (si usas el plugin extra)
    ensure_installed = { "lua", "python", "bash", "javascript", "html", "css", "markdown" }, -- Cambia o amplía según tus lenguajes
    auto_install = true, -- Instala automáticamente los parsers que falten
  },
}
