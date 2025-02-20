-- Debug adapter protocol
require 'loader'.load_plugin({
    'mfussenegger/nvim-dap',
    config = function()
        local function find_executable(name, dir)
            local d = dir or "/usr/bin/"
            local pfile = io.popen('ls -a "' .. d .. '"')
            if pfile then
                for n in pfile:lines() do
                    if string.find(n, name, 0, true) then
                        pfile:close()
                        return d .. n
                    end
                end
                pfile:close()
            end
            return nil
        end

        local dap = require('dap')
        dap.adapters.lldb = {
            type = 'executable',
            command = find_executable('lldb-dap') or find_executable('lldb-vscode') or 'lldb-vscode',
            name = "lldb"
        }

        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "lldb",
                request = "launch",
                program = function()
                    vim.g.dap_target = vim.fn.input('Path to executable: ',
                        vim.g.dap_target or vim.g.dap_cwd or (vim.fn.getcwd() .. '/'),
                        'file')
                    return vim.g.dap_target
                end,
                cwd = function()
                    vim.g.dap_cwd = vim.fn.input('Working directory: ', vim.g.dap_cwd or vim.fn.getcwd() .. '/', 'file')
                    return vim.g.dap_cwd
                end,
                stopOnEntry = false,
                args = function()
                    vim.g.dap_args = vim.fn.input('Arguments: ', vim.g.dap_args or '')
                    return vim.split(vim.g.dap_args, " +")
                end,
                runInTerminal = false,
            }
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp
        dap.configurations.lua = {
            {
                type = 'nlua',
                request = 'attach',
                name = "Attach to running Neovim instance",
                host = function()
                    local value = vim.fn.input('Host [127.0.0.1]: ')
                    if value ~= "" then
                        return value
                    end
                    return '127.0.0.1'
                end,
                port = function()
                    local val = tonumber(vim.fn.input('Port: '))
                    assert(val, "Please provide a port number")
                    return val
                end,
            }
        }
        dap.adapters.nlua = function(callback, config)
            callback({ type = 'server', host = config.host, port = config.port })
        end
    end
})

-- Neovim DAP support
require 'loader'.load_plugin({
    'jbyuki/one-small-step-for-vimkind',
    requires = {
        'mfussenegger/nvim-dap'
    }
})
