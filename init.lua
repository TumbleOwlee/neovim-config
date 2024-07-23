local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
  if not vim.uv.fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()

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

require('pckr').add {
    { 'snakemake/snakemake', rtp='misc/vim', ft='snakemake' }; -- Snakemake highlighting
    'tpope/vim-fugitive'; -- Git commands in nvim
    'tpope/vim-rhubarb'; -- Fugitive-companion to interact with github
    'tpope/vim-commentary'; -- "gc" to comment visual regions/lines
    'mboughaba/vim-lessmess'; -- Remove trailing whitespaces
    { 'nvimdev/dashboard-nvim', event = 'VimEnter', dependencies = { {'nvim-tree/nvim-web-devicons'}}}; -- Dashboard start page
    { 'folke/trouble.nvim', requires = 'kyazdani42/nvim-web-devicons', config = function() require('trouble').setup {} end }; -- List of diagnostics
    { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } }; -- UI to select things (files, grep results, open buffers...)
    'joshdick/onedark.vim'; -- Theme inspired by Atom
    'itchyny/lightline.vim'; -- Fancier statusline
    'lukas-reineke/indent-blankline.nvim'; -- Add indentation guides even on blank lines
    { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }; -- Add git related info in the signs columns and popups
    'nvim-treesitter/nvim-treesitter'; -- Highlight, edit, and navigate code using a fast incremental parsing library
    { 'nvim-treesitter/nvim-treesitter-textobjects', after = "nvim-treesitter", requires = "nvim-treesitter/nvim-treesitter" }; -- Additional textobjects for treesitter
    'nvim-lua/lsp_extensions.nvim';
    'rcarriga/nvim-notify'; -- prettify notifications
    'williamboman/mason.nvim'; -- auto install of language servers
    'williamboman/mason-lspconfig.nvim';
    'neovim/nvim-lspconfig'; -- Collection of configurations for built-in LSP client
    { 'nvimdev/lspsaga.nvim', after ='nvim-lspconfig', config = function() require'lspsaga'.setup({}) end, }; -- lsp extension
    'hrsh7th/nvim-cmp'; -- Autocompletion plugin
    'hrsh7th/cmp-nvim-lsp';
    'hrsh7th/cmp-buffer';
    'hrsh7th/cmp-path';
    'hrsh7th/cmp-cmdline';
    'hrsh7th/cmp-nvim-lsp-document-symbol';
    'ray-x/lsp_signature.nvim';
    { 'L3MON4D3/LuaSnip', after = 'nvim-cmp' }; -- Snippets plugin
    'saadparwaiz1/cmp_luasnip';
    'honza/vim-snippets'; -- Code snippets
    'jbyuki/instant.nvim'; -- Collaborative editing
    'xiyaowong/nvim-cursorword'; -- Highlight all word matching word under cursor
    { 'nvim-tree/nvim-tree.lua', requires = { 'nvim-tree/nvim-web-devicons' } };
    'akinsho/bufferline.nvim'; -- buffer line
    'folke/which-key.nvim'; -- show keybindings as list
    'folke/twilight.nvim'; -- dims inactive potions of code
    'lewis6991/impatient.nvim'; -- speed up plugin loading
    { 'folke/todo-comments.nvim', requires = { 'nvim-lua/plenary.nvim' } }; -- Todo listing
    'mfussenegger/nvim-dap'; -- Debug adapter protocol
    { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} } -- Neovim DAP UI
    { 'jbyuki/one-small-step-for-vimkind', requires = { 'mfussenegger/nvim-dap' } }; -- Neovim DAP
    'sbdchd/neoformat'; -- Extend formatting support
    { 'windwp/nvim-autopairs' }; -- auto closing brackets
    { "nvim-telescope/telescope-file-browser.nvim", requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" } }; -- file explorer
}

--Enable local nvim files
vim.o.exrc = true
vim.o.secure = true

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

vim.o.cursorline = true

vim.api.nvim_exec(
[[
augroup ColorExtend
autocmd!
autocmd ColorScheme * call onedark#extend_highlight("CursorLineNr", { "fg": { "gui": "#000000"}, "bg": { "gui": "#ad3d2a"} })
augroup end
]],
false
)

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2
vim.cmd [[silent! colorscheme onedark]]

