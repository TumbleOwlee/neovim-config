-- Native LSP behaviour. Server configs: see lua/plugins/nvim-lspconfig.lua and after/lsp/.
--
-- Neovim defaults (buffer-local while a server is attached):
--   K hover, grn rename, gra code action, grr references, gri implementation,
--   grt type definition, gO document symbols, <C-s> signature help (insert),
--   [d / ]d previous/next diagnostic, an / in incremental selection

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
})

vim.lsp.inlay_hint.enable()
-- Inline suggestions (e.g. Copilot via copilot-language-server, sign in with :LspCopilotSignIn)
vim.lsp.inline_completion.enable()

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspKeymaps', { clear = true }),
    callback = function(args)
        local function map(mode, lhs, rhs, desc, expr)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc, expr = expr })
        end
        local function picker(name, opts)
            return function()
                Snacks.picker[name](opts)
            end
        end

        map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
        map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
        map('n', 'gh', picker('lsp_references'), 'Find references')
        map('n', '<C-n>', function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, 'Next diagnostic')
        map('n', '<C-p>', function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, 'Previous diagnostic')
        map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')

        map('n', '<leader>lr', vim.lsp.buf.rename, 'Rename')
        map('n', '<leader>ld', picker('lsp_symbols'), 'Document symbols')
        map('n', '<leader>le', vim.diagnostic.open_float, 'Show line diagnostics')
        map('n', '<leader>lci', picker('lsp_incoming_calls'), 'Incoming calls')
        map('n', '<leader>lco', picker('lsp_outgoing_calls'), 'Outgoing calls')
        map('n', '<leader>lh', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
        end, 'Toggle inlay hints')
        map('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, 'Add folder')
        map('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, 'Remove folder')
        map('n', '<leader>lwl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, 'List folders')

        -- Inline completion (Copilot)
        map('i', '<C-f>', function()
            if not vim.lsp.inline_completion.get() then
                return '<C-f>'
            end
        end, 'Accept inline suggestion', true)
        map('i', '<A-]>', function()
            vim.lsp.inline_completion.select({ count = 1 })
        end, 'Next inline suggestion')
        map('i', '<A-[>', function()
            vim.lsp.inline_completion.select({ count = -1 })
        end, 'Previous inline suggestion')
    end,
})
