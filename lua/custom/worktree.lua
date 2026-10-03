-- Review a linked git worktree in its own tab: a tab-local working directory roots unified.nvim, the pickers and
-- git commands there, while the other tabs and Claude Code stay in the directory nvim was started in
local M = {}

local group = vim.api.nvim_create_augroup('worktree', { clear = true })

-- Paths of the worktrees opened for review
local reviewed = {}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = 'Worktree' })
end

-- Run git, returning its trimmed output, or nil when it fails or the directory does not exist
local function git(args, cwd)
    local ok, res = pcall(function()
        return vim.system(vim.list_extend({ 'git' }, args), { text = true, cwd = cwd }):wait()
    end)
    return ok and res.code == 0 and vim.trim(res.stdout) or nil
end

-- All worktrees of the repository nvim was started in as { path, branch, name }, the main checkout first
local function worktrees()
    local out = git({ 'worktree', 'list', '--porcelain' }, vim.fn.getcwd(-1, -1))
    local list = {}
    for _, block in ipairs(vim.split(out or '', '\n\n', { trimempty = true })) do
        local path = block:match('^worktree ([^\n]+)')
        -- A worktree whose directory was deleted without `git worktree prune` is still listed
        if path and vim.fn.isdirectory(path) == 1 then
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
    local default = (git({ 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD' }, wt.path) or ''):match(
        '^origin/(.+)$'
    )
    local target = exists(default) and default or main.branch or 'main'
    local base = git({ 'merge-base', 'HEAD', target }, wt.path)
    -- A branch named like the stage's parent only is the parent when the stage left it after leaving the default
    -- branch, so `fix-issue-123` does not diff against an unrelated `fix-issue`
    local parent = wt.branch and wt.branch:match('^(.*)%-%d+$')
    if exists(parent) then
        local parent_base = git({ 'merge-base', 'HEAD', parent }, wt.path)
        local after_default = parent_base
            and parent_base ~= base
            and (not base or git({ 'merge-base', '--is-ancestor', base, parent_base }, wt.path) ~= nil)
        if after_default then
            target, base = parent, parent_base
        end
    end
    return base and git({ 'rev-parse', '--short', base }, wt.path), target
end

-- Whether the file lies below the directory. Both are compared with symbolic links resolved, as git resolves them
-- in the paths of the worktrees, while a buffer is named by the path it was opened with
local function is_below(file, dir)
    file = vim.uv.fs_realpath(file) or file
    dir = vim.uv.fs_realpath(dir) or dir
    return vim.startswith(file, dir .. '/')
end

-- Whether the file belongs to a worktree opened for review
function M.is_reviewed(file)
    for path in pairs(reviewed) do
        if is_below(file, path) then
            return true
        end
    end
    return false
end

-- Loaded buffers of the files below a worktree
local function buffers_in(path)
    return vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_loaded(buf) and is_below(vim.api.nvim_buf_get_name(buf), path)
    end, vim.api.nvim_list_bufs())
end

-- The agent working in a worktree owns its files, so a review must not edit them by accident, and no language
-- server indexes and checks a second copy of the workspace while the agent builds it
local function hold(buf)
    vim.bo[buf].readonly = true
    vim.bo[buf].modifiable = false
    -- Also the clients still starting, which attach once they are initialized
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, _uninitialized = true })) do
        pcall(vim.lsp.buf_detach_client, buf, client.id)
    end
end

local function release(buf)
    vim.bo[buf].readonly = false
    vim.bo[buf].modifiable = true
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

-- Hold the files of the worktree from now on, the ones opened before like the ones read later, and stop the
-- language servers started for the worktree, which detaching their buffers leaves running
local function review(path)
    if reviewed[path] then
        return
    end
    reviewed[path] = true
    for _, buf in ipairs(buffers_in(path)) do
        hold(buf)
    end
    local dir = vim.uv.fs_realpath(path) or path
    for _, client in ipairs(vim.lsp.get_clients({ _uninitialized = true })) do
        local root = client.root_dir and (vim.uv.fs_realpath(client.root_dir) or client.root_dir)
        if root and vim.fs.relpath(dir, root) then
            client:stop()
        end
    end
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
    review(wt.path)
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

-- A restored session brings back the tabs of the worktrees, with their working directory but neither the tab
-- variable nor the hold on their files, so the tabs in a linked worktree are taken under review again
local function adopt_tabs()
    local paths = {}
    for _, wt in ipairs(M.list()) do
        paths[vim.uv.fs_realpath(wt.path) or wt.path] = wt.path
    end
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local nr = vim.api.nvim_tabpage_get_number(tab)
        local cwd = vim.fn.getcwd(-1, nr)
        local path = paths[vim.uv.fs_realpath(cwd) or cwd]
        if path and vim.fn.haslocaldir(-1, nr) == 1 then
            vim.t[tab].worktree = path
            review(path)
        end
    end
end
vim.api.nvim_create_autocmd('SessionLoadPost', { group = group, callback = adopt_tabs })
-- A hook rather than the ResessionLoadPost event, which is scheduled: resession edits the current buffer after its
-- hooks, which starts its language servers unless the worktree is under review by then
local has_resession, resession = pcall(require, 'resession')
if has_resession then
    resession.add_hook('post_load', adopt_tabs)
end

-- A worktree no tab shows anymore is released: its files are editable and get a language server again
-- The reviewed worktree a tab is in. A tab split off one (`:tab split`) keeps its directory but not its tab variable,
-- which is set here, so the tab counts as showing the worktree
local function tab_worktree(tab)
    if vim.t[tab].worktree then
        return vim.t[tab].worktree
    end
    local nr = vim.api.nvim_tabpage_get_number(tab)
    if vim.fn.haslocaldir(-1, nr) ~= 1 then
        return nil
    end
    local cwd = vim.fn.getcwd(-1, nr)
    cwd = vim.uv.fs_realpath(cwd) or cwd
    for path in pairs(reviewed) do
        if (vim.uv.fs_realpath(path) or path) == cwd then
            vim.t[tab].worktree = path
            return path
        end
    end
end

vim.api.nvim_create_autocmd('TabNewEntered', {
    group = group,
    callback = function()
        tab_worktree(vim.api.nvim_get_current_tabpage())
    end,
})

vim.api.nvim_create_autocmd('TabClosed', {
    group = group,
    callback = function()
        local shown = {}
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
            shown[tab_worktree(tab) or ''] = true
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
