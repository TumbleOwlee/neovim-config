-- Keybindings with interactive popup for reminder
return {
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        dependencies = {
            'nvim-mini/mini.icons',
            'nvim-tree/nvim-web-devicons',
        },
        opts = {
            spec = {
                -- Groups
                {
                    { '<leader>a', group = 'Claude Code' },
                    { '<leader>b', group = 'Buffer' },
                    { '<leader>C', group = 'Copilot Chat' },
                    { '<leader>c', group = 'Code' },
                    { '<leader>d', group = 'Debug' },
                    { '<leader>f', group = 'Find' },
                    { '<leader>g', group = 'Git' },
                    { '<leader>l', group = 'LSP' },
                    { '<leader>lc', group = 'Call hierarchy' },
                    { '<leader>lw', group = 'Workspace' },
                    { '<leader>n', group = 'Annotation / Notification' },
                    { '<leader>o', group = 'Overseer' },
                    { '<leader>p', group = 'Neovim' },
                    { '<leader>q', group = 'Quickfix / Diagnostics' },
                    { '<leader>r', group = 'Review' },
                    { '<leader>s', group = 'Session' },
                    { '<leader><Tab>', group = 'Tabs' },
                    { '<A-u>', group = 'Unified diff' },
                },
            },
        },
    },
}
