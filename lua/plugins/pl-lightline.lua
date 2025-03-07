-- Fancy status line
require 'loader'.load_plugin({
    'itchyny/lightline.vim',
    config = function()
        --Set statusbar
        vim.g.lightline = {
            --colorscheme = 'kanagawa',
            active = { left = { { 'mode', 'paste' }, { 'gitbranch', 'readonly', 'filename', 'modified' } } },
            component_function = { gitbranch = 'FugitiveHead' },
        }
    end
})
