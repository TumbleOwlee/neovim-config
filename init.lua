-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.api.nvim_exec(
[[
augroup Packer
autocmd!
autocmd BufWritePost init.lua PackerCompile
augroup end
]],
false
)

--Helper to check if modules is available
function is_module_available(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if loader and type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

--impatient.nvimj
if (is_module_available('impatient')) then
    require('impatient')
end

local use = require('packer').use
require('packer').startup(function()
    use 'wbthomason/packer.nvim' -- Package manager
    use 'tpope/vim-fugitive' -- Git commands in nvim
    use 'tpope/vim-rhubarb' -- Fugitive-companion to interact with github
    use 'tpope/vim-commentary' -- "gc" to comment visual regions/lines
    use 'glepnir/dashboard-nvim' -- Dashboard start page
    use { 'folke/trouble.nvim', requires = 'kyazdani42/nvim-web-devicons', config = function() require('trouble').setup {} end } -- List of diagnostics
    use { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } } -- UI to select things (files, grep results, open buffers...)
    use 'joshdick/onedark.vim' -- Theme inspired by Atom
    use 'itchyny/lightline.vim' -- Fancier statusline
    use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
    use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Add git related info in the signs columns and popups
    use 'nvim-treesitter/nvim-treesitter' -- Highlight, edit, and navigate code using a fast incremental parsing library
    use 'nvim-treesitter/nvim-treesitter-textobjects' -- Additional textobjects for treesitter
    use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
    use 'tami5/lspsaga.nvim' -- lsp extension
    use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'L3MON4D3/LuaSnip' -- Snippets plugin
    use 'saadparwaiz1/cmp_luasnip'
    use 'honza/vim-snippets' -- Code snippets
    use 'jbyuki/instant.nvim' -- Collaborative editing
    use 'xiyaowong/nvim-cursorword' -- Highlight all word matching word under cursor
    use { 'kyazdani42/nvim-tree.lua', requires = { 'kyazdani42/nvim-web-devicons' }, config = function() require'nvim-tree'.setup {} end }
    use 'akinsho/bufferline.nvim' -- buffer line
    use 'folke/which-key.nvim' -- show keybindings as list
    use 'folke/twilight.nvim' -- dims inactive potions of code
    use 'lewis6991/impatient.nvim' -- speed up plugin loading
    use { 'folke/todo-comments.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Todo listing
    use 'mfussenegger/nvim-dap' -- Debug adapter protocol
    use { 'jbyuki/one-small-step-for-vimkind', requires = { 'mfussenegger/nvim-dap' } } -- Neovim DAP
end)

--Incremental live completion
vim.o.inccommand = 'nosplit'

--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

--Do not save when switching buffers
vim.o.hidden = true

--Enable mouse mode
vim.o.mouse = 'a'

--Enable break indent
vim.o.breakindent = true

--Set tab width
vim.o.tabstop = 4

--Set shiftwidth
vim.o.shiftwidth = 4

--Set expandtab
vim.o.expandtab = true

--Save undo history
vim.cmd [[set undofile]]

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2
vim.cmd [[silent! colorscheme onedark]]

--Set statusbar
vim.g.lightline = {
    colorscheme = 'onedark',
    active = { left = { { 'mode', 'paste' }, { 'gitbranch', 'readonly', 'filename', 'modified' } } },
    component_function = { gitbranch = 'fugitive#head' },
}

--Dashboard default fuzzy search plugin
vim.g.dashboard_default_executive = 'telescope'
vim.g.dashboard_custom_shortcut = {
     ['last_session'] = 'SPC s l',
     ['find_history'] = 'SPC d h',
     ['find_file'] = 'SPC d f',
     ['new_file'] = 'SPC d n',
     ['change_colorscheme'] = 'SPC d c',
     ['find_word'] = 'SPC d w',
     ['book_marks'] = 'SPC d b',
 }

--LspSaga
if (is_module_available('lspsaga')) then
    require'lspsaga'.init_lsp_saga()
end

--bufferline.nvim
if (is_module_available('bufferline')) then
    require'bufferline'.setup{
        diagnostics = 'nvim_lsp'
    }
end

--todo-comments.nvim
if (is_module_available('todo-comments')) then
    require'todo-comments'.setup{ }
end

--Create new highlight group (necessary for instant.nvim)
local function new_hi_group(name, fg, bg)
    local bg = bg or '0'
    local fg = fg or '0'
    vim.cmd("highlight " .. name .. " guifg=" .. fg .. " guibg="..bg)
    return name
end

-- instant.nvim
if (is_module_available('instant')) then
    vim.g.instant_username = "Owlee"
    vim.g.instant_auth_separator = "| "
    vim.g.instant_cursor_hl_group_user1 = new_hi_group("instant_cursor1", "#000000", "#BB62D3")
    vim.g.instant_name_hl_group_user1 = new_hi_group("instant_name1", "#BB62D3")
    vim.g.instant_cursor_hl_group_user2 = new_hi_group("instant_cursor2", "#000000", "#D36284")
    vim.g.instant_name_hl_group_user2 = new_hi_group("instant_name2", "#D36284")
    vim.g.instant_cursor_hl_group_user3 = new_hi_group("instant_cursor3", "#000000", "#62A9D3")
    vim.g.instant_name_hl_group_user3 = new_hi_group("instant_name3", "#62A9D3")
    vim.g.instant_cursor_hl_group_user4 = new_hi_group("instant_cursor4", "#000000", "#62D39D")
    vim.g.instant_name_hl_group_user4 = new_hi_group("instant_name4", "#62D39D")
    vim.g.instant_cursor_hl_group_default = new_hi_group("instant_cursor_default", "#000000", "#CCD362")
    vim.g.instant_name_hl_group_default = new_hi_group("instant_name_default", "#CCD362")
end

--Map blankline
if (is_module_available('indent_blankline')) then
    vim.opt.list = true
    vim.opt.listchars:append("eol:↴")
    vim.g.indent_blankline_char = '┊'
    vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
    vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
    vim.g.indent_blankline_char_highlight = 'LineNr'
    vim.g.indent_blankline_show_trailing_blankline_indent = true
    require("indent_blankline").setup {
        show_end_of_line = true,
    }
end

-- Gitsigns
if (is_module_available('gitsigns')) then
    require('gitsigns').setup {
        signs = {
            add = { hl = 'GitGutterAdd', text = '+' },
            change = { hl = 'GitGutterChange', text = '~' },
            delete = { hl = 'GitGutterDelete', text = '_' },
            topdelete = { hl = 'GitGutterDelete', text = '‾' },
            changedelete = { hl = 'GitGutterChange', text = '~' },
        },
    }
end

-- Telescope
if (is_module_available('telescope')) then
    require('telescope').setup {
        defaults = {
            mappings = {
                i = {
                    ['<C-u>'] = false,
                    ['<C-d>'] = false,
                },
            },
        },
    }
end

-- Highlight on yank
vim.api.nvim_exec(
[[
augroup YankHighlight
autocmd!
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup end
]],
false
)

--Set custom highlight for nvim-cursorword
vim.api.nvim_exec( [[ hi! CursorWord gui=underline cterm=undercurl ]], false)

-- Y yank until the end of line
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })

