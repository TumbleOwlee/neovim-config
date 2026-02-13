return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({})
            vim.cmd.colorscheme('tokyonight')
        end,
    },
    {
        "vague-theme/vague.nvim",
        priority = 1000,
        config = function()
            require("vague").setup({
                transparent = true,
            })
            vim.cmd.colorscheme('vague')
        end,
    },
    {
        'scottmckendry/cyberdream.nvim',
        enabled = not vim.g.opaque,
        priority = 1000,
        config = function()
            require('cyberdream').setup({ transparent = true })
            vim.cmd.colorscheme('cyberdream')
        end,
    },
    { 
        "catppuccin/nvim", 
        name = "catppuccin", 
        priority = 1000 
    },
    { 
        "rose-pine/neovim", 
        name = "rose-pine", 
        priority = 1000 
    }
}
