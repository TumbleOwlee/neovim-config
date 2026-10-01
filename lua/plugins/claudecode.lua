-- Claude Code integration (IDE protocol: diffs, selections, @-mentions)
return {
    {
        'coder/claudecode.nvim',
        dependencies = { 'folke/snacks.nvim' },
        cmd = { 'ClaudeCode', 'ClaudeCodeFocus', 'ClaudeCodeStart', 'ClaudeCodeStatus' },
        keys = {
            {
                '<A-,>',
                function()
                    require('custom.terminals').hide(Snacks.terminal.get('tmux', { create = false }))
                    vim.cmd('ClaudeCode')
                end,
                mode = { 'n', 't' },
                desc = 'Toggle Claude Code',
            },
            { '<leader>ac', '<cmd>ClaudeCode<CR>', desc = 'Toggle Claude Code' },
            { '<leader>af', '<cmd>ClaudeCodeFocus<CR>', desc = 'Focus Claude Code' },
            { '<leader>ar', '<cmd>ClaudeCode --resume<CR>', desc = 'Resume conversation' },
            { '<leader>aC', '<cmd>ClaudeCode --continue<CR>', desc = 'Continue last conversation' },
            { '<leader>am', '<cmd>ClaudeCodeSelectModel<CR>', desc = 'Select model' },
            { '<leader>ab', '<cmd>ClaudeCodeAdd %<CR>', desc = 'Add current buffer' },
            { '<leader>as', '<cmd>ClaudeCodeSend<CR>', mode = 'x', desc = 'Send selection' },
            { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<CR>', desc = 'Accept diff' },
            { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<CR>', desc = 'Deny diff' },
        },
        opts = {
            focus_after_send = true,
            terminal = {
                provider = 'snacks',
                snacks_win_opts = {
                    position = 'float',
                    width = 0.9,
                    height = 0.9,
                    border = 'single',
                },
            },
        },
    },
}
