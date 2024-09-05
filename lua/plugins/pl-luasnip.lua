-- Snippets plugin
require 'loader'.load_plugin({
    'L3MON4D3/LuaSnip',
    after = 'nvim-cmp',
    requires = 'hrsh7th/nvim-cmp',
    config = function()
        require 'luasnip'.config.setup({
            enable_autosnippets = true,
        })
        require 'luasnip.loaders.from_snipmate'.load()
    end
})
require 'loader'.load_plugin({
    'saadparwaiz1/cmp_luasnip',
    after = 'nvim-cmp',
    requires = 'hrsh7th/nvim-cmp',
})
