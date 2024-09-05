-- Dims inactive potions of code
require 'loader'.load_plugin({
    'folke/twilight.nvim',
    config = function()
        require 'twilight'.setup {
            dimming = {
                alpha = 0.5,
            },
            context = 30,
        }
    end
})
