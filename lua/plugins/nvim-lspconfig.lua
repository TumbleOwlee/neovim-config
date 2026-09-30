-- LSP: nvim-lspconfig provides the server configs (lsp/*.lua), overrides live in
-- after/lsp/<server>.lua. mason-lspconfig enables every server installed via Mason.

-- Completion capabilities of blink.cmp (same as blink.cmp's get_lsp_capabilities()),
-- declared here so blink doesn't have to load before the first server starts
local completion_capabilities = {
    textDocument = {
        completion = {
            completionItem = {
                labelDetailsSupport = true,
                insertTextModeSupport = { valueSet = { 1 } },
                resolveSupport = {
                    properties = { 'documentation', 'detail', 'additionalTextEdits', 'command', 'data' },
                },
            },
            completionList = {
                itemDefaults = { 'commitCharacters', 'editRange', 'insertTextFormat', 'insertTextMode', 'data' },
            },
            contextSupport = true,
            insertTextMode = 1,
        },
    },
}

return {
    {
        'neovim/nvim-lspconfig',
        lazy = true,
    },
    {
        'mason-org/mason-lspconfig.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'mason-org/mason.nvim',
            'neovim/nvim-lspconfig',
        },
        config = function()
            vim.lsp.config('*', { capabilities = completion_capabilities })
            require('mason-lspconfig').setup({
                automatic_enable = true,
            })
        end,
    },
}
