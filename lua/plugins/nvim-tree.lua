vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
	{
		"nvim-tree/nvim-tree.lua",
		requires = { "nvim-tree/nvim-web-devicons" },
		opts = {
			view = {
				width = 45,
			},
		},
	},
}
