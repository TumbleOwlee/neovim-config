return {
    {
        'akinsho/bufferline.nvim',
        event = 'VeryLazy',
        keys = {
            { '<leader>bp', '<cmd>BufferLinePick<CR>', desc = 'Buffer picker' },
            { '<leader>bc', '<cmd>BufferLinePickClose<CR>', desc = 'Pick buffer to close' },
        },
        opts = {
            options = {
                diagnostics = 'nvim_lsp',
            },
        },
    },
}
