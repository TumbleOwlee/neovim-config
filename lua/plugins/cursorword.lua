-- Highlight all word matching word under cursor
return {
    {
        'xiyaowong/nvim-cursorword',
        event = { 'BufReadPost', 'BufNewFile' },
        config = function()
            -- Custom highlight for nvim-cursorword, reapplied on colorscheme change
            local function set_hl()
                vim.api.nvim_set_hl(0, 'CursorWord', { underline = true })
            end
            set_hl()
            vim.api.nvim_create_autocmd('ColorScheme', {
                group = vim.api.nvim_create_augroup('CursorWordHl', { clear = true }),
                callback = set_hl,
            })
        end,
    },
}
