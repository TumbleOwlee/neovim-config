-- Autocompletion
local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

return {
    {
        'saghen/blink.cmp',
        version = '1.*',
        -- Fetch the prebuilt fuzzy matcher at install time, so offline packages contain it
        -- A failed download fails the build, so a package is not made without it
        build = function()
            local done, err = false, nil
            require('blink.cmp.fuzzy.download').ensure_downloaded(function(download_err)
                done, err = true, download_err
            end)
            if not vim.wait(120000, function()
                return done
            end) then
                error('Downloading the blink.cmp fuzzy matcher timed out')
            end
            if err then
                error('Downloading the blink.cmp fuzzy matcher failed: ' .. tostring(err))
            end
            -- Some failures are only notified, so the library has to load
            local ok, load_err = pcall(require, 'blink.cmp.fuzzy.rust')
            if not ok then
                error('The blink.cmp fuzzy matcher cannot be loaded: ' .. tostring(load_err))
            end
        end,
        event = { 'InsertEnter', 'CmdlineEnter' },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                preset = 'none',
                ['<Tab>'] = {
                    function(cmp)
                        if cmp.is_visible() then
                            return cmp.select_next()
                        elseif cmp.snippet_active({ direction = 1 }) then
                            return cmp.snippet_forward()
                        end
                        local luasnip = require('luasnip')
                        if luasnip.expandable() then
                            vim.schedule(luasnip.expand)
                            return true
                        elseif has_words_before() then
                            return cmp.show()
                        end
                    end,
                    'fallback',
                },
                ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
                -- Confirm the selected item, or the first one if none is selected
                ['<S-CR>'] = { 'select_and_accept', 'fallback' },
                ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                ['<C-e>'] = { 'hide', 'fallback' },
                ['<C-x>'] = {
                    function()
                        local luasnip = require('luasnip')
                        if luasnip.expandable() then
                            vim.schedule(luasnip.expand)
                            return true
                        end
                    end,
                    'fallback',
                },
                ['<C-n>'] = { 'snippet_forward', 'fallback' },
                ['<C-p>'] = { 'snippet_backward', 'fallback' },
            },
            snippets = { preset = 'luasnip' },
            completion = {
                list = { selection = { preselect = false, auto_insert = true } },
                documentation = { auto_show = true },
            },
            sources = {
                default = { 'lsp', 'snippets', 'path', 'buffer' },
            },
            cmdline = {
                keymap = { preset = 'cmdline' },
                completion = { menu = { auto_show = true } },
            },
            -- Signature help is shown by noice
            signature = { enabled = false },
            fuzzy = { implementation = 'prefer_rust_with_warning' },
        },
    },
}
