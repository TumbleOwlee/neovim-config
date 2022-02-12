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
            if type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
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
    use 'glepnir/lspsaga.nvim' -- lsp extension
    use 'hrsh7th/nvim-compe' -- Autocompletion plugin
    use 'L3MON4D3/LuaSnip' -- Snippets plugin
    use 'jbyuki/instant.nvim' -- Collaborative editing
    use 'xiyaowong/nvim-cursorword' -- Highlight all word matching word under cursor
    use { 'kyazdani42/nvim-tree.lua', requires = { 'kyazdani42/nvim-web-devicons' }, config = function() require'nvim-tree'.setup {} end }
    use 'akinsho/bufferline.nvim' -- buffer line
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

--Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--Remap for dealing with word wrap
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

--Dashboard default fuzzy search plugin
vim.g.dashboard_default_executive = 'telescope'
vim.api.nvim_set_keymap('n', '<leader>ss', [[<cmd>SessionSave<CR>]], { noremap = false, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sl', [[<cmd>SessionLoad<CR>]], { noremap = false, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fh', [[<cmd>DashboardFindHistory<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>DashboardFindFile<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tc', [[<cmd>DashboardChangeColorscheme<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fa', [[<cmd>DashboardFindWord<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>DashboardJumpMark<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cn', [[<cmd>DashboardNewFile<CR>]], { noremap = true, silent = true })

--LspSaga
if (is_module_available('lspsaga')) then
    vim.api.nvim_set_keymap('n', 'gh', [[<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>ca', [[<cmd>lua require'lspsaga.codeaction'.code_action()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<leader>ca', [[<cmd>lua require'lspsaga.codeaction'.range_code_action()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'K', [[<cmd>lua require'lspsaga.hover'.render_hover_doc()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'lss', [[<cmd>lua require'lspsaga.signaturehelp'.signature_help()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'lsr', [[<cmd>lua require'lspsaga.rename'.rename()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'lsp', [[<cmd>lua require'lspsaga.provider'.preview_definition()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'lsdl', [[<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'lsd', [[<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '[e', [[<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', ']e', [[<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>]], { noremap = true, silent = true })
    -- floating terminal
    vim.api.nvim_set_keymap('n', '<A-d>', [[<cmd>lua require'lspsaga.floaterm'.open_float_terminal()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('t', '<A-d>', [[<C-\><C-n><cmd>lua require'lspsaga.floaterm'.close_float_terminal()<CR>]], { noremap = true, silent = true })
    require'lspsaga'.init_lsp_saga()
end

--nvim-tree
vim.api.nvim_set_keymap('n', '<C-n>', [[<cmd>NvimTreeToggle<CR>]], { noremap = true, silent = true })

--Gitsigns
vim.api.nvim_set_keymap('n', '<leader>lb', [[<cmd>Gitsigns toggle_current_line_blame<CR>]], { noremap = true, silent = true })


--bufferline.nvim
if (is_module_available('bufferline')) then
    require'bufferline'.setup{
        diagnostics = 'nvim_lsp'
    }
    vim.api.nvim_set_keymap('n', '<leader>gb', [[<cmd>BufferLinePick<CR>]], { noremap = true, silent = true })
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
    vim.g.instant_cursor_hl_group_user1     = new_hi_group("instant_cursor1", "#000000", "#BB62D3")
    vim.g.instant_name_hl_group_user1         = new_hi_group("instant_name1", "#BB62D3")
    vim.g.instant_cursor_hl_group_user2     = new_hi_group("instant_cursor2", "#000000", "#D36284")
    vim.g.instant_name_hl_group_user2         = new_hi_group("instant_name2", "#D36284")
    vim.g.instant_cursor_hl_group_user3     = new_hi_group("instant_cursor3", "#000000", "#62A9D3")
    vim.g.instant_name_hl_group_user3         = new_hi_group("instant_name3", "#62A9D3")
    vim.g.instant_cursor_hl_group_user4     = new_hi_group("instant_cursor4", "#000000", "#62D39D")
    vim.g.instant_name_hl_group_user4         = new_hi_group("instant_name4", "#62D39D")
    vim.g.instant_cursor_hl_group_default = new_hi_group("instant_cursor_default", "#000000", "#CCD362")
    vim.g.instant_name_hl_group_default     = new_hi_group("instant_name_default", "#CCD362")
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
--Add leader shortcuts
vim.api.nvim_set_keymap('n', '<leader><space>', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sf', [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sb', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sh', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>st', [[<cmd>lua require('telescope.builtin').tags()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sd', [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sp', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>so', [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>?', [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], { noremap = true, silent = true })

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

-- LSP settings
if (is_module_available('lspconfig')) then
    local nvim_lsp = require 'lspconfig'
    local on_attach = function(_, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        local opts = { noremap = true, silent = true }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, 'v', '<leader>ca', '<cmd>lua vim.lsp.buf.range_code_action()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
        vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

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

-- Compe setup
if (is_module_available('compe')) then
    require('compe').setup {
        source = {
            path = true,
            nvim_lsp = true,
            luasnip = true,
            buffer = false,
            calc = false,
            nvim_lua = false,
            vsnip = false,
            ultisnips = false,
        },
    }
end

-- Utility functions for compe and luasnip
local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col '.' - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
if (is_module_available('luasnip')) then
    local luasnip = require 'luasnip'

    _G.tab_complete = function()
        if vim.fn.pumvisible() == 1 then
            return t '<C-n>'
        elseif luasnip.expand_or_jumpable() then
            return t '<Plug>luasnip-expand-or-jump'
        elseif check_back_space() then
            return t '<Tab>'
        else
            return vim.fn['compe#complete']()
        end
    end

    _G.s_tab_complete = function()
        if vim.fn.pumvisible() == 1 then
            return t '<C-p>'
        elseif luasnip.jumpable(-1) then
            return t '<Plug>luasnip-jump-prev'
        else
            return t '<S-Tab>'
        end
    end
end

-- Map tab to the above tab complete functiones
vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.tab_complete()', { expr = true })
vim.api.nvim_set_keymap('s', '<Tab>', 'v:lua.tab_complete()', { expr = true })
vim.api.nvim_set_keymap('i', '<S-Tab>', 'v:lua.s_tab_complete()', { expr = true })
vim.api.nvim_set_keymap('s', '<S-Tab>', 'v:lua.s_tab_complete()', { expr = true })

-- Map exit of terminal mode
vim.api.nvim_set_keymap('t', '<leader><ESC>', '<C-\\><C-n>', { noremap = true })

-- Map compe confirm and complete functions
vim.api.nvim_set_keymap('i', '<cr>', 'compe#confirm("<cr>")', { expr = true })
vim.api.nvim_set_keymap('i', '<c-space>', 'compe#complete()', { expr = true })
