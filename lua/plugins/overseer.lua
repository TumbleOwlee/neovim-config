return {
    {
        "stevearc/resession.nvim",
        lazy = true,
        config = function()
            local opts = {
                autosave = {
                    enabled = true,
                    interval = 60,
                    notify = true,
                },
                options = {
                    "binary",
                    "bufhidden",
                    "buflisted",
                    "cmdheight",
                    "diff",
                    "filetype",
                    "modifiable",
                    "previewwindow",
                    "readonly",
                    "scrollbind",
                    "winfixheight",
                    "winfixwidth",
                },
                load_detail = true,
                load_order = "modification_time",
                extensions = {
                    overseer = {
                    },
                },
            }

            local resession = require 'resession'
            resession.setup(opts)
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    -- Only load the session if nvim was started with no args and without reading from stdin
                    if vim.fn.argc(-1) == 0 and not vim.g.using_stdin then
                        -- Save these to a different directory, so our manual sessions don't get polluted
                        resession.load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true })
                    end
                end,
                nested = true,
            })
            vim.api.nvim_create_autocmd("VimLeavePre", {
                callback = function()
                    resession.save(vim.fn.getcwd(), { dir = "dirsession", notify = true })
                end,
            })
            vim.api.nvim_create_autocmd('StdinReadPre', {
                callback = function()
                    -- Store this for later
                    vim.g.using_stdin = true
                end,
            })
        end,
    },
    {
        'ibhagwan/fzf-lua',
        opts = {},
        config = function()
            require 'fzf-lua'.setup({})
            require 'fzf-lua'.register_ui_select()
        end
    },
    {
        "stevearc/overseer.nvim",
        dependencies = {
            'ibhagwan/fzf-lua',
        },
        cmd = {
            "Grep",
            "Make",
            "CMake",
            "OverseerOpen",
            "OverseerRun",
            "OverseerToggle",
            "OverseerTestOutput",
        },
        keys = {
            { "<leader>oo", "<cmd>OverseerRestartLast<CR>",    mode = "n", desc = "[O]verseer Restart [L]ast" },
            { "<leader>oo", "<cmd>OverseerToggle! bottom<CR>", mode = "n", desc = "[O]verseer [O]pen" },
            { "<leader>or", "<cmd>OverseerRun<CR>",            mode = "n", desc = "[O]verseer [R]un" },
            { "<leader>os", "<cmd>OverseerShell<CR>",          mode = "n", desc = "[O]verseer [S]hell" },
            { "<leader>ot", "<cmd>OverseerTaskAction<CR>",     mode = "n", desc = "[O]verseer [T]ask action" },
            {
                "<leader>od",
                function()
                    local overseer = require("overseer")
                    local task_list = require("overseer.task_list")
                    local tasks = overseer.list_tasks({
                        sort = task_list.sort_finished_recently,
                        include_ephemeral = true,
                    })
                    if vim.tbl_isempty(tasks) then
                        vim.notify("No tasks found", vim.log.levels.WARN)
                    else
                        local most_recent = tasks[1]
                        overseer.run_action(most_recent)
                    end
                end,
                mode = "n",
                desc = "[O]verseer [D]o quick action",
            },
        },
        ---@module 'overseer'
        ---@type overseer.SetupOpts
        opts = {
            dap = false,
            log_level = vim.log.levels.TRACE,
            component_aliases = {
                default = {
                    "on_exit_set_status",
                    { "on_complete_notify",  system = "unfocused" },
                    { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
                },
                default_neotest = {
                    "unique",
                    { "on_complete_notify", system = "unfocused", on_change = true },
                    "default",
                },
            },
            wrap_builtins = {
                enabled = false,
                partial_condition = {
                    noop = function(cmd, caller, opts) return true end,
                },
            },
            post_setup = {},
            task_list = {
                direction = "float",
            },
            form = {
                border = "rounded",
            },
            task_win = {
                border = "rounded",
                padding = 2,
            },
            strategy = {
                "terminal",
                use_shell = true,
                direction = "float",
                autoshow  = "on_load",
            },
        },
        init = function() vim.cmd.cnoreabbrev("OS OverseerShell") end,
        config = function(_, opts)
            local partial = opts.wrap_builtins.partial_condition
            opts.wrap_builtins.condition = function(cmd, caller, opts)
                for _, v in pairs(partial) do
                    if not v(cmd, caller, opts) then
                        return false
                    end
                end
                return true
            end
            local overseer = require("overseer")
            overseer.setup(opts)
            for _, cb in pairs(opts.post_setup) do
                cb()
            end
            vim.api.nvim_create_user_command("OverseerTestOutput", function(params)
                vim.cmd.tabnew()
                vim.bo.bufhidden = "wipe"
                overseer.create_task_output_view(0, {
                    select = function(self, tasks)
                        for _, task in ipairs(tasks) do
                            if task.metadata.neotest_group_id then
                                return task
                            end
                        end
                        self:dispose()
                    end,
                })
            end, {
                desc = "Open a new tab that displays the output of the most recent test",
            })
            vim.api.nvim_create_user_command("Grep", function(params)
                local args = vim.fn.expandcmd(params.args)
                -- Insert args at the '$*' in the grepprg
                local cmd, num_subs = vim.o.grepprg:gsub("%$%*", args)
                if num_subs == 0 then
                    cmd = cmd .. " " .. args
                end
                local cwd
                local has_oil, oil = pcall(require, "oil")
                if has_oil then
                    cwd = oil.get_current_dir()
                end

                local task = overseer.new_task({
                    cmd = cmd,
                    cwd = cwd,
                    name = "grep " .. args,
                    components = {
                        {
                            "on_output_quickfix",
                            errorformat = vim.o.grepformat,
                            open = not params.bang,
                            open_height = 8,
                            items_only = true,
                        },
                        -- We don't care to keep this around as long as most tasks
                        { "on_complete_dispose", timeout = 30, require_view = {} },
                        "default",
                    },
                })
                task:start()
            end, { nargs = "*", bang = true, bar = true, complete = "file" })

            vim.api.nvim_create_user_command("Make", function(params)
                -- Insert args at the '$*' in the makeprg
                local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)
                if num_subs == 0 then
                    cmd = cmd .. " " .. params.args
                end
                local task = require("overseer").new_task({
                    cmd = vim.fn.expandcmd(cmd),
                    components = {
                        "unique",
                        "default",
                    },
                })
                task:start()
                vim.notify("Start '" .. vim.fn.expandcmd(cmd) .. "'", vim.log.levels.INFO, { title = "Make" })
            end, {
                desc = "Run your makeprg as an Overseer task",
                nargs = "*",
                bang = true,
            })

            vim.api.nvim_create_user_command("OverseerRestartLast", function()
                local overseer = require("overseer")
                local task_list = require("overseer.task_list")
                local tasks = overseer.list_tasks({
                    status = {
                        overseer.STATUS.SUCCESS,
                        overseer.STATUS.FAILURE,
                        overseer.STATUS.CANCELED,
                    },
                    sort = task_list.sort_finished_recently
                })
                if vim.tbl_isempty(tasks) then
                    vim.notify("No tasks found", vim.log.levels.WARN)
                else
                    local most_recent = tasks[1]
                    overseer.run_action(most_recent, "restart")
                end
            end, {})

            vim.api.nvim_create_user_command("CMake", function(params)
                -- Insert args at the '$*' in the makeprg
                local cmd = "cmake"
                if params.args:len() > 0 then
                    cmd = cmd .. " " .. params.args
                end
                local task = require("overseer").new_task({
                    cmd = vim.fn.expandcmd(cmd),
                    components = {
                        "unique",
                        "default",
                    },
                })
                task:start()
                vim.notify("Start '" .. vim.fn.expandcmd(cmd) .. "'", vim.log.levels.INFO, { title = "CMake" })
            end, {
                desc = "Run your makeprg as an Overseer task",
                nargs = "*",
                bang = true,
            })
        end,
    },
}
