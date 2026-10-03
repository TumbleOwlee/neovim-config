-- Follows a file based task board (`.claude/tasks/`) on the status line and the window bar: the directory a card
-- sits in is its state, the card itself is YAML frontmatter followed by an append-only log
local M = {}

local group = vim.api.nvim_create_augroup('board', { clear = true })

local states = { 'open', 'inprogress', 'inreview', 'done' }
local state = {
    root = nil, -- the tasks directory, nil without a board
    watchers = {}, -- directory -> watcher
    timer = nil,
    cards = {}, -- id -> { id, slug, label, state, fields, ready }
    winbar = '', -- the steps of the followed run, shown above every file window
    focus = nil, -- slug of the only run this session shows, nil for all runs
    approvals = {}, -- slug -> { marker, paths, name, mtime } of the files waiting for the user's approval
}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = 'Task board' })
end

local function read_card(path, card_state)
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok then
        return nil
    end
    local id = vim.fn.fnamemodify(path, ':t:r')
    local fields, ready, fences = {}, false, 0
    for _, line in ipairs(lines) do
        if line == '---' and fences < 2 then
            fences = fences + 1
        elseif fences == 1 then
            local key, value = line:match('^([%w_-]+):%s*(.-)%s*$')
            if key then
                fields[key] = value
            end
        else
            ready = ready or line:find('pr=ready', 1, true) ~= nil
        end
    end
    local slug, label = id:match('^(.*)%.([sw]%d+)$')
    return {
        id = id,
        slug = slug or id,
        label = label,
        state = card_state,
        fields = fields,
        ready = ready, -- whether the log tells that the pull request left its draft state
    }
end

local function scan()
    local cards = {}
    for _, s in ipairs(states) do
        for _, path in ipairs(vim.fn.glob(state.root .. '/' .. s .. '/*.md', true, true)) do
            local card = read_card(path, s)
            if card and (not state.focus or card.slug == state.focus) then
                cards[card.id] = card
            end
        end
    end
    return cards
end

-- Files waiting for approval: the marker `artifacts/<slug>/approval` holds their paths, one per line, and is
-- removed once they were opened from here
local function scan_approvals()
    local approvals = {}
    for _, marker in ipairs(vim.fn.glob(state.root .. '/artifacts/*/approval', true, true)) do
        local slug = vim.fs.basename(vim.fs.dirname(marker))
        local ok, lines = pcall(vim.fn.readfile, marker)
        local stat = vim.uv.fs_stat(marker)
        local paths = ok and vim.tbl_filter(function(line)
            return line ~= ''
        end, lines) or {}
        if stat and #paths > 0 and (not state.focus or slug == state.focus) then
            approvals[slug] = {
                marker = marker,
                paths = paths,
                name = table.concat(vim.tbl_map(vim.fs.basename, paths), ', '),
                mtime = ('%d.%d'):format(stat.mtime.sec, stat.mtime.nsec),
            }
        end
    end
    return approvals
end

-- Runs as a sorted list of { slug, parent, stages }, the stages in the order of their number
local function runs()
    local by_slug = {}
    for _, card in pairs(state.cards) do
        local run = by_slug[card.slug] or { slug = card.slug, stages = {} }
        by_slug[card.slug] = run
        if card.label then
            table.insert(run.stages, card)
        else
            run.parent = card
        end
    end
    local list = vim.tbl_values(by_slug)
    table.sort(list, function(a, b)
        return a.slug < b.slug
    end)
    for _, run in ipairs(list) do
        table.sort(run.stages, function(a, b)
            local kind_a, kind_b = a.label:sub(1, 1), b.label:sub(1, 1)
            if kind_a ~= kind_b then
                return kind_a < kind_b
            end
            return tonumber(a.label:sub(2)) < tonumber(b.label:sub(2))
        end)
    end
    return list
end

------------------------------------------------------------------------------------------------------------------------
-- Steps
------------------------------------------------------------------------------------------------------------------------

-- Colors of the steps by status, taken from the colorscheme
local function step_colors()
    local function color(name, attr, fallback)
        return vim.api.nvim_get_hl(0, { name = name, link = false })[attr] or fallback
    end
    return {
        open = color('Normal', 'fg', 0xd0d0d0),
        inprogress = color('DiagnosticOk', 'fg', 0x98c379),
        inreview = color('DiagnosticWarn', 'fg', 0xe5c07b),
        approval = color('DiagnosticError', 'fg', 0xe06c75),
        done = color('Comment', 'fg', 0x7f848e),
        text = color('Normal', 'bg', 0x1e1e1e),
        bar = vim.api.nvim_get_hl(0, { name = 'WinBar', link = false }).bg,
    }
