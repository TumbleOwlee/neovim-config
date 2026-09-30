-- ToDo listing
return {
    {
        'folke/todo-comments.nvim',
        event = { 'BufReadPost', 'BufNewFile' },
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        keys = {
            {
                '<leader>fd',
                function()
                    Snacks.picker.todo_comments()
                end,
                desc = 'ToDo list',
            },
        },
        opts = {},
    },
}
