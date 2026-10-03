return {
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        keys = {
            -- Pickers
            {
                '<leader><Space>',
                function()
                    Snacks.picker.buffers()
                end,
                desc = 'List buffers',
            },
            {
                '<leader>ff',
                function()
                    Snacks.picker.files()
                end,
                desc = 'Find files',
            },
            {
                '<leader>fg',
                function()
                    Snacks.picker.grep()
                end,
                desc = 'Live grep',
            },
            {
                '<leader>fw',
                function()
                    Snacks.picker.grep_word()
                end,
                desc = 'Grep word',
                mode = { 'n', 'x' },
            },
            {
                '<leader>fz',
                function()
                    Snacks.picker.lines()
                end,
                desc = 'Fuzzy find in buffer',
            },
            {
                '<leader>fr',
                function()
                    Snacks.picker.recent()
                end,
                desc = 'Recent files',
            },
            {
                '<leader>fm',
                function()
                    Snacks.picker.marks()
                end,
                desc = 'Marks',
            },
            {
                '<leader>fh',
                function()
                    Snacks.picker.help()
                end,
                desc = 'Help tags',
            },
            {
                '<leader>ft',
                function()
                    Snacks.picker.tags()
                end,
                desc = 'Tags',
            },
            {
                '<leader>fk',
                function()
                    Snacks.picker.keymaps()
                end,
                desc = 'Keymaps',
            },
            {
                '<leader>fp',
                function()
                    Snacks.picker.resume()
                end,
                desc = 'Resume last picker',
            },
            {
                '<A-w>',
                function()
                    Snacks.picker.lsp_symbols({ filter = { default = { 'Function', 'Method' } } })
                end,
                desc = 'Show functions',
            },
            -- Explorer
            {
                '<leader>e',
                function()
                    Snacks.explorer()
                end,
                desc = 'Toggle file explorer',
            },
            {
                '<A-d>',
                function()
                    require('custom.terminals').toggle_tmux()
                end,
                mode = { 'n', 't' },
                desc = 'Toggle terminal',
            },
            {
                '<leader>ns',
                function()
                    Snacks.notifier.show_history()
                end,
                desc = 'Show notification history',
            },
        },
        ---@type snacks.Config
        opts = {
            dashboard = {
                preset = {
                    keys = {
                        { icon = ' ', key = 'f', desc = 'Find File', action = ':lua Snacks.picker.files()' },
                        { icon = ' ', key = '?', desc = 'Recents', action = ':lua Snacks.picker.recent()' },
                        { icon = ' ', key = 'w', desc = 'Find Word', action = ':lua Snacks.picker.grep()' },
                        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
                        { icon = ' ', key = 'b', desc = 'Bookmarks', action = ':lua Snacks.picker.marks()' },
                        {
                            icon = '󰸧 ',
                            key = 's',
                            desc = 'Load Last Session',
                            action = function()
                                require('custom.session').load()
                            end,
                        },
                        { icon = ' ', key = 'u', desc = 'Update Plugins', action = ':Lazy update' },
                        { icon = '󰗼 ', key = 'q', desc = 'Exit', action = ':qa' },
                    },
                },
                sections = {
                    { section = 'header' },
                    { section = 'keys', gap = 1, padding = 1 },
                    { section = 'startup' },
                },
            },
            notifier = {
                style = 'fancy',
                timeout = 6000,
            },
            picker = {},
            -- Directories are opened with oil
            explorer = { replace_netrw = false },
        },
        config = function(_, opts)
            require('snacks').setup(opts)
            ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
            local progress = vim.defaulttable()
            vim.api.nvim_create_autocmd('LspProgress', {
                group = vim.api.nvim_create_augroup('LspProgressNotify', { clear = true }),
                ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
                callback = function(ev)
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)
                    --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
                    local value = ev.data.params.value
                    if not client or type(value) ~= 'table' then
                        return
                    end
                    local p = progress[client.id]

                    for i = 1, #p + 1 do
                        if i == #p + 1 or p[i].token == ev.data.params.token then
                            p[i] = {
                                token = ev.data.params.token,
                                -- Servers that report no percentage get none shown until they are done
                                msg = ('%s%s%s'):format(
                                    (value.kind == 'end' or value.percentage)
                                            and ('[%3d%%] '):format(value.kind == 'end' and 100 or value.percentage)
                                        or '',
                                    value.title or '',
                                    value.message and (' **%s**'):format(value.message) or ''
                                ),
                                done = value.kind == 'end',
                            }
                            break
                        end
                    end

                    local msg = {} ---@type string[]
                    progress[client.id] = vim.tbl_filter(function(v)
                        return table.insert(msg, v.msg) or not v.done
                    end, p)

                    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
                    vim.notify(table.concat(msg, '\n'), vim.log.levels.INFO, {
                        id = 'lsp_progress',
                        title = client.name,
                        opts = function(notif)
                            notif.icon = #progress[client.id] == 0 and ' '
                                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                        end,
                    })
                end,
            })
        end,
    },
}
