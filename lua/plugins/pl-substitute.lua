-- Substitute operator
require 'loader'.load_plugin({
    'gbprod/substitute.nvim',
    config = function()
        require('substitute').setup {}

        -- Add keybindings
        vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
        vim.keymap.set("n", "ss", require('substitute').line, { noremap = true })
        vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
        vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })
    end
})