end

-- Mix a color with another one, `ratio` being the share of the other
local function blend(color, other, ratio)
    local result = 0
    for shift = 16, 0, -8 do
        local c, o = bit.band(bit.rshift(color, shift), 0xff), bit.band(bit.rshift(other, shift), 0xff)
        result = result + bit.lshift(math.floor(c + (o - c) * ratio + 0.5), shift)
    end
    return result
end

-- The highlight group for a foreground on a background, created when first used
local function step_hl(fg, bg, bold)
    local name = ('BoardStep_%06x_%s'):format(fg, bg and ('%06x'):format(bg) or 'none')
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg, bold = bold })
    return name
end

local function is_set(value)
    return value ~= nil and value ~= ''
end

-- The steps of a run from its first gate to its pull request as { label, status }, the status being a card
-- state or `approval`. A run that changes no spec has neither a spec nor an issue step
local function steps(run, approval)
    local parent = run.parent
    local f = parent and parent.fields or {}
    local planned = is_set(f.gate2)
    local spec_approved = is_set(f.gate1) and f.gate1 ~= 'skipped'
    local spec_skipped = f.gate1 == 'skipped' or (planned and not is_set(f.gate1))

    local list, by_file = {}, {}
    local function add(label, status)
        table.insert(list, { label = label, status = status })
        return list[#list]
    end
    if not spec_skipped then
        by_file['spec-diff.md'] = add('Spec', spec_approved and 'done' or 'inprogress')
        local issue = add('Issue', is_set(f.issue) and 'done' or spec_approved and 'inprogress' or 'open')
        by_file['issue.md'], by_file['issue-comment.md'] = issue, issue
    end
    local plan_started = spec_skipped or is_set(f.issue)
    local plan = add('Plan', planned and 'done' or plan_started and 'inprogress' or 'open')
    by_file['plan.summary.md'] = plan

    local reviewing, stages, done = {}, 0, 0
    for _, card in ipairs(run.stages) do
        if card.label:sub(1, 1) == 's' then
            local step = add(is_set(card.fields.title) and card.fields.title or card.label, card.state)
            stages = stages + 1
            done = done + (card.state == 'done' and 1 or 0)
            if card.state == 'inreview' then
                table.insert(reviewing, step)
            end
        end
    end
    local merged = parent ~= nil and parent.state == 'done'
    local ready = parent ~= nil and parent.ready
    local implemented = stages > 0 and done == stages
    local review = add('Review', (ready or merged) and 'done' or implemented and 'inreview' or 'open')
    local pr = add('PR', merged and 'done' or ready and 'inprogress' or 'open')
    by_file['pr.md'] = pr

    for _, path in ipairs(approval and approval.paths or {}) do
        local name = vim.fs.basename(path)
        local waiting = { by_file[name] or pr }
        -- The verdict is shown for the plan, for a stage and for the whole branch
        if name == 'review.verdict.md' then
            waiting = not planned and { plan } or #reviewing > 0 and reviewing or { review }
        end
        for _, step in ipairs(waiting) do
            step.status = 'approval'
        end
    end
    return list
end

-- A window gets the bar if it shows a file and has no bar of its own. Without a focus, the bar shows the first
-- run and names it, followed by the number of the other runs
local function update_winbar()
    local all = runs()
    local run = all[1]
    local expr = "%{%v:lua.require'custom.board'.winbar()%}"
    state.winbar = ''
    if run then
        -- Every step is a block in the color of its status that ends in an arrow into the next block. A step
        -- with the status of the one before it is shaded, so the two stay apart
        local colors = step_colors()
        local blocks, previous = {}, nil
        for _, step in ipairs(steps(run, state.approvals[run.slug])) do
            local shaded = previous ~= nil and previous.status == step.status and not previous.shaded
            local bg = colors[step.status]
            previous = {
                status = step.status,
                shaded = shaded,
                bg = shaded and blend(bg, colors.text, 0.3) or bg,
                label = vim.fn.toupper(step.label):gsub('%%', '%%%%'),
            }
            table.insert(blocks, previous)
        end
        local parts = { '%<' }
        if #all > 1 then
            table.insert(parts, ('%%#WinBar# %s (+%d) '):format(run.slug:gsub('%%', '%%%%'), #all - 1))
        end
        for i, block in ipairs(blocks) do
            local next_bg = blocks[i + 1] and blocks[i + 1].bg or colors.bar
            table.insert(
                parts,
                ('%%#%s# %s %%#%s#%s'):format(
                    step_hl(colors.text, block.bg, true),
                    block.label,
                    step_hl(block.bg, next_bg),
                    '\u{e0b0}'
                )
            )
        end
        state.winbar = table.concat(parts) .. '%*'
    end
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local is_file = vim.api.nvim_win_get_config(win).relative == '' and vim.bo[buf].buftype == ''
        local current = vim.wo[win].winbar
        if run and is_file and current == '' then
            vim.wo[win][0].winbar = expr
        elseif current == expr and not (run and is_file) then
            vim.wo[win][0].winbar = ''
        end
    end
end

function M.winbar()
    return state.winbar
end

-- Bring the status line and the window bars up to date with the board
local function refresh_bars()
    update_winbar()
    pcall(function()
        require('lualine').refresh()
    end)
end

local refresh

local function start_watcher(dir)
    local watcher = assert(vim.uv.new_fs_event())
    -- A moving card changes two directories and an agent appends to its card line by line
    local ok = watcher:start(dir, {}, function()
        state.timer:start(100, 0, vim.schedule_wrap(refresh))
    end)
    if ok then
        return watcher
    end
    watcher:close()
end

-- Watch the tasks directory, the directories of the states and the artifact directory of every run, as far as
-- they exist. The marker of a run lies in its artifact directory, which exists only once the run started, and the
-- tasks directory tells when another directory is created
local function watch_dirs()
    local dirs = { [state.root] = true }
    for _, name in ipairs(vim.list_extend({ 'artifacts' }, states)) do
        local dir = state.root .. '/' .. name
        if vim.fn.isdirectory(dir) == 1 then
            dirs[dir] = true
        end
    end
    for _, dir in ipairs(vim.fn.glob(state.root .. '/artifacts/*/', true, true)) do
        dir = dir:gsub('/$', '')
        if not state.focus or vim.fs.basename(dir) == state.focus then
            dirs[dir] = true
        end
    end
    for dir, watcher in pairs(state.watchers) do
        if not dirs[dir] then
            watcher:stop()
            watcher:close()
            state.watchers[dir] = nil
        end
    end
    for dir in pairs(dirs) do
        state.watchers[dir] = state.watchers[dir] or start_watcher(dir)
    end
end

function refresh()
    if not state.root then
        return
    end
    local approvals = scan_approvals()
    for slug, approval in pairs(approvals) do
        local before = state.approvals[slug]
        if not before or before.mtime ~= approval.mtime then
            notify(('%s of %s: approval needed, open with <leader>ba'):format(approval.name, slug), vim.log.levels.WARN)
        end
    end
    state.approvals = approvals
    watch_dirs()

    state.cards = scan()
    refresh_bars()
end

local function unwatch()
    for _, watcher in pairs(state.watchers) do
        watcher:stop()
        watcher:close()
    end
    state.watchers = {}
end

-- Take the board as it is now, without announcing the approvals already waiting
local function load()
    state.cards = scan()
    state.approvals = scan_approvals()
    watch_dirs()
    refresh_bars()
end

-- Follow the board of the directory nvim runs in, if it has one
local function watch()
    unwatch()
    local root = vim.fn.getcwd(-1, -1) .. '/.claude/tasks'
    state.root = vim.fn.isdirectory(root) == 1 and root or nil
    state.cards, state.approvals = {}, {}
    if not state.root then
        refresh_bars()
        return
    end
    state.timer = state.timer or assert(vim.uv.new_timer())
    load()
end

------------------------------------------------------------------------------------------------------------------------
-- Status line
------------------------------------------------------------------------------------------------------------------------

function M.has_cards()
    return next(state.cards) ~= nil
end

-- Every run with the stages being worked on and its progress, e.g. `󰨇 tab-bar-fill ▸ s3 inreview · 2/5`
function M.status()
    local parts = {}
    for _, run in ipairs(runs()) do
        local active, done, total = {}, 0, 0
        for _, card in ipairs(run.stages) do
            if card.label:sub(1, 1) == 's' then
                total = total + 1
                done = done + (card.state == 'done' and 1 or 0)
            end
            if card.state == 'inprogress' or card.state == 'inreview' then
                table.insert(active, card.label .. ' ' .. card.state)
            end
        end
        local now = #active > 0 and table.concat(active, ', ') or run.parent and run.parent.state or ''
        local progress = total > 0 and (' · %d/%d'):format(done, total) or ''
        table.insert(parts, ('%s ▸ %s%s'):format(run.slug, now, progress))
    end
    return #parts > 0 and '󰨇 ' .. table.concat(parts, ' │ ') or ''
end

------------------------------------------------------------------------------------------------------------------------
-- Approvals
------------------------------------------------------------------------------------------------------------------------

function M.has_approval()
    return next(state.approvals) ~= nil
end

local function approval_slugs()
    local slugs = vim.tbl_keys(state.approvals)
    table.sort(slugs)
    return slugs
end

function M.approval_status()
    local slugs = approval_slugs()
    if #slugs == 0 then
        return ''
    end
    local more = #slugs > 1 and (' (+%d)'):format(#slugs - 1) or ''
    return '󰀦 Approve ' .. state.approvals[slugs[1]].name .. more
end

-- Open the files waiting for approval in a new tab, which removes their marker and thus the one on the status line
function M.open_approval()
    local function open(slug)
        local approval = slug and state.approvals[slug]
        if approval then
            os.remove(approval.marker)
            state.approvals[slug] = nil
            -- A tab of their own, the first file on top, keeps the files being worked on as they are
            local readable = vim.tbl_filter(function(path)
                return vim.fn.filereadable(path) == 1
            end, approval.paths)
            for i, path in ipairs(readable) do
                vim.cmd((i == 1 and 'tabedit ' or 'belowright split ') .. vim.fn.fnameescape(path))
            end
            if #readable == 0 then
                notify(('%s does not exist'):format(approval.name), vim.log.levels.WARN)
            else
                vim.cmd.wincmd('t')
            end
            refresh_bars()
        end
    end
    local slugs = approval_slugs()
    if #slugs == 0 then
        notify('Nothing waits for approval')
    elseif #slugs == 1 then
        open(slugs[1])
    else
        vim.ui.select(slugs, {
            prompt = 'Approval',
            format_item = function(slug)
                return ('%s  %s'):format(slug, state.approvals[slug].name)
            end,
        }, open)
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Focus
------------------------------------------------------------------------------------------------------------------------

-- Slugs of the runs on the board
local function slugs()
    return vim.tbl_map(function(dir)
        return vim.fs.basename((dir:gsub('/$', '')))
    end, vim.fn.glob((state.root or '') .. '/artifacts/*/', true, true))
end

function M.focused()
    return state.focus
end

-- Limit the status line, the window bar and the approvals of this session to one run, or show all runs with `nil`
function M.focus(slug)
    if not state.root then
        notify('No task board (.claude/tasks) in ' .. vim.fn.getcwd(-1, -1), vim.log.levels.WARN)
        return
    end
    if slug and not vim.list_contains(slugs(), slug) then
        notify(('No run %s on the board'):format(slug), vim.log.levels.ERROR)
        return
    end
    state.focus = slug
    load()
    notify(slug and ('Following %s only'):format(slug) or 'Following all runs')
end

-- Pick the run to follow, each shown with the state of its parent card
function M.pick_focus()
    local all = 'All runs'
    vim.ui.select(vim.list_extend({ all }, slugs()), {
        prompt = 'Follow run',
        format_item = function(slug)
            local card = vim.fn.glob(('%s/*/%s.md'):format(state.root or '', slug), true, true)[1]
            local card_state = card and vim.fs.basename(vim.fs.dirname(card))
            return (card_state and ('%s  %s'):format(slug, card_state) or slug)
                .. (slug == state.focus and '  ●' or '')
        end,
    }, function(slug)
        if slug then
            M.focus(slug ~= all and slug or nil)
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------
-- Commands and keymaps
------------------------------------------------------------------------------------------------------------------------

vim.api.nvim_create_user_command('Board', function(opts)
    if opts.fargs[1] == 'approval' then
        M.open_approval()
    elseif opts.fargs[1] == 'focus' then
        if opts.fargs[2] == 'all' then
            M.focus(nil)
        elseif opts.fargs[2] then
            M.focus(opts.fargs[2])
        else
            M.pick_focus()
        end
    else
        notify(('Unknown subcommand %s'):format(opts.fargs[1]), vim.log.levels.ERROR)
    end
end, {
    nargs = '+',
    desc = 'Open the file waiting for `approval`, or `focus [slug|all]` on one run',
    complete = function(lead, line)
        local candidates = line:match('^%s*%a+!?%s+focus%s') and vim.list_extend({ 'all' }, slugs())
            or { 'approval', 'focus' }
        return vim.tbl_filter(function(s)
            return s:sub(1, #lead) == lead
        end, candidates)
    end,
})

vim.keymap.set('n', '<leader>bf', M.pick_focus, { desc = 'Follow one run of the task board' })
vim.keymap.set('n', '<leader>ba', M.open_approval, { desc = 'Open file waiting for approval' })

vim.api.nvim_create_autocmd('DirChanged', { group = group, pattern = 'global', callback = watch })
vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = unwatch })
vim.api.nvim_create_autocmd(
    { 'BufWinEnter', 'WinNew', 'TermOpen', 'ColorScheme' },
    { group = group, callback = vim.schedule_wrap(update_winbar) }
)
watch()

return M
