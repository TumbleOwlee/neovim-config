local Util = {}

function Util.abort(msg, context)
	vim.api.nvim_echo({
		{ msg .. "\n", "ErrorMsg" },
		{ context, "WarningMsg" },
		{ "\nPress any key to exit..." },
	}, true, {})
	vim.fn.getchar()
	os.exit(1)
end
