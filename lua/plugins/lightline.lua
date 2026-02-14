-- Fancy status line
return {
    {
        "itchyny/lightline.vim",
        config = function()
            vim.g.lightline = {
                active = { left = { { "mode", "paste" }, { "gitbranch", "readonly", "filename", "modified" } } },
                component_function = { gitbranch = "FugitiveHead" },
            }
        end,
    },
}
