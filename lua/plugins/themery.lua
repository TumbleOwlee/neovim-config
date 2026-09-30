-- Colorscheme switcher with live preview
return {
    {
        'zaldih/themery.nvim',
        cmd = 'Themery',
        config = function()
            -- Colorschemes of lazy-loaded plugins aren't on the runtimepath yet
            local themes = {
                'vague',
                'tokyonight-night',
                'tokyonight-storm',
                'tokyonight-moon',
                'tokyonight-day',
                'cyberdream',
                'catppuccin-mocha',
                'catppuccin-macchiato',
                'catppuccin-frappe',
                'catppuccin-latte',
                'rose-pine',
                'rose-pine-moon',
                'rose-pine-dawn',
                'gruvbox',
                'kanagawa-wave',
                'kanagawa-dragon',
                'kanagawa-lotus',
            }
            for _, name in ipairs(vim.fn.getcompletion('', 'color')) do
                if not vim.tbl_contains(themes, name) then
                    table.insert(themes, name)
                end
            end
            require('themery').setup({
                themes = themes,
                livePreview = true,
                globalAfter = [[
                    vim.opt.background = "dark"
                    vim.cmd("highlight Normal guibg=none")
                ]],
            })
        end,
    },
}
