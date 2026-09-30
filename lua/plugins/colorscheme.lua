-- vague is the default colorscheme, the others are loaded on demand (e.g. via :Themery)
return {
    {
        'vague-theme/vague.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('vague').setup({
                transparent = true,
            })
            vim.cmd.colorscheme('vague')
        end,
    },
    {
        'folke/tokyonight.nvim',
        lazy = true,
        opts = {},
    },
    {
        'scottmckendry/cyberdream.nvim',
        lazy = true,
        opts = { transparent = true },
    },
    {
        'catppuccin/nvim',
        lazy = true,
        name = 'catppuccin',
    },
    {
        'rose-pine/neovim',
        lazy = true,
        name = 'rose-pine',
    },
    {
        'ellisonleao/gruvbox.nvim',
        lazy = true,
        opts = {
            terminal_colors = true,
            transparent_mode = false,
        },
    },
    {
        'rebelot/kanagawa.nvim',
        lazy = true,
        opts = {
            compile = true,
        },
    },
}
