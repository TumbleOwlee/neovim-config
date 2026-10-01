-- Debug adapter protocol

-- Currently open centered float (frames/scopes)
local float

-- Wrap a dap action: close an open float first and optionally require an active session
local function dap(action, needs_session)
    return function()
        if float then
            float.close()
            float = nil
        end
        local d = require('dap')
        if needs_session and not d.session() then
            return
        end
        action(d)
    end
end

local function show(widget)
    return dap(function()
        local widgets = require('dap.ui.widgets')
        float = widgets.centered_float(widgets[widget])
    end, true)
end

return {
    {
        'mfussenegger/nvim-dap',
        keys = {
            -- Quick access without leader
            { '<A-b>', dap(function(d)
                d.toggle_breakpoint()
            end), desc = 'Debug: toggle breakpoint' },
            { '<A-r>', dap(function(d)
                if not d.session() then
                    d.continue()
                end
            end), desc = 'Debug: start session' },
            { '<A-c>', dap(function(d)
                d.continue()
            end, true), desc = 'Debug: continue' },
            { '<A-n>', dap(function(d)
                d.step_over()
            end, true), desc = 'Debug: step over' },
            { '<A-s>', dap(function(d)
                d.step_into()
            end, true), desc = 'Debug: step into' },
            { '<A-f>', show('frames'), desc = 'Debug: show frames' },
            { '<A-l>', show('scopes'), desc = 'Debug: show locals' },
            { '<A-p>', dap(function(d)
                d.repl.toggle()
            end), desc = 'Debug: toggle REPL' },
            -- Full set under <leader>d
            { '<leader>db', dap(function(d)
                d.toggle_breakpoint()
            end), desc = 'Toggle breakpoint' },
            { '<leader>dB', dap(function(d)
                d.clear_breakpoints()
            end), desc = 'Clear all breakpoints' },
            { '<leader>dc', dap(function(d)
                d.continue()
            end), desc = 'Continue / start' },
            {
                '<leader>dr',
                dap(function(d)
                    if d.session() then
                        d.terminate()
                    end
                    d.continue()
                end),
                desc = 'Restart session',
            },
            { '<leader>dt', dap(function(d)
                d.terminate()
            end, true), desc = 'Terminate' },
            { '<leader>dn', dap(function(d)
                d.step_over()
            end, true), desc = 'Step over' },
            { '<leader>di', dap(function(d)
                d.step_into()
            end, true), desc = 'Step into' },
            { '<leader>do', dap(function(d)
                d.step_out()
            end, true), desc = 'Step out' },
            { '<leader>dk', dap(function(d)
                d.step_back()
            end, true), desc = 'Step back' },
            { '<leader>dK', dap(function(d)
                d.reverse_continue()
            end, true), desc = 'Reverse continue' },
            { '<leader>dg', dap(function(d)
                d.run_to_cursor()
            end), desc = 'Run to cursor' },
            { '<leader>dp', dap(function(d)
                d.pause()
            end, true), desc = 'Pause thread' },
            { '<leader>du', dap(function(d)
                d.up()
            end, true), desc = 'Go up in stacktrace' },
            { '<leader>dd', dap(function(d)
                d.down()
            end, true), desc = 'Go down in stacktrace' },
            { '<leader>df', show('frames'), desc = 'Show frames' },
            { '<leader>ds', show('scopes'), desc = 'Show scopes' },
            { '<leader>dR', dap(function(d)
                d.repl.toggle()
            end), desc = 'Toggle REPL console' },
            {
                '<leader>dv',
                dap(function()
                    require('dap.ui.widgets').hover()
                end, true),
                desc = 'Show value under cursor',
            },
        },
        config = function()
            local function find_executable(name, dir)
                local d = dir or '/usr/bin/'
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
                name = 'lldb',
            }

            dap.configurations.cpp = {
                {
                    name = 'Launch',
                    type = 'lldb',
                    request = 'launch',
                    program = function()
                        vim.g.dap_target = vim.fn.input(
                            'Path to executable: ',
                            vim.g.dap_target or vim.g.dap_cwd or (vim.fn.getcwd() .. '/'),
                            'file'
                        )
                        return vim.g.dap_target
                    end,
                    cwd = function()
                        vim.g.dap_cwd =
                            vim.fn.input('Working directory: ', vim.g.dap_cwd or vim.fn.getcwd() .. '/', 'file')
                        return vim.g.dap_cwd
                    end,
                    stopOnEntry = false,
                    args = function()
                        vim.g.dap_args = vim.fn.input('Arguments: ', vim.g.dap_args or '')
                        return vim.split(vim.g.dap_args, ' +')
                    end,
                    runInTerminal = false,
                },
            }
            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
            dap.configurations.lua = {
                {
                    type = 'nlua',
                    request = 'attach',
                    name = 'Attach to running Neovim instance',
                    host = function()
                        local value = vim.fn.input('Host [127.0.0.1]: ')
                        if value ~= '' then
                            return value
                        end
                        return '127.0.0.1'
                    end,
                    port = function()
                        local val = tonumber(vim.fn.input('Port: '))
                        assert(val, 'Please provide a port number')
                        return val
                    end,
                },
            }
            dap.adapters.nlua = function(callback, config)
                callback({ type = 'server', host = config.host, port = config.port })
            end
        end,
    },
    {
        'jbyuki/one-small-step-for-vimkind',
        dependencies = {
            'mfussenegger/nvim-dap',
        },
    },
}