-- nvim-cmp initialization
if (is_module_available('cmp')) then
    local cmp = require'cmp'
    cmp.setup({
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
              end,
        },
        mapping = {
            ['<Down>'] = cmp.config.disable,
            ['<Up>'] = cmp.config.disable,
            ['<Tab>'] = cmp.config.disable,
            ['<S-Tab>'] = cmp.config.disable,
            ['<C-n>'] = cmp.config.disable,
            ['<C-p>'] = cmp.config.disable,
            ['<C-y>'] = cmp.config.disable,
            ['<C-e>'] = cmp.config.disable,
            ['<CR>'] = cmp.config.disable,
        },
        sources = cmp.config.sources({
            { name = 'luasnip' },
            { name = 'nvim_lsp' },
        }, {
            { name = 'buffer' },
        })
    })
     -- Set configuration for specific filetype.
    cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
            { name = 'cmp_git' },
        }, {
            { name = 'buffer' },
        })
    })
    -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline('/', {
        sources = {
            { name = 'buffer' }
        }
    })
    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })

    _G.vimrc = _G.vimrc or {}
    _G.vimrc.cmp = _G.vimrc.cmp or {}
    _G.vimrc.cmp.has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    local luasnip = is_module_available('luasnip') and require'luasnip'
    local cmp = is_module_available('cmp') and require'cmp'
    local types = is_module_available('cmp') and require'cmp.types'
    _G.vimrc.cmp.cb_tab = function()
        if luasnip and luasnip.jumpable(1) then
            luasnip.jump(1)
        elseif cmp and cmp.visible() then
            cmp.select_next_item()
        elseif luasnip and luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        elseif cmp and _G.vimrc.cmp.has_words_before() then
            cmp.complete()
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n', true)
        end
    end
    _G.vimrc.cmp.cb_s_tab = function()
        if luasnip.jumpable(-1) then
            luasnip.jump(-1)
        elseif cmp.visible() then
            cmp.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert })
        elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
        end
    end
    _G.vimrc.cmp.cb_s_cr = function()
        if cmp.visible() and cmp.get_active_entry()
            then cmp.confirm()
        end
    end
    _G.vimrc.cmp.cb_c_x = function()
        if luasnip.expandable() then
            luasnip.expand()
        end
    end
