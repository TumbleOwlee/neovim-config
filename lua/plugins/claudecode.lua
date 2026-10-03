-- Claude Code integration (IDE protocol: diffs, selections, @-mentions)

-- Run a command that shows the Claude Code float (also sending to it shows it) in the current tab, with the tmux
-- float hidden
local function show(cmd)
    return function()
        local terminals = require('custom.terminals')
        terminals.hide(terminals.tmux())
        terminals.claude_to_current_tab()
        vim.cmd(cmd)
    end
end

return {
    {
        'coder/claudecode.nvim',
        dependencies = { 'folke/snacks.nvim' },
        cmd = { 'ClaudeCode', 'ClaudeCodeFocus', 'ClaudeCodeStart', 'ClaudeCodeStatus' },
        keys = {
            { '<A-,>', show('ClaudeCode'), mode = { 'n', 't' }, desc = 'Toggle Claude Code' },
            { '<leader>ac', show('ClaudeCode'), desc = 'Toggle Claude Code' },
            { '<leader>af', show('ClaudeCodeFocus'), desc = 'Focus Claude Code' },
            { '<leader>ar', show('ClaudeCode --resume'), desc = 'Resume conversation' },
            { '<leader>aC', show('ClaudeCode --continue'), desc = 'Continue last conversation' },
            { '<leader>am', '<cmd>ClaudeCodeSelectModel<CR>', desc = 'Select model' },
            { '<leader>ab', show('ClaudeCodeAdd %'), desc = 'Add current buffer' },
            { '<leader>as', show('ClaudeCodeSend'), mode = 'x', desc = 'Send selection' },
            { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<CR>', desc = 'Accept diff' },
            { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<CR>', desc = 'Deny diff' },
        },
        opts = {
            focus_after_send = true,
            terminal = {
                provider = 'snacks',
                -- Claude Code runs in the directory nvim was started in, also when started from a worktree's tab
                cwd_provider = function()
                    return vim.fn.getcwd(-1, -1)
                end,
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
