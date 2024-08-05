require'loader'.load_plugin({
    'ray-x/lsp_signature.nvim',
    config = function()
        require'lsp_signature'.setup({})
    end,
})
