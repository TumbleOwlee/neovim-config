-- Activate highlight on search pattern
local hl_ns = vim.api.nvim_create_namespace('search')
local hlsearch_group = vim.api.nvim_create_augroup('hlsearch_group', { clear = true })

local function manage_hlsearch(char)
    local key = vim.fn.keytrans(char)
    local keys = { '<CR>', 'n', 'N', '*', '#', '?', '/' }

    if vim.fn.mode() == 'n' then
        if not vim.tbl_contains(keys, key) then
            vim.cmd([[ :set nohlsearch ]])
        elseif vim.tbl_contains(keys, key) then
            vim.cmd([[ :set hlsearch ]])
        end
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
