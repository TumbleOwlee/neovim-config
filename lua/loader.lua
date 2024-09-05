-- Install pckr if missing
local function bootstrap_pckr()
    local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
    if not vim.uv.fs_stat(pckr_path) then
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

local function load_plugin(plugin)
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
