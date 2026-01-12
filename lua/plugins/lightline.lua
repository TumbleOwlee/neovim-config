-- Fancy status line
return {
    {
        "itchyny/lightline.vim",
        dependencies = { "joshdick/onedark.vim" },
        config = function()
            vim.g.lightline = {
                colorscheme = "onedark",
                active = { left = { { "mode", "paste" }, { "gitbranch", "readonly", "filename", "modified" } } },
                component_function = { gitbranch = "FugitiveHead" },
            }
        end,
    },
}
