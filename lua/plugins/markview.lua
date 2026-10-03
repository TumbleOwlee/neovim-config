return {
    {
        'OXY2DEV/markview.nvim',
        dependencies = {
            'nvim-mini/mini.icons',
        },
        config = function()
            local opts = {
                preview = {
                    modes = { 'n', 'i', 'no', 'c' },
                    icon_provider = 'mini',
                    hybrid_modes = { 'i', 'n' },
                    callbacks = {
                        -- Called with the list of windows showing the buffer
                        on_enable = function(_, wins)
                            for _, win in ipairs(wins) do
                                vim.wo[win].conceallevel = 2
                                vim.wo[win].concealcursor = 'nc'
                            end
                        end,
                    },
                },
                markdown_inline = {
                    checkboxes = {
                        enable = true,
                        checked = {
                            text = '󰡖',
                            hl = 'MarkviewCheckboxChecked',
                        },
                        unchecked = {
                            text = '',
                            hl = 'MarkviewCheckboxUnchecked',
                        },
                    },
                },
                markdown = {
                    headings = {
                        heading_1 = { hl = 'MarkViewHeading1', icon = '󰓛 ' },
                        heading_2 = { hl = 'MarkViewHeading2', icon = '󰓛 󰓛 ' },
                        heading_3 = { hl = 'MarkViewHeading3', icon = '󰓛 󰓛 󰓛 ' },
                        heading_4 = { hl = 'MarkViewHeading4', icon = '󰓛 󰓛 󰓛 󰓛 ' },
                        heading_5 = { hl = 'MarkViewHeading5', icon = '󰓛 󰓛 󰓛 󰓛 󰓛 ' },
                        heading_6 = { hl = 'MarkViewHeading6', icon = '󰓛 󰓛 󰓛 󰓛 󰓛 󰓛 ' },
                    },
                },
            }
            require('markview').setup(opts)
        end,
        priority = 101,
        lazy = false,
    },
}
