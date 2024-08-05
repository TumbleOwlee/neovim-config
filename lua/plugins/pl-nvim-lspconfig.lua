-- Collection of configurations for built-in LSP client
require'loader'.load_plugin({
    'neovim/nvim-lspconfig',
    after = {
        { 'cmp_nvim_lsp' },
        { 'lsp_signature' },
        { 'mason' },
        { 'mason-registry' },
        { 'mason-lspconfig' },
    },
    requires = {
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'ray-x/lsp_signature.nvim' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
    },
    config = function()
        vim.api.nvim_create_autocmd({"BufWritePost"}, {
            pattern = {"*.rs"},
            callback = function()
                vim.lsp.buf.format({timeout_ms = 3000})
            end
        })

        local nvim_lsp = require 'lspconfig'
        local on_attach = function(_, bufnr)
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
            vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
            require'lsp_signature'.on_attach()
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

        -- Lua LSP
        local settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = {
                        '?.lua',
                        '?/init.lua',
                        vim.fn.expand'~/.luarocks/share/lua/5.3/?.lua',
                        vim.fn.expand'~/.luarocks/share/lua/5.3/?/init.lua',
                        '/usr/share/5.3/?.lua',
                        '/usr/share/lua/5.3/?/init.lua'
                    }
                },
                diagnostics = {
                    globals = {'vim'},
                },
                workspace = {
                    library = {
                        vim.api.nvim_get_runtime_file("", true),
                        vim.fn.expand'~/.luarocks/share/lua/5.3',
                        '/usr/share/lua/5.3'
                    }
                },
                telemetry = {
                    enable = false,
                },
            },
            pylsp = {
                plugins = {
                    pycodestyle = {
                        ignore = {'w391', 'E501'},
                        maxLineLength = 120,
                    }
                }
            },
            ['rust-analyzer'] = {
                checkOnSave = true,
                check = {
                    enable = true,
                    command = "clippy",
                    features = "all"
                }
            }
        }

        local mason = require'mason'
        local mason_registry = require'mason-registry'
        local mason_lspconfig = require'mason-lspconfig'

        mason_lspconfig.setup {
            automatic_installation = true,
        }

        mason.setup({
            ui = {
                icons = {
                    server_installed = "✓",
                    server_pending = "➜",
                    server_uninstalled = "✗"
                }
            }
        })

        local name_mappings = {
            python_lsp_server = 'pylsp',
            lua_language_server = 'lua_ls',
            r_languageserver = 'r_language_server'
        }

        for _, name in ipairs(mason_registry.get_installed_package_names()) do
            name = name:gsub("-", "_")
            if name_mappings[name] ~= nil then
                name = name_mappings[name]
            end
            local cmd = nvim_lsp[name].cmd
            nvim_lsp[name].setup {
                cmd = cmd,
                on_attach = on_attach,
                capabilities = capabilities,
                settings = settings,
            }
        end
    end
})