--Set statusbar
vim.g.lightline = {
    colorscheme = 'onedark',
    active = { left = { { 'mode', 'paste' }, { 'gitbranch', 'readonly', 'filename', 'modified' } } },
    component_function = { gitbranch = 'FugitiveHead' },
}

--Dashboard default fuzzy search plugin
if (is_module_available('dashboard')) then
    local home = os.getenv('HOME')
    local db = require('dashboard')
    db.setup({
        theme = 'hyper',
        disable_move = true,
        shortcut_type = 'letter',
        config = {
            week_header = {
                enable = true,
            },
            shortcut = {
                a = { icon = " ", desc = "Find File", key = "f", action = "Telescope find_files"},
                b = { icon = " ", desc = "Recents", key = "?", action = "Telescope oldfiles"},
                c = { icon = " ", desc = "Find Word", key = "w", action = "Telescope live_grep"},
                d = { icon = " ", desc = "New File", key = "n", action = "DashboardNewFile"},
                e = { icon = " ", desc = "Bookmarks", key = "b", action = "Telescope marks"},
                f = { icon = "󰸧 ", desc = "Load Last Session", key = "s", action = "SessionLoad"},
                g = { icon = " ", desc = "Update Plugins", key = "u", action = "PackerUpdate"},
                i = { icon = "󰗼 ", desc = "Exit", key = "q", action = "exit"}
            },
            footer = {'type  :help<Enter>  or  <F1>  for on-line help'},
        }
    })
 end

-- telescope setup for file explorer
if (is_module_available('telescope')) then
    require'telescope'.load_extension 'file_browser'
end


--bufferline.nvim
if (is_module_available('bufferline')) then
    require'bufferline'.setup{
        options = {
            diagnostics = 'nvim_lsp'
        }
    }
end

--todo-comments.nvim
if (is_module_available('todo-comments')) then
    require'todo-comments'.setup{ }
end

-- signature
if (is_module_available('lsp_signature')) then
    local cfg = {}
    require'lsp_signature'.setup(cfg)
end

--Create new highlight group (necessary for instant.nvim)
local function new_hi_group(name, fg, bg)
    local bg = bg or '0'
    local fg = fg or '0'
    vim.cmd("highlight " .. name .. " guifg=" .. fg .. " guibg="..bg)
    return name
end

--Set background opacity
vim.cmd("highlight Normal guibg=none")

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
    require("ibl").setup {
        indent = {
            char = '┊',
            highlight = 'LineNr',
        },
        scope = {
            show_end = true,
        },
        exclude = {
            filetypes = { 'help', 'packer', 'dashboard' },
        },
    --    buftype_exclude = { 'terminal', 'nofile' },
        whitespace = {
            highlight = highlight,
            remove_blankline_trail = true,
        }
    }
end

-- Template placeholder replacement
vim.api.nvim_create_autocmd({"BufRead"}, {
    pattern = {"*"},
    callback = function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local context = vim.g.template_context_map or {}

        local config = {}
        for pattern, cfg in pairs(context) do
            if string.match(buf_name, pattern) then
                config = cfg
                break
            end
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        for nr, line in ipairs(lines) do
            for key, value in pairs(config) do
                line = line:gsub(key, value)
            end
            vim.api.nvim_buf_set_lines(0, nr - 1, nr, true, {line})
        end

        if lines[1] then
            vim.api.nvim_win_set_cursor(0, {1, lines[1]:len()})
        end
    end
})