end

-- LSP settings
if (is_module_available('lspconfig')) then
    local nvim_lsp = require 'lspconfig'
    local on_attach = function(_, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    if is_module_available('cmp_nvim_lsp') then
        capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
    end

    -- Enable the following language servers
    local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
    for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
        }
    end
end

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
if (is_module_available('nvim-treesitter.configs')) then
    require('nvim-treesitter.configs').setup {
        highlight = {
            enable = true, -- false will disable the whole extension
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = 'gnn',
                node_incremental = 'grn',
                scope_incremental = 'grc',
                node_decremental = 'grm',
            },
        },
        indent = {
            enable = true,
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer',
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer',
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer',
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer',
                },
            },
        },
    }
end

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- luasnip initialization
if is_module_available('luasnip') then
    require'luasnip'.config.setup({
        enable_autosnippets = true,
    })
    require'luasnip.loaders.from_snipmate'.load()
end

--twilight.nvim
if (is_module_available('twilight')) then
    require'twilight'.setup {
        dimming = {
            alpha = 0.5,
        },
        context = 30,
    }
end

--dap-nvim
if (is_module_available('dap')) then
    local dap = require('dap')
    dap.adapters.lldb = {
      type = 'executable',
      command = '/usr/bin/lldb-vscode', -- adjust as needed
      name = "lldb"
    }

    dap.configurations.cpp = {
        {
            name = "Launch",
            type = "lldb",
            request = "launch",
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            args = {},
            runInTerminal = false,
        },
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

-- KEYBINDINGS

--Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--WhichKey keybinding generation
if (is_module_available('which-key')) then
    local wk = require('which-key')

    -- Terminal mode without <leader>
    wk.register({
        ['<A-d>'] = { [[<C-\><C-n><cmd>lua require'lspsaga.floaterm'.close_float_terminal()<CR>]], 'Close terminal' },
    }, { mode = 't', prefix = "", noremap =true, silent = true })

    -- Normal mode without <leader>
    wk.register({
        ['g'] = {
            ['name'] = 'Go to',
            ['D'] = { [[<Cmd>lua vim.lsp.buf.declaration()<CR>]], 'Go to declaration' },
            ['d'] = { [[<Cmd>lua vim.lsp.buf.definition()<CR>]], 'Go to definition' },
            ['i'] = { [[<cmd>lua vim.lsp.buf.implementation()<CR>]], 'Go to implementation' },
            ['h'] = { [[<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>]], 'LSP finder' },
            ['r'] = { [[<cmd>lua vim.lsp.buf.references()<CR>]], 'Show references' },
        },
        ['K'] = { [[<cmd>lua require'lspsaga.hover'.render_hover_doc()<CR>]], 'Show documentation' },
        ['<A-d>'] = { [[<cmd>lua require'lspsaga.floaterm'.open_float_terminal()<CR>]], 'Open terminal' },
        ['<C-n>'] = { [[<cmd>NvimTreeToggle<CR>]], 'Toggle directory tree' },
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
            ['a'] = { [[<cmd>lua require'lspsaga.codeaction'.code_action()<CR>]], 'Code action' },
        },
        ['s'] = { -- Session
            ['name'] = 'Session handling',
            ['s'] = 'Save session',
            ['l'] = 'Load session',
        },
        ['D'] = { [[<cmd>lua vim.lsp.buf.type_definition()<CR>]], 'Type definition' },
        ['d'] = { -- Dashboard
            ['name'] = 'Dashboard operations.',
            ['h'] = { [[<cmd>DashboardFindHistory<CR>]], 'Find history' },
            ['f'] = { [[<cmd>DashboardFindFile<CR>]], 'Find file' },
            ['c'] = { [[<cmd>DashboardChangeColorscheme<CR>]], 'Change colorscheme' },
            ['w'] = { [[<cmd>DashboardFindWord<CR>]], 'Find word' },
            ['b'] = { [[<cmd>DashboardJumpMark<CR>]], 'Jump bookmark' },
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
            ['r'] = { [[<cmd>lua require'dap'.repl.toggle()<CR>]], 'Toggle interactive REPL console' },
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
            ['s'] = { [[<cmd>lua require'lspsaga.signaturehelp'.signature_help()<CR>]], 'Signature help' },
            ['d'] = { [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], 'Document symbols' },
            ['r'] = { [[<cmd>lua require'lspsaga.rename'.rename()<CR>]], 'Rename' },
            ['p'] = { [[<cmd>lua require'lspsaga.provider'.preview_definition()<CR>]], 'Preview definition' },
            ['l'] = { [[<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>]], 'Show line diagnostics' },
            ['c'] = { [[<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>]], 'Show cursor diagnostics' },
            ['j'] = {
                ['name'] = 'Jump',
                ['n'] = { [[<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>]], 'Jump to next' },
                ['p'] = { [[<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>]], 'Jump to previous' },
            },
        },
        ['b'] = {
            ['name'] = 'Buffer operations',
            ['p'] = { [[<cmd>BufferLinePick<CR>]], 'Buffer picker' },
            ['b'] = { [[<cmd>Gitsigns toggle_current_line_blame<CR>]], 'Toggle line blame' },
        },
        ['q'] = {
            ['name'] = 'Quickfix window',
            ['t'] = { [[<cmd>TroubleToggle<CR>]], 'Toggle quickfix' },
            ['r'] = { [[<cmd>TroubleRefresh<CR>]], 'Refresh quickfix' },
            ['d'] = { [[<cmd>TodoTelescope<CR>]], 'Show ToDo list' },
        },
        ['t'] = {
            ['name'] = 'Telescope operations',
            ['f'] = {
                ['name'] = 'Find',
                ['f'] = { [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]], 'Find files' },
                ['z'] ={ [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], 'Fuzzy find' },
            },
            ['h'] = { [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], 'Help tags' },
            ['t'] = { [[<cmd>lua require('telescope.builtin').tags()<CR>]], 'Tags' },
            ['s'] = { [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], 'Grep string' },
            ['l'] = { [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], 'Live grep' },
            ['c'] = { [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], 'Tags in current buffer' },
            ['?'] = { [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], 'Old files' },
        },
        ['z'] = { [[<cmd>Twilight<CR>]], 'Toggle zen mode' },
        ['<Space>'] = { [[<cmd>lua require('telescope.builtin').buffers()<CR>]], 'List buffers'},
    }, { mode = 'n', prefix = '<leader>', noremap = true, silent = true })

    -- Visual mode with <leader>
    wk.register({
        ['c'] = {
            ['name'] = 'Range code actions',
            ['a'] = { [[<cmd>lua require'lspsaga.codeaction'.range_code_action()<CR>]], 'Range code action' },
        },
    }, { mode = 'v', prefix = '<leader>', noremap = true, silent = true })

    wk.register({
        ['<Tab>'] = { [[<cmd>lua vimrc.cmp.cb_tab()<CR>]], '' },
        ['<S-Tab>'] = { [[<cmd>lua vimrc.cmp.cb_s_tab()<CR>]], '' },
        ['<S-CR>'] = { [[<cmd>lua vimrc.cmp.cb_s_cr()<CR>]], '' },
        ['<C-x>'] = { [[<cmd>lua if require'luasnip'.expandable() then require'luasnip'.expand() end<CR>]], '' },
    }, { mode = 'i', prefix = '', noremap = true, silent = true})
end

