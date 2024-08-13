-- Keybindings with interactive popup for reminder
require'loader'.load_plugin({
    'folke/which-key.nvim',
    config = function()
        local wk = require('which-key')

        -- Terminal mode without <leader>
        wk.register({
            ['<A-d>'] = { [[<C-\><C-n><cmd>Lspsaga term_toggle<CR>]], 'Close terminal' },
        }, { mode = 't', prefix = "", noremap =true, silent = true })

        -- Normal mode without <leader>
        wk.register({
            ['g'] = {
                ['name'] = 'Go to',
                ['D'] = { [[<Cmd>lua vim.lsp.buf.declaration()<CR>]], 'Go to declaration' },
                ['d'] = { [[<Cmd>lua vim.lsp.buf.definition()<CR>]], 'Go to definition' },
                ['i'] = { [[<cmd>lua vim.lsp.buf.implementation()<CR>]], 'Go to implementation' },
                ['h'] = { [[<cmd>Lspsaga finder<CR>]], 'LSP finder' },
                ['r'] = { [[<cmd>lua vim.lsp.buf.references()<CR>]], 'Show references' },
            },
            ['K'] = { [[<cmd>Lspsaga hover_doc<CR>]], 'Show documentation' },
            ['<A-d>'] = { [[<cmd>Lspsaga term_toggle<CR>]], 'Open terminal' },
            ['<C-d>'] = { [[<cmd>NvimTreeToggle<CR>]], 'Toggle directory tree' },
            ['<C-p>'] = { [[<cmd>Lspsaga diagnostic_jump_prev<CR>]], 'Jump to previous' },
            ['<C-n>'] = { [[<cmd>Lspsaga diagnostic_jump_next<CR>]], 'Jump to next' },
        }, { mode = 'n', prefix = "", noremap = true, silent = true })
        -- Expressions
        wk.register({
            ['j'] = { 'v:count == 0 ? "gj" : "j"', 'Move cursor up' },
            ['k'] = { 'v:count == 0 ? "gk" : "k"', 'Move cursor up' },
        }, { mode = 'n', prefix = "", noremap = true, silent = true, expr = true })

        -- Normal mode with <leader>
        wk.register({
            ['c'] = {
                ['name'] = 'Code actions',
                ['a'] = { [[<cmd>Lspsaga code_action<CR>]], 'Code action' },
            },
            ['s'] = { -- Session
                ['name'] = 'Session handling',
                ['s'] = 'Save session',
                ['l'] = 'Load session',
            },
            ['D'] = { [[<cmd>lua vim.lsp.buf.type_definition()<CR>]], 'Type definition' },
            ['d'] = { -- Dashboard
                ['name'] = 'Dashboard operations.',
                ['n'] = { [[<cmd>DashboardNewFile<CR>]], 'New file' },
            },
            ['g'] = {
                ['name'] = 'Debugging operations',
                ['b'] = { [[<cmd>lua require'dap'.toggle_breakpoint()<CR>]], 'Toggle breakpoint' },
                ['c'] = { [[<cmd>lua require'dap'.continue()<CR>]], 'Continue' },
                ['r'] = { [[<cmd>lua require'dap'.continue()<CR>]], 'Run' },
                ['t'] = { [[<cmd>lua require'dap'.terminate()<CR>]], 'Terminate' },
                ['d'] = { [[<cmd>lua require'dap'.clear_breakpoints()<CR>]], 'Clear all breakpoints' },
                ['n'] = { [[<cmd>lua require'dap'.step_over()<CR>]], 'Step over' },
                ['g'] = { [[<cmd>lua require'dap'.run_to_cursor()<CR>]], 'Run to cursor' },
                ['s'] = {
                    ['name'] = 'Step operations',
                    ['i'] = { [[<cmd>lua require'dap'.step_into()<CR>]], 'Step into' },
                    ['o'] = { [[<cmd>lua require'dap'.step_out()<CR>]], 'Step out' },
                    ['b'] = { [[<cmd>lua require'dap'.step_back()<CR>]], 'Step back' },
                    ['r'] = { [[<cmd>lua require'dap'.reverse_continue()<CR>]], 'Reverse continue' },
                },
                ['i'] = {
                    ['name'] = 'Information',
                    ['u'] = { [[<cmd>lua require'dap'.up()<CR>]], 'Go up in stacktrace' },
                    ['d'] = { [[<cmd>lua require'dap'.down()<CR>]], 'Go down in stacktrace' },
                    ['f'] = { [[<cmd>lua require'dap.ui.widgets'.centered_float(require'dap.ui.widgets'.frames)<CR>]], 'Show frames' },
                    ['s'] = { [[<cmd>lua require'dap.ui.widgets'.centered_float(require'dap.ui.widgets'.frames)<CR>]], 'Show scopes' },
                },
                ['p'] = { [[<cmd>lua require'dap'.pause()<CR>]], 'Pause thread' },
                ['f'] = { [[<cmd>lua require'dap'.repl.toggle()<CR>]], 'Toggle interactive REPL console' },
                ['v'] = { [[<cmd>lua require'dap.ui.widgets').hover()<CR>]], 'Show value of expr under cursor' },
            },
            ['l'] = {
                ['name'] = 'LSP operations',
                ['w'] = {
                    ['name'] = 'Workspace',
                    ['a'] = { [[<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>]], 'Add folder' },
                    ['r'] = { [[<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>]], 'Remove folder' },
                    ['l'] = { [[<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>]], 'List folders' },
                },
                ['q'] = { [[<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>]], 'Set loclist' },
                ['s'] = { [[<cmd>Lspsaga peek_definition<CR>]], 'Peek definition' },
                ['d'] = { [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], 'Document symbols' },
                ['r'] = { [[<cmd>Lspsaga rename<CR>]], 'Rename' },
                ['p'] = { [[<cmd>Lspsaga peek_definition<CR>]], 'Preview definition' },
                ['j'] = {
                    ['name'] = 'Jump',
                    ['n'] = { [[<cmd>Lspsaga diagnostic_jump_next<CR>]], 'Jump to next' },
                    ['p'] = { [[<cmd>Lspsaga diagnostic_jump_prev<CR>]], 'Jump to previous' },
                },
                ['c'] = {
                    ['name'] = 'Callhierarchy',
                    ['i'] = { [[<cmd>Lspsaga incoming_calls<CR>]], 'Incoming calls' },
                    ['o'] = { [[<cmd>Lspsaga outgoing_calls<CR>]], 'Outgoing calls' },
                },
            },
            ['b'] = {
                ['name'] = 'Buffer operations',
                ['p'] = { [[<cmd>BufferLinePick<CR>]], 'Buffer picker' },
                ['b'] = { [[<cmd>Gitsigns toggle_current_line_blame<CR>]], 'Toggle line blame' },
            },
            ['q'] = {
                ['name'] = 'Quickfix window',
                ['t'] = { [[<cmd>Trouble diagnostics toggle<CR>]], 'Toggle quickfix' },
                ['d'] = { [[<cmd>TodoTelescope<CR>]], 'Show ToDo list' },
            },
            ['t'] = {
                ['name'] = 'Telescope operations',
                ['f'] = {
                    ['name'] = 'Find',
                    ['f'] = { [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]], 'Find files' },
                    ['z'] ={ [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], 'Fuzzy find' },
                },
                ['m'] = { [[<cmd>lua require('telescope.builtin').marks()<CR>]], 'Help tags' },
                ['h'] = { [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], 'Help tags' },
                ['t'] = { [[<cmd>lua require('telescope.builtin').tags()<CR>]], 'Tags' },
                ['s'] = { [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], 'Grep string' },
                ['l'] = { [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], 'Live grep' },
                ['c'] = { [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], 'Tags in current buffer' },
                ['?'] = { [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], 'Old files' },
            },
            ['z'] = { [[<cmd>Twilight<CR>]], 'Toggle zen mode' },
            ['p'] = {
                ['name'] = 'Nvim operations',
                ['u'] = { [[<cmd>PackerUpdate<CR>]], 'Packer update' },
                ['q'] = { [[<cmd>exit<CR>]], 'Close nvim' },
            },
            ['f'] = { [[<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>]], 'List buffers'},
            ['<Space>'] = { [[<cmd>lua require('telescope.builtin').buffers()<CR>]], 'List buffers'},
        }, { mode = 'n', prefix = '<leader>', noremap = true, silent = true })

        -- Visual mode with <leader>
        wk.register({
        }, { mode = 'v', prefix = '<leader>', noremap = true, silent = true })

        wk.register({
            ['<Tab>'] = { [[<cmd>lua vimrc.cmp.cb_tab()<CR>]], 'Move to next completion item' },
            ['<S-Tab>'] = { [[<cmd>lua vimrc.cmp.cb_s_tab()<CR>]], 'Move to previous completion item' },
            ['<S-CR>'] = { [[<cmd>lua vimrc.cmp.cb_s_cr()<CR>]], 'Confirm completion item' },
            ['<C-x>'] = { [[<cmd>lua if require'luasnip'.expandable() then require'luasnip'.expand() end<CR>]], 'Expand snippet' },
            ['<C-n>'] = { [[<cmd>lua if require'luasnip'.jumpable(1) then require'luasnip'.jump(1) end<CR>]], 'Jump to next position' },
            ['<C-p>'] = { [[<cmd>lua if require'luasnip'.jumpable(-1) then require'luasnip'.jump(-1) end<CR>]], 'Jump to next position' },
        }, { mode = 'i', prefix = '', noremap = true, silent = true})
    end
})
