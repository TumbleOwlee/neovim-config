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
            require('CopilotChat').setup({
                window = {
                    layout = 'vertical',
                    relative = 'win',
                    width = math.min(vim.o.columns, 150), -- Fixed width in columns
                    height = 1.0, -- Fixed height in rows
                    row = 1,
                    col = vim.o.columns - math.min(vim.o.columns, 150),
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
                model = 'claude-opus-4.6', -- Default model, see :CopilotChatModels
                tools = { 'file', 'glob', 'grep' }, -- List of tools to use
            })

            -- Customize chat buffer
            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('CopilotChatBuffer', { clear = true }),
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
