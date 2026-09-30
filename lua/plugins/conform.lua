-- Formatting: on save the LSP formats first (clangd/rust-analyzer use clang-format/rustfmt),
-- then trailing whitespace is trimmed. Filetypes listed below use their own formatter instead.
return {
    {
        'stevearc/conform.nvim',
        event = 'BufWritePre',
        cmd = 'ConformInfo',
        keys = {
            {
                '<leader>lf',
                function()
                    require('conform').format({ async = true })
                end,
                mode = { 'n', 'x' },
                desc = 'Format buffer',
            },
            { '<leader>lF', '<cmd>FormatToggle<CR>', desc = 'Toggle format on save (buffer)' },
        },
        ---@module 'conform'
        ---@type conform.setupOpts
        opts = {
            formatters_by_ft = {
                lua = { 'stylua', lsp_format = 'never' },
                snakemake = { 'snakefmt' },
                ['*'] = { 'trim_whitespace' },
            },
            default_format_opts = {
                lsp_format = 'first',
            },
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                return { timeout_ms = 3000 }
            end,
        },
        init = function()
            vim.api.nvim_create_user_command('FormatToggle', function(args)
                if args.bang then
                    vim.g.disable_autoformat = not vim.g.disable_autoformat
                    vim.notify('Format on save ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled') .. ' globally')
                else
                    vim.b.disable_autoformat = not vim.b.disable_autoformat
                    vim.notify('Format on save ' .. (vim.b.disable_autoformat and 'disabled' or 'enabled') .. ' for buffer')
                end
            end, { desc = 'Toggle format on save (! for global)', bang = true })
        end,
    },
}
