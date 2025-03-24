-- spellwarn
vim.opt.spell = true
require 'loader'.load_plugin({
    'ravibrock/spellwarn.nvim',
    config = function()
        require 'spellwarn'.setup()
        require 'spellwarn'.enable()
    end
})
