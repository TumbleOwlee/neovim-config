-- Define placeholders and how to retrieve their values
-- and replace it automatically on open

-- Template placeholder replacement
vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = { "*" },
    callback = function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local context = vim.g.template_context_map or {}

        local config = {}
        for pattern, cfg in pairs(context) do
            if string.match(buf_name, pattern) then
                config = cfg
                break
            end
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        for nr, line in ipairs(lines) do
            for key, value in pairs(config) do
                line = line:gsub(key, value)
            end
            vim.api.nvim_buf_set_lines(0, nr - 1, nr, true, { line })
        end

        if lines[1] then
            vim.api.nvim_win_set_cursor(0, { 1, lines[1]:len() })
        end
    end,
})
