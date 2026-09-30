return {
    {
        'lewis6991/gitsigns.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        keys = {
            { '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>', desc = 'Toggle line blame' },
            { '<leader>gp', '<cmd>Gitsigns preview_hunk<CR>', desc = 'Preview hunk' },
            { '<leader>gr', '<cmd>Gitsigns reset_hunk<CR>', desc = 'Reset hunk' },
            { '<leader>gs', '<cmd>Gitsigns stage_hunk<CR>', desc = 'Stage hunk' },
            { ']h', '<cmd>Gitsigns nav_hunk next<CR>', desc = 'Next git hunk' },
            { '[h', '<cmd>Gitsigns nav_hunk prev<CR>', desc = 'Previous git hunk' },
        },
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
                untracked = { text = '|' },
            },
        },
    },
}
