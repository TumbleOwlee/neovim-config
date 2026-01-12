-- Dashboard
return {
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
        opts = {
            theme = "hyper",
            disable_move = true,
            shortcut_type = "letter",
            config = {
                week_header = {
                    enable = true,
                },
                shortcut = {
                    a = { icon = " ", desc = "Find File", key = "f", action = "Telescope find_files" },
                    b = { icon = " ", desc = "Recents", key = "?", action = "Telescope oldfiles" },
                    c = { icon = " ", desc = "Find Word", key = "w", action = "Telescope live_grep" },
                    d = { icon = " ", desc = "New File", key = "n", action = "DashboardNewFile" },
                    e = { icon = " ", desc = "Bookmarks", key = "b", action = "Telescope marks" },
                    f = { icon = "󰸧 ", desc = "Load Last Session", key = "s", action = "SessionLoad" },
                    g = { icon = " ", desc = "Update Plugins", key = "u", action = "PackerUpdate" },
                    i = { icon = "󰗼 ", desc = "Exit", key = "q", action = "exit" },
                },
                footer = { "type  :help<Enter>  or  <F1>  for on-line help" },
            },
        },
    },
}
