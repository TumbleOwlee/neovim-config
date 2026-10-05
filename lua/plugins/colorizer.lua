-- Highlight color codes in their color
return {
    {
        'catgoose/nvim-colorizer.lua',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            filetypes = { '*', '!snacks_terminal' },
        },
    },
}
