return{
	"folke/lazydev.nvim",
	ft = "lua", -- solo se carga para archivos lua (más eficiente)
	opts = {
		library = {
			"nvim-dap-ui",
		},
	},
}
