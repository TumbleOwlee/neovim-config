-- List of diagnostics
return {
    {
        'folke/trouble.nvim',
        cmd = 'Trouble',
        keys = {
            { '<leader>qt', '<cmd>Trouble diagnostics toggle<CR>', desc = 'Toggle diagnostics list' },
            { '<leader>qb', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'Buffer diagnostics' },
            { '<leader>qq', '<cmd>Trouble qflist toggle<CR>', desc = 'Quickfix list' },
        },
        opts = {
            modes = {
                diagnostics = {
                    auto_open = false,
                },
            },
            auto_close = true,
            max_items = 10000,
        },
    },
}
