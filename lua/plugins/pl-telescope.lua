-- UI to select things (files, grep results, open buffers...)
require 'loader'.load_plugin({
    'nvim-telescope/telescope.nvim',
    requires = {
        { 'nvim-lua/popup.nvim' },
        { 'nvim-lua/plenary.nvim' },
        { 'nvim-telescope/telescope-file-browser.nvim' },
    },
    config = function()
        require('telescope').setup {
            defaults = {
                mappings = {
                    i = {
                        ['<C-u>'] = false,
                        ['<C-d>'] = false,
                    },
                },
            },
        }
        require 'telescope'.load_extension 'file_browser'
    end
})

-- telescope setup for file explorer
