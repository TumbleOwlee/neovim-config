-- Copilot
vim.g.copilot_enabled = false

require 'loader'.load_plugin({
    'github/copilot.vim',
    config = function()
        vim.api.nvim_set_keymap('i', '<C-f>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
        vim.g.copilot_no_tab_map = true
    end,
})
