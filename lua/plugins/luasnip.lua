-- Snippets plugin
return {
	{
		"L3MON4D3/LuaSnip",
		config = function()
			require("luasnip").config.setup({
				enable_autosnippets = true,
			})
			require("luasnip.loaders.from_snipmate").load()
		end,
	},
	{
		"saadparwaiz1/cmp_luasnip",
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
	},
}
