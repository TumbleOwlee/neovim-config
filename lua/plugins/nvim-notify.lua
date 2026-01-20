-- prettify notifications
return {
	{
		"rcarriga/nvim-notify",
		config = function()
			-- Change color of info
			local change_color = function(lvl, fg)
				vim.cmd("highlight Notify" .. lvl .. "Border guifg=" .. fg)
				vim.cmd("highlight Notify" .. lvl .. "Icon guifg=" .. fg)
				vim.cmd("highlight Notify" .. lvl .. "Title guifg=" .. fg)
			end
			change_color("INFO", "#8080ff")

			require("notify").setup({
				stages = "fade_in_slide_out",
				timeout = 1500,
				background_colour = "#2E3440",
				render = "wrapped-compact",
				max_width = 60,
				max_height = 10,
				minimum_width = 40,
				fps = 45,
			})
			vim.notify = require("notify")
		end,
	},
}
