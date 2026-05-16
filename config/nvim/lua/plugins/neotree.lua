return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x", -- Usa la rama estable recomendada
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- Para iconos bonitos (opcional, pero recomendado)
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Neotree: Alternar explorador de archivos" },
		-- Más comandos:	  
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,  -- Muestra archivos ocultos por defecto
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = { enabled = true },
    },
    window = {
      position = "left",
      width = 30,
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["<space>"] = "none", -- Desactiva el mapeo por defecto de espacio
      },
    },
    default_component_configs = {
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
        default = "",
      },
      git_status = {
        symbols = {
          added = "✚",
          modified = "",
          deleted = "✖",
          renamed = "",
          untracked = "",
          ignored = "",
          unstaged = "",
          staged = "",
          conflict = "",
        },
      },
    },
  },
}
