-- LSP extension
require'loader'.load_plugin({
    'nvimdev/lspsaga.nvim',
    after ='nvim-lspconfig',
    config = function()
        require'lspsaga'.setup({})
    end,
})
