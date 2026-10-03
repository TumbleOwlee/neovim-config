local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local Util = require('config.util')

-- Install lazy.nvim
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        Util.abort('Failed to clone lazy.nvim:', out)
    end
    -- At the commit of lazy-lock.json: installing the plugins writes the lockfile with the commit lazy.nvim is at, so
    -- staying at the head of `stable` would change the committed lockfile and leave lazy.nvim unpinned
    local ok, lock = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath('config') .. '/lazy-lock.json'), '\n'))
    end)
    local commit = ok and lock['lazy.nvim'] and lock['lazy.nvim'].commit
    if commit then
        out = vim.fn.system({ 'git', '-C', lazypath, 'checkout', '--quiet', commit })
        if vim.v.shell_error ~= 0 then
            out = vim.fn.system({ 'git', '-C', lazypath, 'fetch', '--quiet', 'origin', commit })
                .. vim.fn.system({ 'git', '-C', lazypath, 'checkout', '--quiet', commit })
            if vim.v.shell_error ~= 0 then
                Util.abort('Failed to check out lazy.nvim at ' .. commit .. ':', out)
            end
        end
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
    -- Headless (CI) a failure exits with an error, so no package is made with plugins or parsers missing, while an
    -- editor in use is kept open
    local function fail(msg)
        if #vim.api.nvim_list_uis() > 0 then
            vim.notify(msg, vim.log.levels.ERROR)
            return
        end
        vim.api.nvim_echo({ { msg, 'ErrorMsg' } }, true, { err = true })
        vim.cmd.cquit(1)
    end

    -- The plugins that are not installed or whose last tasks (clone, checkout, build) failed
    local failed = {}
    local function check()
        local Plugin = require('lazy.core.plugin')
        for name, plugin in pairs(require('lazy.core.config').plugins) do
            if not plugin._.installed or Plugin.has_errors(plugin) then
                failed[name] = true
            end
        end
    end
    require('lazy').install({ wait = true, show = false, lockfile = true })
    check()
    require('lazy').restore({ wait = true, show = false })
    check()
    if next(failed) then
        local names = vim.tbl_keys(failed)
        table.sort(names)
        return fail('SyncInstall: installing these plugins failed: ' .. table.concat(names, ', '))
    end

    -- The parsers as well, so packages contain them: on startup they are installed in the background, which `+qall`
    -- does not wait for, and not at all headless
    if vim.fn.executable('tree-sitter') == 0 then
        return fail('SyncInstall: the tree-sitter CLI is required to install the parsers')
    end
    local ok, done = pcall(function()
        return require('nvim-treesitter').install(require('config.parsers')):wait(30 * 60 * 1000)
    end)
    if not (ok and done) then
        fail('SyncInstall: installing the treesitter parsers failed' .. (ok and '' or (': ' .. tostring(done))))
    end
end, { desc = 'Install all plugins at the versions of lazy-lock.json and the treesitter parsers' })
