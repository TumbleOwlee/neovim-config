return {
    {
        "zaldih/themery.nvim",
        lazy = false,
        config = function()
            opts = {
                livePreview = true,
                globalAfter = [[
                    vim.g.opaque = true
                    vim.opt.background = "dark"
                    vim.cmd("highlight Normal guibg=none")
                ]],
            }
            opts.themes = vim.fn.getcompletion("", "color")
            require("themery").setup(opts)
            vim.opt.background = "dark"
            vim.cmd("highlight Normal guibg=none")
        end,
    },
}
