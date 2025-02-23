-- Install pckr if missing
local function bootstrap_pckr()
    local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
    local uv = vim.uv or vim.loop
    if not uv.fs_stat(pckr_path) then
        vim.fn.system({
            'git',
            'clone',
            "--filter=blob:none",
            'https://github.com/lewis6991/pckr.nvim',
            pckr_path
        })
    end

    vim.opt.rtp:prepend(pckr_path)
end

local function init()
    -- Enable faster plugin load times
    vim.loader.enable()
    -- Init package manager
    bootstrap_pckr()
end

local registered_plugins = {}

local function install_plugin(plugin)
    local dir = vim.split(type(plugin) == "table" and plugin[1] or plugin, '/')[2]
    local opt = vim.fn.stdpath("data") .. "/site/pack/pckr/opt/".. dir
    local uv = vim.uv or vim.loop
    -- Check out plugin if not present
    if not uv.fs_stat(opt) then
        vim.fn.system({
            'git',
            'clone',
            '--depth',
            '1',
            'https://github.com/' .. (type(plugin) == "table" and plugin[1] or plugin),
            opt
        })
    end
    -- Install dependencies and requirements
    for _, n in pairs{'dependencies', 'requires'} do
        if plugin[n] then
            if type(plugin[n]) == "table" then
                for k, v in pairs(plugin[n]) do
                    install_plugin(v)
                end
            else
                install_plugin(plugin[n])
            end
        end
    end
end

-- Create user command for synchronous install (blocking)
vim.api.nvim_create_user_command(
    "SyncInstall",
    function()
        for _, plugin in pairs(registered_plugins) do
            install_plugin(plugin)
        end
    end,
    { desc = "Install all plugins synchronously!" }
)

local function load_plugin(plugin)
    -- Store plugin info
    table.insert(registered_plugins, plugin)
    -- Initialize plugin using pckr
    require 'pckr'.add { plugin }
end

-- Check if specific plugin is loaded
local function is_plugin_loaded(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if loader and type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

init()

return {
    is_plugin_loaded = is_plugin_loaded,
    load_plugin = load_plugin,
}
