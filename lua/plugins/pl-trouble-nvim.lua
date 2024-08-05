-- List of diagnostics
require'loader'.load_plugin({
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
        require('trouble').setup {
        }
    end
})
