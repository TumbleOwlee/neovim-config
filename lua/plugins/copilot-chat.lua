-- GitHub Copilot chat (inline suggestions come from the native copilot LSP, see config/lsp.lua)
return {
    {
        'CopilotC-Nvim/CopilotChat.nvim',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
        },
        build = 'make tiktoken',
        cmd = { 'CopilotChat', 'CopilotChatToggle', 'CopilotChatOpen', 'CopilotChatModels', 'CopilotChatPrompts' },
        keys = {
            { '<A-e>', '<cmd>CopilotChatToggle<CR>', desc = 'Toggle CopilotChat' },
            { '<leader>Cc', '<cmd>CopilotChatToggle<CR>', desc = 'Toggle chat' },
            { '<leader>Cm', '<cmd>CopilotChatModels<CR>', desc = 'Select model' },
            { '<leader>Cp', '<cmd>CopilotChatPrompts<CR>', mode = { 'n', 'x' }, desc = 'Select prompt' },
            { '<leader>Ce', '<cmd>CopilotChatExplain<CR>', mode = { 'n', 'x' }, desc = 'Explain code' },
            { '<leader>Cr', '<cmd>CopilotChatReview<CR>', mode = { 'n', 'x' }, desc = 'Review code' },
            { '<leader>Cf', '<cmd>CopilotChatFix<CR>', mode = { 'n', 'x' }, desc = 'Fix code' },
        },
        config = function()
            -- Half the editor, at most 150 columns, so the code stays visible next to it. The width is read when the
            -- chat opens, so it follows the size of the editor
            local function width()
                return math.min(150, math.floor(vim.o.columns * 0.5))
            end
            local chat = require('CopilotChat')
            chat.setup({
                window = {
                    layout = 'vertical',
                    width = width(),
                    height = 1.0,
                    border = 'double', -- 'single', 'double', 'rounded', 'solid'
                    title = '🤖 AI Assistant',
                    zindex = 100, -- Ensure window stays on top
                },
                headers = {
                    user = '👤 You',
                    assistant = '🤖 Copilot',
                    tool = '🔧 Tool',
                },
                separator = '━━',
                auto_fold = true, -- Automatically folds non-assistant messages
                tools = { 'file', 'glob', 'grep' }, -- List of tools to use
            })

            local group = vim.api.nvim_create_augroup('CopilotChatBuffer', { clear = true })
            vim.api.nvim_create_autocmd('VimResized', {
                group = group,
                callback = function()
                    chat.config.window.width = width()
                end,
            })

            -- Customize chat buffer
            vim.api.nvim_create_autocmd('FileType', {
                group = group,
                pattern = 'copilot-chat',
                callback = function()
                    vim.opt_local.relativenumber = false
                    vim.opt_local.number = false
                    vim.opt_local.conceallevel = 3
                end,
            })
        end,
    },
}
