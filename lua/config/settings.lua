local opt = vim.opt

--Enable project-local .nvim.lua/.exrc files (asks for trust before running them)
opt.exrc = true

--Highlight on search is toggled by custom.search
opt.hlsearch = false

--Make line numbers default
opt.number = true

--Enable break indent
opt.breakindent = true

--Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

--Save undo history
opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
opt.ignorecase = true
opt.smartcase = true

--Decrease update time
opt.updatetime = 250
opt.signcolumn = 'yes'

opt.cursorline = true

--24-bit colors (auto-detection fails in some terminals and headless)
opt.termguicolors = true

--Open vertical splits on the right
opt.splitright = true

--Show end of line markers
opt.list = true
opt.listchars:append('eol:↴')

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})
