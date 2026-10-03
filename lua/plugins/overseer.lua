return {
    {
        'stevearc/resession.nvim',
        -- Must be loaded before VimEnter to restore the directory session
        lazy = false,
        keys = {
            {
                '<leader>ss',
                function()
                    require('custom.session').save(true)
                end,
                desc = 'Save session',
            },
            {
                '<leader>sl',
                function()
                    require('custom.session').load()
                end,
                desc = 'Load session',
            },
        },
        config = function()
            local opts = {
                -- Saved by the autocmds below instead, which keep a session from being replaced by an empty one
                autosave = {
                    enabled = false,
                },
                options = {
                    'binary',
                    'bufhidden',
                    'buflisted',
                    'cmdheight',
                    'diff',
                    'filetype',
                    -- Not 'modifiable' and 'readonly': files of a worktree under review are held, which
                    -- custom.worktree does again for a restored worktree tab, and a held file must not stay so
                    -- once the worktree is gone
                    'previewwindow',
                    'scrollbind',
                    'winfixheight',
                    'winfixwidth',
                },
                load_detail = true,
                load_order = 'modification_time',
                extensions = {
                    overseer = {},
                },
            }

            local resession = require('resession')
            resession.setup(opts)

            -- Directory sessions only when nvim is started without file args, stdin or UI (headless)
            local function use_dir_session()
                return vim.fn.argc(-1) == 0 and not vim.g.using_stdin and #vim.api.nvim_list_uis() > 0
            end
            -- Don't replace a session with an empty one (e.g. `nvim +SyncInstall +qall`)
            local function has_file_buffers()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[buf].buflisted and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= '' then
                        return true
                    end
                end
                return false
            end
            local group = vim.api.nvim_create_augroup('DirSession', { clear = true })
            vim.api.nvim_create_autocmd('VimEnter', {
                group = group,
                callback = function()
                    if use_dir_session() then
                        -- Save these to a different directory, so our manual sessions don't get polluted.
                        -- A restored session means the dashboard (empty buffer only) is not shown.
                        require('custom.session').load()
                    end
                end,
                nested = true,
            })
            local function autosave()
                -- Saving visits every tab, which ends Visual, Select and Operator-pending mode, so it waits for the
                -- next time then
                local mode = vim.api.nvim_get_mode().mode
                if mode:match('^[vVsS\22\19]') or mode:match('^no') then
                    return
                end
                if use_dir_session() and has_file_buffers() then
                    require('custom.session').save(false)
                end
            end
            vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = autosave })
            local timer = assert(vim.uv.new_timer())
            timer:start(60000, 60000, vim.schedule_wrap(autosave))
            vim.api.nvim_create_autocmd('StdinReadPre', {
                group = group,
                callback = function()
                    -- Store this for later
                    vim.g.using_stdin = true
                end,
            })
        end,
    },
    {
        'stevearc/overseer.nvim',
        cmd = {
            'Grep',
            'Make',
            'CMake',
            'Run',
            'OverseerRestartLast',
            'OverseerOpen',
            'OverseerRun',
            'OverseerShell',
            'OverseerTaskAction',
            'OverseerToggle',
            'OverseerTestOutput',
        },
        keys = {
            { '<leader>ol', '<cmd>OverseerRestartLast<CR>', mode = 'n', desc = '[O]verseer Restart [L]ast' },
            { '<leader>oo', '<cmd>OverseerToggle! bottom<CR>', mode = 'n', desc = '[O]verseer [O]pen' },
            { '<leader>or', '<cmd>OverseerRun<CR>', mode = 'n', desc = '[O]verseer [R]un' },
            { '<leader>os', '<cmd>OverseerShell<CR>', mode = 'n', desc = '[O]verseer [S]hell' },
            { '<leader>ot', '<cmd>OverseerTaskAction<CR>', mode = 'n', desc = '[O]verseer [T]ask action' },
            {
                '<leader>od',
                function()
                    local overseer = require('overseer')
                    local task_list = require('overseer.task_list')
                    local tasks = overseer.list_tasks({
                        sort = task_list.sort_finished_recently,
                        include_ephemeral = true,
                    })
                    if vim.tbl_isempty(tasks) then
                        vim.notify('No tasks found', vim.log.levels.WARN)
                    else
                        local most_recent = tasks[1]
                        overseer.run_action(most_recent)
                    end
                end,
                mode = 'n',
                desc = '[O]verseer [D]o quick action',
            },
        },
        ---@module 'overseer'
        ---@type overseer.SetupOpts
        opts = {
            dap = false,
            component_aliases = {
                default = {
                    'on_exit_set_status',
                    { 'on_complete_notify', system = 'unfocused' },
                    { 'on_complete_dispose', require_view = { 'SUCCESS', 'FAILURE' } },
                    -- Show task output in a float when a task starts, unless it fills the quickfix list (:Grep)
                    { 'open_output', direction = 'float', on_start = 'if_no_on_output_quickfix' },
                },
                default_neotest = {
                    'unique',
                    { 'on_complete_notify', system = 'unfocused', on_change = true },
                    'default',
                },
            },
            experimental_wrap_builtins = {
                enabled = false,
            },
            task_list = {
                direction = 'bottom',
            },
            form = {
                border = 'rounded',
            },
            task_win = {
                border = 'rounded',
                padding = 2,
            },
        },
        init = function()
            vim.cmd.cnoreabbrev('OS OverseerShell')
        end,
        config = function(_, opts)
            local overseer = require('overseer')
            overseer.setup(opts)
            vim.api.nvim_create_user_command('OverseerTestOutput', function()
                vim.cmd.tabnew()
                vim.bo.bufhidden = 'wipe'
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
                desc = 'Open a new tab that displays the output of the most recent test',
            })
            vim.api.nvim_create_user_command('Grep', function(params)
                local args = vim.fn.expandcmd(params.args)
                -- Insert args at the '$*' in the grepprg, as is: a replacement string would treat `%` as special
                local cmd, num_subs = vim.o.grepprg:gsub('%$%*', function()
                    return args
                end)
                if num_subs == 0 then
                    cmd = cmd .. ' ' .. args
                end
                local cwd
                local has_oil, oil = pcall(require, 'oil')
                if has_oil then
                    cwd = oil.get_current_dir()
                end

                local task = overseer.new_task({
                    cmd = cmd,
                    cwd = cwd,
                    name = 'grep ' .. args,
                    components = {
                        {
                            'on_output_quickfix',
                            errorformat = vim.o.grepformat,
                            open = not params.bang,
                            open_height = 8,
                            items_only = true,
                        },
                        -- We don't care to keep this around as long as most tasks
                        { 'on_complete_dispose', timeout = 30, require_view = {} },
                        'default',
                    },
                })
                task:start()
            end, { nargs = '*', bang = true, complete = 'file' })

            vim.api.nvim_create_user_command('Make', function(params)
                -- Insert args at the '$*' in the makeprg, as is: a replacement string would treat `%` as special
                local cmd, num_subs = vim.o.makeprg:gsub('%$%*', function()
                    return params.args
                end)
                if num_subs == 0 then
                    cmd = cmd .. ' ' .. params.args
                end
                -- Expanded once, as backticks run a shell command
                cmd = vim.fn.expandcmd(cmd)
                local task = require('overseer').new_task({
                    cmd = cmd,
                    components = {
                        'unique',
                        'default',
                    },
                })
                task:start()
                vim.notify("Start '" .. cmd .. "'", vim.log.levels.INFO, { title = 'Make' })
            end, {
                desc = 'Run your makeprg as an Overseer task',
                nargs = '*',
            })

            vim.api.nvim_create_user_command('OverseerRestartLast', function()
                local overseer = require('overseer')
                local task_list = require('overseer.task_list')
                local tasks = overseer.list_tasks({
                    status = {
                        overseer.STATUS.SUCCESS,
                        overseer.STATUS.FAILURE,
                        overseer.STATUS.CANCELED,
                    },
                    sort = task_list.sort_finished_recently,
                })
                if vim.tbl_isempty(tasks) then
                    vim.notify('No tasks found', vim.log.levels.WARN)
                else
                    local most_recent = tasks[1]
                    overseer.run_action(most_recent, 'restart')
                end
            end, {})

            vim.api.nvim_create_user_command('CMake', function(params)
                -- Insert args at the '$*' in the makeprg
                local cmd = 'cmake'
                if params.args:len() > 0 then
                    cmd = cmd .. ' ' .. params.args
                end
                cmd = vim.fn.expandcmd(cmd)
                local task = require('overseer').new_task({
                    cmd = cmd,
                    components = {
                        'unique',
                        'default',
                    },
                })
                task:start()
                vim.notify("Start '" .. cmd .. "'", vim.log.levels.INFO, { title = 'CMake' })
            end, {
                desc = 'Run your CMake command as an Overseer task',
                nargs = '*',
            })

            vim.api.nvim_create_user_command('Run', function(params)
                if params.args:len() == 0 then
                    vim.notify('No command specified!', vim.log.levels.ERROR, { title = 'Run' })
                    return
                end
                local cmd = vim.fn.expandcmd(params.args)
                local task = overseer.new_task({
                    cmd = cmd,
                    components = {
                        'unique',
                        'default',
                    },
                })
                task:start()
                vim.notify("Start '" .. cmd .. "'", vim.log.levels.INFO, { title = 'Overseer Run' })
            end, {
                desc = 'Run command as an Overseer task',
                nargs = '*',
            })
        end,
    },
}
