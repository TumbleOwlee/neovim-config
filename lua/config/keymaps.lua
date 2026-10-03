-- General keymaps that don't belong to a plugin. Plugin keymaps live in the
-- `keys` field of their spec in lua/plugins, which-key only defines groups.
local map = vim.keymap.set

-- Move by display lines unless a count is given
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = 'Move cursor down' })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = 'Move cursor up' })

-- Buffers
map('n', '<A-m>', '<cmd>update<CR><cmd>bnext<CR>', { desc = 'Save and go to next buffer' })

-- Tabs. Most terminals send <Tab> for <C-i>, so jumping forward in the jump list only keeps working in a
-- terminal that tells the two apart, which is what the <C-i> mapping is for
map('n', '<Tab>', '<cmd>tabnext<CR>', { desc = 'Next tab' })
map('n', '<S-Tab>', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })
map('n', '<C-i>', '<C-i>', { desc = 'Jump forward' })
map('n', '<C-t>', '<cmd>tab split<CR>', { desc = 'Open current buffer in new tab' })
map('n', '<C-q>', function()
    -- The last tab cannot be closed
    if #vim.api.nvim_list_tabpages() > 1 then
        vim.cmd.tabclose()
    end
end, { desc = 'Close current tab' })
map('n', ']<Tab>', '<cmd>tabnext<CR>', { desc = 'Next tab' })
map('n', '[<Tab>', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })
map('n', '<leader><Tab>n', '<cmd>tabnew %<CR>', { desc = 'Open current buffer in new tab' })
map('n', '<leader><Tab>c', '<cmd>tabclose<CR>', { desc = 'Close current tab' })

-- Fold all lines not matching a pattern
map('n', '<A-q>', function()
    require('custom.search').search_pattern()
end, { desc = 'Fold lines not matching pattern' })

-- Diagnostics
map('n', '<leader>lq', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

-- Neovim
map('n', '<leader>pu', '<cmd>Lazy update<CR>', { desc = 'Update plugins' })
map('n', '<leader>pl', '<cmd>Lazy<CR>', { desc = 'Plugin manager' })
map('n', '<leader>pm', '<cmd>Mason<CR>', { desc = 'Mason' })
map('n', '<leader>pq', '<cmd>exit<CR>', { desc = 'Close nvim' })
