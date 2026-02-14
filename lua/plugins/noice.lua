return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            views = {
                cmdline_popup = {
                    border = {
                        style = "single",
                        padding = { 0, 2 },
                    },
                    filter_options = {},
                    win_options = {
                        winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
                    },
                    position = {
                        row = 26,
                        col = "50%",
                    },
                    size = {
                        width = 120,
                        height = "auto",
                    },
                },
                popupmenu = {
                    relative = "editor",
                    position = {
                        row = 29,
                        col = "50%",
                    },
                    size = {
                        width = 120,
                        height = 10,
                    },
                    border = {
                        style = "single",
                        padding = { 0, 1 },
                    },
                    win_options = {
                        winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
                    },

                },
                confirm = {
                    relative = "editor",
                    position = {
                        row = "88%",
                        col = "50%",
                    },
                    size = {
                        width = 60,
                        height = 10,
                    },
                    border = {
                        padding = { 0, 1 },
                    },
                    win_options = {
                        winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
                    },
                },
            },
            popupmenu = {
                backend = 'cmp',
            },
            presets = {
                bottom_search = false,        -- use a classic bottom cmdline for search
                command_palette = false,      -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true,        -- add a border to hover docs and signature help
            },
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
            "hrsh7th/nvim-cmp",
        }
    }
}
