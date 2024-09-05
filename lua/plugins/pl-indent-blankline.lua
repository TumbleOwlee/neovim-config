-- Add indentation guides even on blank lines
require 'loader'.load_plugin({
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        vim.opt.list = true
        vim.opt.listchars:append("eol:↴")

        -- highlight for indentation
        local highlight = {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        }

        -- create the highlight groups in the highlight setup hook, so they are reset
        -- every time the colorscheme changes
        require 'ibl.hooks'.register(require 'ibl.hooks'.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
            vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
            vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
            vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
            vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
            vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
            vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        end)

        require("ibl").setup {
            indent = {
                char = '┊',
                tab_char = '┊',
                highlight = highlight,
            },
            scope = {
                enabled = true,
                show_end = true,
            },
            exclude = {
                filetypes = { 'help', 'packer', 'dashboard' },
            },
            whitespace = {
                highlight = { 'LineNr' },
                remove_blankline_trail = true,
            }
        }
    end
})
