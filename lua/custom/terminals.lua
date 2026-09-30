-- Keep only one floating Snacks terminal (tmux, Claude Code) visible at a time
local M = {}

-- Visible means the window shows the terminal buffer and is not config-hidden,
-- as claudecode.nvim hides its float with `hide = true` instead of closing it
local function is_visible(term)
    local win = term.win
    return win ~= nil
        and vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_buf(win) == term.buf
        and not vim.api.nvim_win_get_config(win).hide
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
