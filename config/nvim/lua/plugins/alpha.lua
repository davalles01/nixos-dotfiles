return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },

	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			[[                                                                     ]],
			[[       ███████████           █████      ██                     ]],
			[[      ███████████             █████                             ]],
			[[      ████████████████ ███████████ ███   ███████     ]],
			[[     ████████████████ ████████████ █████ ██████████████   ]],
			[[    ██████████████    █████████████ █████ █████ ████ █████   ]],
			[[  ██████████████████████████████████ █████ █████ ████ █████  ]],
			[[ ██████  ███ █████████████████ ████ █████ █████ ████ ██████ ]],
		}

		-- 👉 NO tocamos botones → usamos los del plugin (funcionan bien)
		-- pero si quieres asegurarte:
		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", ":ene <CR>"),
			dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
			dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
			dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
			dashboard.button("q", "  Quit", ":qa<CR>"),
		}

		alpha.setup(dashboard.config)
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				if vim.fn.argc() == 0 then
					alpha.start()
				end
			end,
		})
	end,
}
