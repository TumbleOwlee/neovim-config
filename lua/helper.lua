local M = {}

-- Search pattern by folding non-matching lines
function M.search_pattern()
    local pattern = vim.fn.input('Pattern: ')
    vim.o.foldmethod = 'expr'
    vim.o.foldexpr = "getline(v:lnum)!~'" .. pattern .. "'"
end

return M
