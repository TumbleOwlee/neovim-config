local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local Util = require("config.util")

-- Install lazy.nvim
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		Util.abort("Failed to clone lazy.nvim:", out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })

-- Configure leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup lazy
require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
	checker = { enabled = true },
})

vim.api.nvim_create_user_command("SyncInstall", "Lazy update", { desc = "Install all plugins synchronously!" })
