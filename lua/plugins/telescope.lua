-- UI to select things (files, grep results, open buffers...)
return {
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            { "nvim-lua/popup.nvim" },
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope-file-browser.nvim" },
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-u>"] = false,
                            ["<C-d>"] = false,
                        },
                    },
                },
            })
            require("telescope").load_extension("file_browser")
        end,
    },
}
