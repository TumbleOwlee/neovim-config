-- List of diagnostics
return {
	{
		"folke/trouble.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		opts = {
			modes = {
				diagnostics = {
					auto_open = false,
				},
			},
			auto_close = true,
			max_items = 10000,
		},
	},
}
