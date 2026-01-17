-- Fancy status line
return {
    {
        "itchyny/lightline.vim",
        dependencies = {
            'vague-theme/vague.nvim',
        },
        config = function()
            vim.g.lightline = {
                colorscheme = "vague",
                active = { left = { { "mode", "paste" }, { "gitbranch", "readonly", "filename", "modified" } } },
                component_function = { gitbranch = "FugitiveHead" },
            }
        end,
    },
}