-- Gitsigns
if (is_module_available('gitsigns')) then
    require('gitsigns').setup {
        signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
            untracked = { text = '|' },
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

-- lsp_extensions : Currently broken somehow
if (is_module_available('lsp_extensions')) then
    require'lsp_extensions'.inlay_hints{
        highlight = "Comment",
        prefix = " > ",
        aligned = false,
        only_current_line = false,
        enabled = { "TypeHint", "ChainingHint", "ParameterHint" }
    }
end

-- nvim-notify
if is_module_available('notify') then
    -- Change color of info
    local change_color = function(lvl, fg)
        vim.cmd("highlight Notify"..lvl.."Border guifg=" .. fg)
        vim.cmd("highlight Notify"..lvl.."Icon guifg=" .. fg)
        vim.cmd("highlight Notify"..lvl.."Title guifg=" .. fg)
    end

    change_color("INFO", "#8080ff")

    local nvim_notify = require'notify'
    nvim_notify.setup({
        stages = "fade_in_slide_out",
        timeout = 1500,
        background_colour = "#2E3440",
        render = "wrapped-compact",
        max_width = 60,
        max_height = 10,
        minimum_width = 40,
        fps = 45,
    })
    vim.notify = nvim_notify
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

-- nvim-autopairs
if (is_module_available('nvim-autopairs')) then
    require('nvim-autopairs').setup{}
end

-- nvim-cmp initialization
if (is_module_available('cmp')) then
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require'cmp'
    cmp.setup({
        snippet = {
            expand = function(args)
                local luasnip = require'luasnip'
                if not luasnip then
                    return
                end
                luasnip.lsp_expand(args.body)
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
            { name = 'nvim_lsp_document_symbol' },
            { name = 'nvim_lsp_signature_help' },
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
    -- add nvim-autopairs
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))

    _G.vimrc = _G.vimrc or {}
    _G.vimrc.cmp = _G.vimrc.cmp or {}
    _G.vimrc.cmp.has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    local luasnip = is_module_available('luasnip') and require'luasnip'
    local types = is_module_available('cmp') and require'cmp.types'
    _G.vimrc.cmp.cb_tab = function()
        if not _G.vimrc.cmp.has_words_before() then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n', true)
        elseif cmp and cmp.visible() then
            cmp.select_next_item({ behavior = types.cmp.SelectBehavior.Insert })
        elseif luasnip and luasnip.jumpable(1) then
            luasnip.jump(1)
        elseif luasnip and luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        elseif cmp and _G.vimrc.cmp.has_words_before() then
            cmp.complete()
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n', true)
        end
    end
    _G.vimrc.cmp.cb_s_tab = function()
        if cmp.visible() then
            cmp.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert })
        elseif luasnip and luasnip.jumpable(-1) then
            luasnip.jump(-1)
        elseif luasnip and luasnip.jumpable(-1) then
            luasnip.jump(-1)
        end
    end
    -- Important Note
    -- By default SHIFT-CR may not work. If so, you have to configure your terminal to send the correct codes.
    -- See https://stackoverflow.com/questions/16359878/how-to-map-shift-enter
    _G.vimrc.cmp.cb_s_cr = function()
        if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm()
        else
            cmp.select_next_item()
            cmp.select_prev_item()
            if cmp.get_active_entry() then
                cmp.confirm()
            end
        end
    end
    _G.vimrc.cmp.cb_c_x = function()
        if luasnip and luasnip.expandable() then
            luasnip.expand()
        end
    end
end

-- LSP settings
if (is_module_available('lspconfig')) then
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
    if is_module_available('cmp_nvim_lsp') then
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
    end

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

    if (is_module_available('mason')) then
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
vim.o.completeopt = 'menu,menuone,noselect'

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
  
    if (is_module_available('dapui')) then
      require('dapui').setup()
      
      local dapui = require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end
  
    dap.adapters.lldb = {
      type = 'executable',
      command = '/usr/bin/lldb-vscode',
      name = "lldb"
    }

    dap.adapters.gdb = {
      type = 'executable',
      command = 'gdb',
      name = "gdb",
      args = { "-i", "dap" }
    }

    dap.configurations.cpp = {
        {
            name = "Launch",
            type = "gdb",
            request = "launch",
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = true,
            args = {},
            runInTerminal = false,
        },
    }
    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = {
        {
            name = "Launch",
            type = "gdb",
            request = "launch",
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            args = {},
            runInTerminal = false,
        },
    }
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

-- Snakemake
vim.api.nvim_exec(
[[
augroup Snakemake
autocmd!
autocmd BufWritePost *.smk silent w !snakefmt - 2>/dev/null >/tmp/snakefmt && cat /tmp/snakefmt >%
augroup end
]],
false
)

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
                ['n'] = { [[<cmd>Lspsaga diagnostic_jump_prev<CR>]], 'Jump to next' },
                ['p'] = { [[<cmd>Lspsaga diagnostic_jump_next<CR>]], 'Jump to previous' },
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
