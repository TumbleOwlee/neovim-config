local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local Util = require('config.util')

-- Install lazy.nvim
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        Util.abort('Failed to clone lazy.nvim:', out)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Remap space as leader key
vim.keymap.set({ 'n', 'x' }, '<Space>', '<Nop>', { silent = true })

-- Configure leader key (before lazy so plugin keys use it)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Setup lazy
require('lazy').setup({
    spec = {
        { import = 'plugins' },
    },
    -- Plugins load on their event/cmd/keys/ft trigger unless marked `lazy = false`
    defaults = { lazy = true },
    install = { colorscheme = { 'vague', 'habamax' } },
    checker = { enabled = true, notify = false },
    change_detection = { notify = false },
    performance = {
        rtp = {
            disabled_plugins = { 'gzip', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
        },
    },
})

-- Install the plugins at the commits of lazy-lock.json and move installed ones back to them, so packages contain
-- the versions committed. Uses the Lua API: with a UI attached the :Lazy command only exists after VeryLazy,
-- which is too late for `nvim +SyncInstall +qall` (CI)
vim.api.nvim_create_user_command('SyncInstall', function()
    require('lazy').install({ wait = true, show = false, lockfile = true })
    require('lazy').restore({ wait = true, show = false })
end, { desc = 'Install all plugins at the versions of lazy-lock.json' })
