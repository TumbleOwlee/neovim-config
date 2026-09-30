-- Edit filesystem as files. Not lazy, so it can open directories given on the command line.
return {
    {
        'stevearc/oil.nvim',
        lazy = false,
        keys = {
            { '<leader>fb', '<cmd>Oil<CR>', desc = 'File browser (directory of current file)' },
        },
        opts = {},
    },
}
