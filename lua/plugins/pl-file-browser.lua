-- File explorer
require'loader'.load_plugin({
    "nvim-telescope/telescope-file-browser.nvim",
    requires = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim"
    }
})
