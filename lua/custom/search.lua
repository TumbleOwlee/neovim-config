-- Highlight search matches while searching: the first key pressed in normal mode after the cursor moved turns the
-- highlight on if it searches, else off
local hl_ns = vim.api.nvim_create_namespace('search')
local hlsearch_group = vim.api.nvim_create_augroup('hlsearch_group', { clear = true })
local search_keys = { '<CR>', 'n', 'N', '*', '#', '?', '/' }

local function manage_hlsearch(char)
    if vim.fn.mode() == 'n' then
        vim.o.hlsearch = vim.list_contains(search_keys, vim.fn.keytrans(char))
    end
    vim.on_key(nil, hl_ns)
end

vim.api.nvim_create_autocmd('CursorMoved', {
    group = hlsearch_group,
    callback = function()
        vim.on_key(manage_hlsearch, hl_ns)
    end,
})

local M = {}

-- Search pattern by folding non-matching lines
function M.search_pattern()
    local pattern = vim.fn.input('Pattern: ')
    if pattern == '' then
        return
    end
    -- Pattern is read from a window variable, so it needs no escaping
    vim.w.search_pattern = pattern
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'getline(v:lnum) !~ w:search_pattern'
end

return M
