vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require 'loader'.load_plugin({
    'nvim-tree/nvim-tree.lua',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require 'nvim-tree'.setup({
            view = {
                width = 45,
            },
        })
    end,
})
