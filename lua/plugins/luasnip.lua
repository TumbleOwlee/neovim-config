-- Snippets plugin, snippets from vim-snippets (snipmate format)
return {
    {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        dependencies = { 'honza/vim-snippets' },
        config = function()
            require('luasnip').config.setup({
                enable_autosnippets = true,
            })
            require('luasnip.loaders.from_snipmate').lazy_load()
        end,
    },
}
