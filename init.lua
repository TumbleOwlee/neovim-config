if vim.fn.has('nvim-0.12') == 0 then
    require('config.util').abort('This configuration requires Neovim >= 0.12', 'Found ' .. tostring(vim.version()))
end

require('config')
require('custom')
