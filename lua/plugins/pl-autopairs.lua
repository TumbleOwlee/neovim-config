-- Automatic closing brackets
require 'loader'.load_plugin({
    'windwp/nvim-autopairs',
    config = function()
        require('nvim-autopairs').setup {}
    end
})
