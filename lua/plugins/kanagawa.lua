return {
	{
		"rebelot/kanagawa.nvim",
		config = function()
			require("kanagawa").setup({
				compile = true,
				undercurl = true,
				transparent = true,
				theme = "wave",
				background = {
					dark = "wave",
					light = "wave",
				},
				dimInactive = true,
				terminalColors = true,
				colors = {
					theme = {
						all = {
							ui = {
								bg_gutter = "none",
							},
						},
						wave = {
							ui = {
								float = {
									bg = "none",
								},
							},
						},
					},
				},
				overrides = function(colors)
					local theme = colors.theme
					return {
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },

						NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

						LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

						MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
					}
				end,
			})
			--Set colorscheme (order is important here)
			vim.o.termguicolors = true
			vim.g.onedark_terminal_italics = 2

			vim.cmd([[silent! KanagawaCompile ]])
			vim.cmd([[silent! colorscheme kanagawa]])
		end,
	},
}
