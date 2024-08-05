-- Highlight all word matching word under cursor
require'loader'.load_plugin({
    'xiyaowong/nvim-cursorword',
    config = function()
        --Set custom highlight for nvim-cursorword
        vim.api.nvim_exec( [[ hi! CursorWord gui=underline cterm=undercurl ]], false)
    end
})
