require 'loader'.load_plugin({
    'joshdick/onedark.vim',
    config = function()
        vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
            pattern = { '*' },
            command =
            'call onedark#extend_highlight("CursorLineNr", { "fg": { "gui": "#000000"}, "bg": { "gui": "#ad3d2a"} })'
        })

        --Set colorscheme (order is important here)
        vim.o.termguicolors = true
        vim.g.onedark_terminal_italics = 2

        vim.cmd [[silent! colorscheme onedark]]
    end
})
