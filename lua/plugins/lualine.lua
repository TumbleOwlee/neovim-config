-- Fancy status line
return {
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            options = {
                theme = 'auto',
                globalstatus = true,
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = {
                    {
                        function()
                            return require('custom.review').status()
                        end,
                        cond = function()
                            return require('custom.review').is_active()
                        end,
                        color = function()
                            return require('custom.review').status_color()
                        end,
                    },
                    'lsp_status',
                    'filetype',
                },
                lualine_y = { 'progress' },
                lualine_z = { 'location' },
            },
        },
    },
}
