--Enable local nvim files
vim.o.exrc = true
vim.o.secure = true

--Incremental live completion
vim.o.inccommand = "nosplit"

--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

--Do not save when switching buffers
vim.o.hidden = true

--Enable mouse mode
vim.o.mouse = "a"

--Enable break indent
vim.o.breakindent = true

--Set tab width
vim.o.tabstop = 4

--Set shiftwidth
vim.o.shiftwidth = 4

--Set expandtab
vim.o.expandtab = true

--Save undo history
vim.cmd([[set undofile]])

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

vim.o.cursorline = true

--Set background opacity
vim.cmd("highlight Normal guibg=none")

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

-- Y yank until the end of line
vim.api.nvim_set_keymap("n", "Y", "y$", { noremap = true })

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menu,menuone,noselect"
