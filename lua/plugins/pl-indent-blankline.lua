-- Add indentation guides even on blank lines
require 'loader'.load_plugin({
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        vim.opt.list = true
        vim.opt.listchars:append("eol:↴")
        require("ibl").setup {
            indent = {
                char = '┊',
                highlight = 'LineNr',
            },
            scope = {
                show_end = true,
            },
            exclude = {
                filetypes = { 'help', 'packer', 'dashboard' },
            },
            --    buftype_exclude = { 'terminal', 'nofile' },
            whitespace = {
                highlight = highlight,
                remove_blankline_trail = true,
            }
        }
    end
})
