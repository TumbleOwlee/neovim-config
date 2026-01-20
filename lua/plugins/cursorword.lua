-- Highlight all word matching word under cursor
return {
	{
		"xiyaowong/nvim-cursorword",
		config = function()
			-- Set custom highlight for nvim-cursorword
			vim.api.nvim_exec([[ hi! CursorWord gui=underline cterm=undercurl ]], false)
		end,
	},
}
