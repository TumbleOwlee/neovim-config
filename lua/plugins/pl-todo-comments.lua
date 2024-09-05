-- ToDo listing
require 'loader'.load_plugin({
    'folke/todo-comments.nvim',
    requires = {
        'nvim-lua/plenary.nvim'
    },
    config = function()
        require 'todo-comments'.setup({})
    end,
})
