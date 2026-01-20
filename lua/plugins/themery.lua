return {
	{
		"zaldih/themery.nvim",
		lazy = false,
		config = function()
			opts = {
				livePreview = true,
			}
			opts.themes = vim.fn.getcompletion("", "color")
			require("themery").setup(opts)
		end,
	},
}
