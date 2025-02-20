-- List of diagnostics
require 'loader'.load_plugin({
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
        require('trouble').setup {
            modes = {
                diagnostics = {
                    auto_open = true,
                }
            },
            auto_close = true,
            max_items = 10000,
        }
    end
})
