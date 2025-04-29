-- Edit filesystem as files
require 'loader'.load_plugin({
    'stevearc/oil.nvim',
    config = function()
        require('oil').setup {}
    end
})
