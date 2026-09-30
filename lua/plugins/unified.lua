-- Inline unified git diff
return {
    {
        'axkirillov/unified.nvim',
        cmd = 'Unified',
        keys = {
            { '<A-u>u', '<cmd>Unified<CR>', desc = 'Show unified diff' },
            { '<A-u><A-u>', '<cmd>Unified<CR>', desc = 'Show unified diff' },
            { '<A-u>r', '<cmd>Unified reset<CR>', desc = 'Reset unified diff' },
            { '<A-u><A-r>', '<cmd>Unified reset<CR>', desc = 'Reset unified diff' },
        },
        opts = {},
    },
}
