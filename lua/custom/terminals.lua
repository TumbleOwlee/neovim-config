-- Keep only one floating terminal (tmux, the sidekick CLI tools) visible at a time
local M = {}

-- Visible means the window shows the terminal buffer and is not config-hidden
local function is_visible(term)
    local win = term.win
    return win ~= nil
        and vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_buf(win) == term.buf
        and not vim.api.nvim_win_get_config(win).hide
end

-- Snacks tells terminals apart by their directory, which is the window's by default. The tmux terminal runs in the
-- directory nvim was started in, so a tab with a directory of its own (a worktree under review) finds the same one
local function tmux_opts(opts)
    return vim.tbl_extend('force', { cwd = vim.fn.getcwd(-1, -1) }, opts or {})
end

-- The tmux terminal, nil if it was not started yet
function M.tmux()
    return Snacks.terminal.get('tmux', tmux_opts({ create = false }))
end

-- Toggle the tmux terminal, hiding the other terminals when it is shown
function M.toggle_tmux()
    local tmux = M.tmux()
    M.hide_others(tmux)
    M.ai_to_current_tab()
    -- Shown in another tab, it is moved here rather than hidden there
    local win = tmux and tmux:valid() and tmux.win
    if win and vim.api.nvim_win_get_tabpage(win) ~= vim.api.nvim_get_current_tabpage() then
        tmux:hide()
        tmux:show()
        return
    end
    Snacks.terminal.toggle(
        'tmux',
        tmux_opts({ win = { position = 'float', width = 0.9, height = 0.9, border = 'rounded' } })
    )
end

-- A sidekick float stays in the tab it was opened in, and toggling it from another tab would close it there. The
-- windows of the CLI tools in other tabs, and of the other tools in this one, are closed (the tools keep running in
-- their buffers), so `name` opens in the current tab without covering another
function M.ai_to_current_tab(name)
    local tab = vim.api.nvim_get_current_tabpage()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local tool = vim.b[vim.api.nvim_win_get_buf(win)].sidekick_cli
        if tool and (vim.api.nvim_win_get_tabpage(win) ~= tab or tool.name ~= name) then
            pcall(vim.api.nvim_win_close, win, true)
        end
    end
end

-- Hide a Snacks terminal (snacks.win) if it is visible
function M.hide(term)
    if term and is_visible(term) then
        term:hide()
    end
end

-- Hide every visible Snacks terminal except `keep` (a snacks.win)
function M.hide_others(keep)
    for _, term in ipairs(Snacks.terminal.list()) do
        if term ~= keep then
            M.hide(term)
        end
    end
end

return M
