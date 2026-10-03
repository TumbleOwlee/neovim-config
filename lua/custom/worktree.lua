-- Review a linked git worktree in its own tab: a tab-local working directory roots unified.nvim, the pickers and
-- git commands there, while the other tabs and Claude Code stay in the directory nvim was started in
local M = {}

local group = vim.api.nvim_create_augroup('worktree', { clear = true })

-- Paths of the worktrees opened for review
local reviewed = {}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = 'Worktree' })
end

local function git(args, cwd)
    local res = vim.system(vim.list_extend({ 'git' }, args), { text = true, cwd = cwd }):wait()
    return res.code == 0 and vim.trim(res.stdout) or nil
end

-- All worktrees of the repository nvim was started in as { path, branch, name }, the main checkout first
local function worktrees()
    local out = git({ 'worktree', 'list', '--porcelain' }, vim.fn.getcwd(-1, -1))
    local list = {}
    for _, block in ipairs(vim.split(out or '', '\n\n', { trimempty = true })) do
        local path = block:match('^worktree ([^\n]+)')
        if path then
            table.insert(list, {
                path = path,
                branch = block:match('\nbranch refs/heads/([^\n]+)'),
                name = vim.fs.basename(path),
            })
        end
    end
    return list
end

-- Linked worktrees, without the main checkout
function M.list()
    return vim.list_slice(worktrees(), 2)
end

-- The commit the worktree's branch started from: on the feature branch for the worktree of a parallel stage
-- (`<branch>-<n>` next to an existing `<branch>`), else on the default branch
local function branch_point(wt, main)
    local function exists(branch)
        return branch and git({ 'rev-parse', '--verify', '--quiet', 'refs/heads/' .. branch }, wt.path) ~= nil
    end
    local parent = wt.branch and wt.branch:match('^(.*)%-%d+$')
    local default = (git({ 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD' }, wt.path) or ''):match(
        '^origin/(.+)$'
    )
    local target = exists(parent) and parent or exists(default) and default or main.branch or 'main'
    local base = git({ 'merge-base', 'HEAD', target }, wt.path)
    return base and git({ 'rev-parse', '--short', base }, wt.path), target
end

-- Whether the file belongs to a worktree opened for review
function M.is_reviewed(file)
    for path in pairs(reviewed) do
        if vim.startswith(file, path .. '/') then
            return true
        end
    end
    return false
end

-- Loaded buffers of the files below a worktree
local function buffers_in(path)
    return vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_loaded(buf) and vim.startswith(vim.api.nvim_buf_get_name(buf), path .. '/')
    end, vim.api.nvim_list_bufs())
end

-- The agent working in a worktree owns its files, so a review must not edit them by accident, and no language
-- server indexes and checks a second copy of the workspace while the agent builds it
local function hold(buf)
    vim.bo[buf].readonly = true
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        vim.lsp.buf_detach_client(buf, client.id)
    end
end

local function release(buf)
    vim.bo[buf].readonly = false
    -- Start the language servers the buffer would have got when it was read
    pcall(vim.api.nvim_buf_call, buf, function()
        vim.cmd.doautocmd('nvim.lsp.enable FileType')
    end)
end

-- vim.lsp.enable() has no way to skip a buffer, so every server start is checked here, which keeps servers
-- from Mason, plugins and after/lsp/ alike out of the worktrees under review
local lsp_start = vim.lsp.start
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.start = function(config, opts)
    local buf = opts and opts.bufnr or vim.api.nvim_get_current_buf()
    if buf == 0 then
        buf = vim.api.nvim_get_current_buf()
    end
    if M.is_reviewed(vim.api.nvim_buf_get_name(buf)) then
        return nil
    end
    return lsp_start(config, opts)
end

-- Open the worktree, given by directory name, branch or path, in its own tab with the diff of everything its
-- branch changed. With `stage`, the diff is the last commit and the uncommitted changes on top of it only
function M.open(name, stage)
    local all = worktrees()
    local main = all[1]
    local wt = vim.iter(all):skip(1):find(function(w)
        return w.name == name or w.branch == name or w.path == vim.fs.normalize(vim.fn.fnamemodify(name, ':p'))
    end)
    if not wt then
        notify(('No worktree %s'):format(name), vim.log.levels.ERROR)
        return
    end
    local base, target
    if stage then
        base = git({ 'rev-parse', '--verify', '--quiet', 'HEAD~1' }, wt.path)
    else
        base, target = branch_point(wt, main)
    end
    if not base then
        notify(('Cannot determine the base commit of %s'):format(wt.name), vim.log.levels.ERROR)
        return
    end

    local tab = vim.iter(vim.api.nvim_list_tabpages()):find(function(t)
        return vim.t[t].worktree == wt.path
    end)
    if tab then
        vim.api.nvim_set_current_tabpage(tab)
    else
        vim.cmd.tabnew()
        vim.cmd.tcd(vim.fn.fnameescape(wt.path))
        vim.t.worktree = wt.path
    end
    if not reviewed[wt.path] then
        reviewed[wt.path] = true
        -- Files of the worktree opened before are held like the ones read from now on
        for _, buf in ipairs(buffers_in(wt.path)) do
            hold(buf)
        end
    end
    vim.cmd({ cmd = 'Unified', args = { base } })
    notify(
        ('%s (%s): %s'):format(
            wt.name,
            wt.branch or 'detached',
            stage and 'changes of the last commit' or ('changes since it left %s'):format(target)
        )
    )
end

function M.pick(stage)
    local list = M.list()
    -- A session following one run only reviews its worktrees: `<slug>`, or `<slug>-<n>` per parallel stage
    local focus = require('custom.board').focused()
    if focus then
        list = vim.tbl_filter(function(wt)
            return wt.name == focus or wt.name:match('^' .. vim.pesc(focus) .. '%-%d+$') ~= nil
        end, list)
    end
    if #list == 0 then
        notify('No linked worktrees')
    elseif #list == 1 then
        M.open(list[1].path, stage)
    else
        vim.ui.select(list, {
            prompt = 'Worktree',
            format_item = function(wt)
                return ('%s  %s'):format(wt.name, wt.branch or 'detached')
            end,
        }, function(wt)
            if wt then
                M.open(wt.path, stage)
            end
        end)
    end
end

vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    callback = function(ev)
        if M.is_reviewed(vim.api.nvim_buf_get_name(ev.buf)) then
            hold(ev.buf)
        end
    end,
})

-- A worktree no tab shows anymore is released: its files are editable and get a language server again
vim.api.nvim_create_autocmd('TabClosed', {
    group = group,
    callback = function()
        local shown = {}
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
            shown[vim.t[tab].worktree or ''] = true
        end
        for path in pairs(reviewed) do
            if not shown[path] then
                reviewed[path] = nil
                for _, buf in ipairs(buffers_in(path)) do
                    release(buf)
                end
            end
        end
    end,
})

vim.api.nvim_create_user_command('Worktree', function(opts)
    local name, stage = opts.fargs[1], opts.fargs[#opts.fargs] == 'stage'
    if not name or (stage and #opts.fargs == 1) then
        M.pick(stage)
    else
        M.open(name, stage)
    end
end, {
    nargs = '*',
    desc = 'Review a git worktree in its own tab; `stage` limits the diff to its last commit',
    complete = function(lead)
        local candidates = vim.tbl_map(function(wt)
            return wt.name
        end, M.list())
        table.insert(candidates, 'stage')
        return vim.tbl_filter(function(s)
            return s:sub(1, #lead) == lead
        end, candidates)
    end,
})

vim.keymap.set('n', '<leader>gw', M.pick, { desc = 'Review a worktree' })

return M
