return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar archivos" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar texto en proyecto" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buscar buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Buscar ayuda" },
		},
		opts = {
			defaults = {
				layout_config = {
					horizontal = { preview_width = 0.5 },
				},
				prompt_prefix = " ",
				selection_caret = " ",
				sorting_strategy = "ascending",
			},
			pickers = {
				find_files = {
					hidden = true,
				},
			},
			extensions = {
				["ui-select"] = {},
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)

			local themes = require("telescope.themes")

			telescope.setup({
				extensions = {
					["ui-select"] = themes.get_dropdown({}),
				},
			})

			-- 🔑 Aquí sí se carga la extensión para usar telescope en las Code Actions
			telescope.load_extension("ui-select")
		end,
	},
}
