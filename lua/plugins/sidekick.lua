-- AI CLI tools (Claude Code, Copilot CLI) in a floating terminal, and Copilot next edit suggestions (needs the
-- copilot LSP, see config/lsp.lua)

local function cli(fn, opts)
    return function()
        require('sidekick.cli')[fn](opts)
    end
end

-- Toggle the float of a CLI tool in the current tab, with the tmux float hidden
local function toggle(name)
    return function()
        local terminals = require('custom.terminals')
        terminals.hide(terminals.tmux())
        terminals.ai_to_current_tab(name)
        require('sidekick.cli').toggle({ name = name, focus = true })
    end
end

return {
    {
        'folke/sidekick.nvim',
        event = 'LspAttach',
        keys = {
            -- Like <C-f> accepting inline suggestions in insert mode, falls back to scrolling a page down
            {
                '<C-f>',
                function()
                    if not require('sidekick').nes_jump_or_apply() then
                        return '<C-f>'
                    end
                end,
                expr = true,
                desc = 'Jump to or apply next edit suggestion',
            },
            { '<A-,>', toggle('claude'), mode = { 'n', 't' }, desc = 'Toggle Claude Code' },
            { '<A-e>', toggle('copilot'), mode = { 'n', 't' }, desc = 'Toggle Copilot CLI' },
            { '<leader>ks', cli('select'), desc = 'Select CLI tool' },
            { '<leader>kd', cli('close'), desc = 'Detach CLI session' },
            { '<leader>kt', cli('send', { msg = '{this}' }), mode = { 'n', 'x' }, desc = 'Send this' },
            { '<leader>kf', cli('send', { msg = '{file}' }), desc = 'Send file' },
            { '<leader>kv', cli('send', { msg = '{selection}' }), mode = 'x', desc = 'Send selection' },
            { '<leader>kp', cli('prompt'), mode = { 'n', 'x' }, desc = 'Select prompt' },
        },
        opts = {
            cli = {
                win = {
                    layout = 'float',
                    float = { width = 0.9, height = 0.9, border = 'single' },
                },
                tools = {
                    -- Claude Code runs in nvim's terminal, not in tmux, so it doesn't get the tmux variables of an
                    -- nvim started inside tmux
                    claude = { env = { TMUX = false, TMUX_PANE = false } },
                },
            },
        },
        config = function(_, opts)
            -- Sessions start in the window's directory. They run in the directory nvim was started in instead, also
            -- when started from a worktree's tab, so the paths of a review are relative to it
            local session = require('sidekick.cli.session')
            local cwd = session.cwd
            session.cwd = function(o)
                return cwd(vim.tbl_extend('keep', o or {}, { cwd = vim.fn.getcwd(-1, -1) }))
            end
            require('sidekick').setup(opts)
        end,
    },
}
