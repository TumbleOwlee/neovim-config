-- Define placeholders and how to retrieve their values
-- and replace it automatically on open.
--
-- vim.g.template_context_map = { ['<lua pattern on buffer name>'] = { ['<placeholder>'] = '<value>' } }

-- Template placeholder replacement
vim.api.nvim_create_autocmd('BufRead', {
    group = vim.api.nvim_create_augroup('Templating', { clear = true }),
    callback = function(args)
        local buf = args.buf
        local context = vim.g.template_context_map
        if not context or not vim.bo[buf].modifiable then
            return
        end

        local buf_name = vim.api.nvim_buf_get_name(buf)
        local config
        for pattern, cfg in pairs(context) do
            if buf_name:match(pattern) then
                config = cfg
                break
            end
        end
        if not config or vim.tbl_isempty(config) then
            return
        end

        -- Only touch lines that actually contain a placeholder
        local first_line
        for nr, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, true)) do
            local new = line
            for key, value in pairs(config) do
                new = new:gsub(vim.pesc(key), (tostring(value):gsub('%%', '%%%%')))
            end
            if new ~= line then
                vim.api.nvim_buf_set_lines(buf, nr - 1, nr, true, { new })
            end
            first_line = first_line or new
        end

        if first_line and buf == vim.api.nvim_get_current_buf() then
            vim.api.nvim_win_set_cursor(0, { 1, #first_line })
        end
    end,
})
