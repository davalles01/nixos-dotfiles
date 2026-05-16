return {
	"nvimtools/none-ls.nvim",
			vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {}),
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	opts = function()
		local null_ls = require("null-ls")
		return {
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.completion.spell,
				require("none-ls.diagnostics.eslint"),
				null_ls.builtins.formatting.qmlformat,
			},
		}
	end,
}
