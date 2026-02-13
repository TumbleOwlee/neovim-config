return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
        build = "make tiktoken",
        config = function()
            opts = {
                window = {
                    layout = 'float',
                    relative = 'win',
                    width = math.min(vim.o.columns, 150), -- Fixed width in columns
                    height = 1.0,                         -- Fixed height in rows
                    row = 1,
                    col = vim.o.columns - math.min(vim.o.columns, 150),
                    border = 'double', -- 'single', 'double', 'rounded', 'solid'
                    title = '🤖 AI Assistant',
                    zindex = 100,      -- Ensure window stays on top

                },
                headers = {
                    user = '👤 You',
                    assistant = '🤖 Copilot',
                    tool = '🔧 Tool',

                },
                separator = '━━',
                auto_fold = true, -- Automatically folds non-assistant messages
            }

            require 'CopilotChat'.setup(opts)

            vim.opt.splitright = true

            -- Auto-command to customize chat buffer behavior
            vim.api.nvim_create_autocmd('BufEnter', {
                pattern = 'copilot-*',
                callback = function()
                    vim.opt_local.relativenumber = false
                    vim.opt_local.number = false
                    vim.opt_local.conceallevel = 0
                end,
            })
        end
    }
}
