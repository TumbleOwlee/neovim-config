-- Code review sessions on top of unified.nvim: comment on diff lines, then send the review to Claude Code or Copilot Chat
local M = {}

local ns = vim.api.nvim_create_namespace('review')
local preview_ns = vim.api.nvim_create_namespace('review.preview')
local group = vim.api.nvim_create_augroup('review', { clear = true })

vim.api.nvim_set_hl(0, 'ReviewComment', { link = 'DiagnosticVirtualTextInfo', default = true })
vim.api.nvim_set_hl(0, 'ReviewCommentSent', { link = 'Comment', default = true })
vim.api.nvim_set_hl(0, 'ReviewHeader', { link = 'DiagnosticError', default = true })

-- Line numbers of commented lines on a background in the colorscheme's error color, recomputed when it changes
local function set_gutter_hl()
    local function color(name, attr)
        return vim.api.nvim_get_hl(0, { name = name, link = false })[attr]
    end
    vim.api.nvim_set_hl(0, 'ReviewGutter', {
        fg = color('Normal', 'bg') or 0x1e1e1e,
        bg = color('DiagnosticError', 'fg') or 0xe06c75,
        bold = true,
        default = true,
    })
end
set_gutter_hl()
vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('review.colors', { clear = true }),
    callback = set_gutter_hl,
})

local state = {
    active = false,
    comments = {}, -- id -> { id, file, lnum, end_lnum, text, excerpt, sent, buf, mark }
    next_id = 1,
    base = nil, -- ref given to :Review
    -- Bottom panel; `ids` are the comments it shows, `new` the pending comment while one is written
    panel = { buf = nil, win = nil, ids = {}, new = nil },
    code_win = nil, -- the window last used for reviewing code
    left_win = nil, -- the window focus last left
}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = 'Review' })
end

local function is_file_buf(buf)
    return vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= ''
end

-- Paths are relative to the directory nvim was started in, where Claude Code runs as well: the tab of a worktree
-- under review has a working directory of its own
local function location(file, first, last)
    local path = vim.fs.relpath(vim.fn.getcwd(-1, -1), file) or vim.fn.fnamemodify(file, ':~')
    return first == last and ('%s:%d'):format(path, first) or ('%s:%d-%d'):format(path, first, last)
end

local function header(tag, file, first, last)
    return ('── %s %s ──'):format(tag, location(file, first, last))
end

-- Only look at unified once it is loaded, so a review does not load it
local function unified_active()
    local ustate = package.loaded['unified.state']
    return ustate ~= nil and ustate.is_active(), ustate
end

-- The base of the unified diff, so excerpts match the diff on screen (:Review <ref> moves unified to it), else
-- the ref given to :Review, else HEAD
local function unified_base()
    local active, ustate = unified_active()
    local ok, base = pcall(function()
        return active and ustate.get_commit_base()
    end)
    return ok and base or nil
end

local function commit_base()
    return unified_base() or state.base or 'HEAD'
end

-- Run git, returning its trimmed output (or the raw output with `raw`), or nil when it fails
local function git(args, cwd, raw)
    local res = vim.system(vim.list_extend({ 'git' }, args), { text = true, cwd = cwd }):wait()
    if res.code ~= 0 then
        return nil
    end
    return raw and res.stdout or vim.trim(res.stdout)
end

-- Refresh a comment's line range from its extmark, which follows edits to the buffer
local function sync(c)
    if c.buf and c.mark and vim.api.nvim_buf_is_valid(c.buf) then
        local mark = vim.api.nvim_buf_get_extmark_by_id(c.buf, ns, c.mark, { details = true })
        if mark[1] then
            c.lnum = mark[1] + 1
            c.end_lnum = (mark[3].end_row or mark[1]) + 1
        end
    end
    return c
end

-- Word-wrap text to a display width, keeping its line breaks
local function wrap(text, width)
    local lines = {}
    for _, line in ipairs(vim.split(text, '\n')) do
        local current = ''
        for word in line:gmatch('%S+') do
            if current ~= '' and vim.fn.strdisplaywidth(current .. ' ' .. word) > width then
                table.insert(lines, current)
                current = word
            else
                current = current == '' and word or current .. ' ' .. word
            end
        end
        table.insert(lines, current)
    end
    return lines
end

-- The comment as a box of virtual lines, wrapped to fit the given width
local function comment_box(c, width)
    local virt_lines = { { { '╭─ Comment #' .. c.id .. (c.sent and ' (sent)' or ''), 'ReviewHeader' } } }
    local hl = c.sent and 'ReviewCommentSent' or 'ReviewComment'
    for _, line in ipairs(wrap(c.text, math.max(20, width - 4))) do
        table.insert(virt_lines, { { '│ ', 'ReviewHeader' }, { line, hl } })
    end
    table.insert(virt_lines, { { '╰─', 'ReviewHeader' } })
    return virt_lines
end

-- Width of the text area of the window showing the buffer
local function text_width(buf)
    local win = vim.fn.bufwinid(buf)
    win = win ~= -1 and win or vim.api.nvim_get_current_win()
    return vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff
end

-- (Re)place the extmarks of a comment: one tracks the commented lines as they move with edits and
-- marks their line numbers, the other shows the comment below the last of them
local function place(c, buf)
    if c.buf and vim.api.nvim_buf_is_valid(c.buf) then
        for _, id in ipairs({ c.mark, c.box }) do
            pcall(vim.api.nvim_buf_del_extmark, c.buf, ns, id)
        end
    end
    c.buf, c.mark, c.box = nil, nil, nil
    if not (buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)) then
        return
    end
    local count = vim.api.nvim_buf_line_count(buf)
    local last = math.min(c.end_lnum, count) - 1
    c.buf = buf
    c.mark = vim.api.nvim_buf_set_extmark(
        buf,
        ns,
        math.min(c.lnum, count) - 1,
        0,
        -- The end sits at the start of the last line, so it has to move with text inserted there like the start
        -- does, or a line added above the last one would take its place in the range
        { end_row = last, end_right_gravity = true, number_hl_group = 'ReviewGutter' }
    )
    c.box = vim.api.nvim_buf_set_extmark(buf, ns, last, 0, { virt_lines = comment_box(c, text_width(buf)) })
end

local function remove(id)
    local c = state.comments[id]
    if c then
        place(c, nil)
        state.comments[id] = nil
    end
end

local function sorted()
    local list = {}
    for _, c in pairs(state.comments) do
        table.insert(list, sync(c))
    end
    table.sort(list, function(a, b)
        if a.file ~= b.file then
            return a.file < b.file
        end
        return a.lnum < b.lnum
    end)
    return list
end

local function comments_at(buf, lnum)
    local file = vim.api.nvim_buf_get_name(buf)
    local list = {}
    for _, c in pairs(state.comments) do
        if c.file == file then
            sync(c)
            if lnum >= c.lnum and lnum <= c.end_lnum then
                table.insert(list, c)
            end
        end
    end
    table.sort(list, function(a, b)
        return a.id < b.id
    end)
    return list
end

-- The buffer's diff against the base of the review as { added = { [lnum] = true }, deleted = { [lnum] = lines } },
-- where deleted lines are shown above buffer line `lnum`, or nil when unified shows no diff for it
local function buffer_diff(buf)
    local udiff = package.loaded['unified.diff']
    if not (unified_active() and udiff and udiff.is_diff_displayed(buf)) then
        return nil
    end
    local file = vim.api.nvim_buf_get_name(buf)
    local root = git({ 'rev-parse', '--show-toplevel' }, vim.fn.fnamemodify(file, ':h'))
    -- git resolves symbolic links in the top level, so the file's path has to be resolved as well
    local path = root and vim.fs.relpath(root, vim.uv.fs_realpath(file) or file)
    if not path then
        return nil
    end
    -- A file that does not exist in the base commit is entirely added
    local old = git({ 'show', commit_base() .. ':' .. path }, root, true) or ''
    local new = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n') .. '\n'
    local old_lines = vim.split(old, '\n')

    local added, deleted = {}, {}
    for _, hunk in ipairs(vim.text.diff(old, new, { result_type = 'indices' })) do
        local old_start, old_count, new_start, new_count = unpack(hunk)
        for lnum = new_start, new_start + new_count - 1 do
            added[lnum] = true
        end
        if old_count > 0 then
            -- Without added lines, `new_start` is the line after which the lines were deleted
            local anchor = new_count > 0 and new_start or new_start + 1
            deleted[anchor] = vim.list_slice(old_lines, old_start, old_start + old_count - 1)
        end
    end
    return { added = added, deleted = deleted }
end

-- Selected lines as a diff fragment when a diff is shown, including the deleted lines within the
-- selection and directly below it, as the deleted block attaches to the line after it
local function excerpt(buf, first, last)
    local diff = buffer_diff(buf)
    local lines = {}
    local function add_deleted(lnum)
        for _, line in ipairs(diff and diff.deleted[lnum] or {}) do
            table.insert(lines, '-' .. line)
        end
    end
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, first - 1, last, false)) do
        local lnum = first + i - 1
        add_deleted(lnum)
        table.insert(lines, (diff and diff.added[lnum] and '+' or ' ') .. line)
    end
    add_deleted(last + 1)
    return lines
end

------------------------------------------------------------------------------------------------------------------------
-- Comment panel
------------------------------------------------------------------------------------------------------------------------

local function panel_open()
    return state.panel.win ~= nil and vim.api.nvim_win_is_valid(state.panel.win)
end

local function panel_buf()
    local p = state.panel
    if p.buf and vim.api.nvim_buf_is_valid(p.buf) then
        return p.buf
    end
    p.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(p.buf, 'review://comments')
    vim.bo[p.buf].buftype = 'acwrite'
    vim.bo[p.buf].bufhidden = 'hide'
    vim.bo[p.buf].filetype = 'markdown'
    vim.api.nvim_create_autocmd('BufWriteCmd', {
        group = group,
        buffer = p.buf,
        callback = function()
            M.save_panel()
        end,
    })
    -- Leaving the panel keeps the edits, as there is no other place they could go
    vim.api.nvim_create_autocmd('BufLeave', {
        group = group,
        buffer = p.buf,
        callback = function()
            if vim.bo[p.buf].modified or p.new then
                M.save_panel()
            end
        end,
    })
    -- Closing a float (e.g. Claude Code) or Copilot Chat returns to the window it was opened from. As
    -- the panel saves when left, there is nothing to continue there, so go back to the code instead
    vim.api.nvim_create_autocmd('WinEnter', {
        group = group,
        buffer = p.buf,
        callback = function()
            local from, code = state.left_win, state.code_win
            if not (from and vim.api.nvim_win_is_valid(from) and code and vim.api.nvim_win_is_valid(code)) then
                return
            end
            local is_float = vim.api.nvim_win_get_config(from).relative ~= ''
            local from_buf = vim.api.nvim_win_get_buf(from)
            if is_float or vim.bo[from_buf].buftype == 'terminal' or vim.bo[from_buf].filetype == 'copilot-chat' then
                vim.schedule(function()
                    if vim.api.nvim_win_is_valid(code) then
                        vim.api.nvim_set_current_win(code)
                        M.hover()
                    end
                end)
            end
        end,
    })
    vim.keymap.set('n', 'q', M.close_panel, { buffer = p.buf, desc = 'Close comment panel' })
    return p.buf
end

local function set_panel(lines, ids, new)
    local p = state.panel
    local buf = panel_buf()
    -- Rendering starts a new undo history, so undo cannot bring back another comment's section,
    -- which would delete the comment shown now when saved
    local undolevels = vim.bo[buf].undolevels
    vim.bo[buf].undolevels = -1
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].undolevels = undolevels
    -- Extmarks, as treesitter highlighting of markdown replaces syntax matches
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for i, line in ipairs(lines) do
        if line:match('^── .* ──$') then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { line_hl_group = 'ReviewHeader' })
        end
    end
    vim.bo[buf].modified = false
    p.ids, p.new = ids, new
    if panel_open() then
        vim.api.nvim_win_set_height(p.win, math.max(12, math.min(#lines + 1, 20)))
    end
end

local function show_comments(list)
    local lines, ids = {}, {}
    for i, c in ipairs(list) do
        if i > 1 then
            table.insert(lines, '')
        end
        table.insert(lines, header('#' .. c.id, c.file, c.lnum, c.end_lnum))
        vim.list_extend(lines, vim.split(c.text, '\n'))
        table.insert(ids, c.id)
    end
    set_panel(lines, ids, nil)
end

local function open_panel(enter)
    local p = state.panel
    if panel_open() then
        if enter then
            vim.api.nvim_set_current_win(p.win)
        end
        return
    end
    local height = math.max(12, math.min(vim.api.nvim_buf_line_count(panel_buf()) + 1, 20))
    p.win = vim.api.nvim_open_win(panel_buf(), enter, { split = 'below', win = -1, height = height })
    local wo = vim.wo[p.win]
    wo.winfixheight = true
    wo.number = false
    wo.relativenumber = false
    wo.signcolumn = 'no'
    wo.wrap = true
    wo.winbar = '%#ReviewHeader# Review comments %*  :w save · empty text or removed header deletes · q close'
end

function M.close_panel()
    local p = state.panel
    if panel_open() then
        pcall(vim.api.nvim_win_close, p.win, true)
    end
    p.win = nil
end

-- Apply the panel contents: every `── #id … ──` section updates its comment, an empty section or
-- a removed header deletes it and a `── new … ──` section with text creates the pending comment
function M.save_panel()
    local p = state.panel
    local sections, current, preamble = {}, nil, {}
    for _, line in ipairs(vim.api.nvim_buf_get_lines(p.buf, 0, -1, false)) do
        local tag = line:match('^── (%S+) .* ──$')
        if tag then
            current = { tag = tag, lines = {} }
            table.insert(sections, current)
        else
            table.insert(current and current.lines or preamble, line)
        end
    end
    -- Text written above the first header belongs to the first comment
    if vim.trim(table.concat(preamble, '\n')) ~= '' then
        if sections[1] then
            sections[1].lines = vim.list_extend(preamble, sections[1].lines)
        else
            notify('Text without a `── … ──` header was not saved', vim.log.levels.WARN)
        end
    end

    local kept, seen = {}, {}
    for _, section in ipairs(sections) do
        local text = vim.trim(table.concat(section.lines, '\n'))
        local id = tonumber(section.tag:match('^#(%d+)$'))
        local c = id and state.comments[id]
        if id and c then
            seen[id] = true
            if text == '' then
                remove(id)
            elseif text ~= c.text then
                c.text, c.sent = text, false
                place(sync(c), c.buf)
            end
        elseif section.tag == 'new' and p.new and text ~= '' then
            c = vim.tbl_extend('force', p.new, { id = state.next_id, text = text, sent = false })
            state.next_id = state.next_id + 1
            state.comments[c.id] = c
            place(c, c.buf)
        end
        if c and state.comments[c.id] then
            table.insert(kept, c)
        end
    end
    for _, id in ipairs(p.ids) do
        if not seen[id] then
            remove(id)
        end
    end

    show_comments(kept)
    if #kept == 0 then
        vim.schedule(M.close_panel)
    end
end

-- Show the comments under the cursor in the panel, unless it holds edits that are not saved yet
function M.hover()
    local p = state.panel
    local buf = vim.api.nvim_get_current_buf()
    if buf == p.buf or not is_file_buf(buf) then
        return
    end
    state.code_win = vim.api.nvim_get_current_win()
    if p.buf and vim.api.nvim_buf_is_valid(p.buf) and (vim.bo[p.buf].modified or p.new) then
        return
    end
    local list = comments_at(buf, vim.fn.line('.'))
    if #list == 0 then
        M.close_panel()
        return
    end
    -- Re-render even for the same comments, as their line ranges may have moved
    show_comments(list)
    open_panel(false)
end

------------------------------------------------------------------------------------------------------------------------
-- Actions
------------------------------------------------------------------------------------------------------------------------

local function require_active()
    if not state.active then
        notify('No review running, start one with :Review', vim.log.levels.WARN)
    end
    return state.active
end

-- Comment on the visual selection, or the cursor line in normal mode
function M.add()
    if not require_active() then
        return
    end
    local buf = vim.api.nvim_get_current_buf()
    if not is_file_buf(buf) then
        notify('Comments can only be added to file buffers', vim.log.levels.WARN)
        return
    end
    local first, last = vim.fn.line('v'), vim.fn.line('.')
    if vim.fn.mode():match('^[vV\22]') then
        vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)
    else
        first = last
    end
    first, last = math.min(first, last), math.max(first, last)

    local p = state.panel
    if p.buf and vim.api.nvim_buf_is_valid(p.buf) and vim.bo[p.buf].modified then
        M.save_panel()
    end
    state.code_win = vim.api.nvim_get_current_win()
    local file = vim.api.nvim_buf_get_name(buf)
    local new = {
        file = file,
        lnum = first,
        end_lnum = last,
        excerpt = excerpt(buf, first, last),
        ft = vim.bo[buf].filetype,
        buf = buf,
    }
    set_panel({ header('new', file, first, last), '' }, {}, new)
    open_panel(true)
    vim.api.nvim_win_set_cursor(p.win, { 2, 0 })
    vim.cmd.startinsert()
end

-- Move into the panel to edit the comments under the cursor
function M.edit()
    if not require_active() then
        return
    end
    M.hover()
    if #comments_at(vim.api.nvim_get_current_buf(), vim.fn.line('.')) == 0 then
        notify('No comment on this line')
        return
    end
    open_panel(true)
end

function M.delete()
    if not require_active() then
        return
    end
    local list = comments_at(vim.api.nvim_get_current_buf(), vim.fn.line('.'))
    if #list == 0 then
        notify('No comment on this line')
        return
    end
    for _, c in ipairs(list) do
        remove(c.id)
    end
    M.close_panel()
    notify(('Deleted %d comment(s)'):format(#list))
end

-- Open the comment's file in unified's content window with its diff and jump to the comment
function M.jump(c)
    sync(c)
    local active, ustate = unified_active()
    local win = active and ustate.get_main_window()
    if win then
        vim.api.nvim_set_current_win(win)
    end
    if vim.api.nvim_buf_get_name(0) ~= c.file then
        vim.cmd.edit(vim.fn.fnameescape(c.file))
    end
    local buf = vim.api.nvim_get_current_buf()
    if active and not require('unified.diff').is_diff_displayed(buf) then
        require('unified.diff').show(commit_base(), buf)
        require('unified.auto_refresh').setup(buf)
    end
    vim.api.nvim_win_set_cursor(0, { math.min(c.lnum, vim.api.nvim_buf_line_count(buf)), 0 })
    M.hover()
end

-- File preview with the full comment shown below the commented lines
local function preview(ctx)
    local ret = Snacks.picker.preview.file(ctx)
    local buf, c = ctx.preview.win.buf, ctx.item.comment
    if not (buf and vim.api.nvim_buf_is_valid(buf)) then
        return ret
    end
    -- The preview buffer is reused for comments in the same file
    vim.api.nvim_buf_clear_namespace(buf, preview_ns, 0, -1)
    local virt_lines = comment_box(c, vim.api.nvim_win_get_width(ctx.win) - vim.fn.getwininfo(ctx.win)[1].textoff)
    local last = math.min(c.end_lnum, vim.api.nvim_buf_line_count(buf)) - 1
    vim.api.nvim_buf_set_extmark(buf, preview_ns, last, 0, { virt_lines = virt_lines })
    return ret
end

function M.list()
    local items = {}
    for _, c in ipairs(sorted()) do
        local summary = c.text:match('^[^\n]*') .. (c.text:find('\n') and ' …' or '')
        table.insert(items, {
            text = location(c.file, c.lnum, c.end_lnum) .. ' ' .. c.text,
            file = c.file,
            pos = { c.lnum, 0 },
            end_pos = { c.end_lnum, 0 },
            comment = c,
            summary = summary,
        })
    end
    if #items == 0 then
        notify('No review comments')
        return
    end
    Snacks.picker.pick({
        title = 'Review comments',
        items = items,
        format = function(item)
            local c = item.comment
            return {
                { location(c.file, c.lnum, c.end_lnum), 'SnacksPickerFile' },
                { c.sent and '  ✓ ' or '  ', 'SnacksPickerComment' },
                { item.summary },
            }
        end,
        preview = preview,
        confirm = function(picker, item)
            picker:close()
            if item then
                M.jump(item.comment)
            end
        end,
    })
end

-- Whether the comment is on lines of a diff, else on plain lines of a file
local function on_diff(c)
    return vim.iter(c.excerpt):any(function(line)
        return line:match('^[+-]') ~= nil
    end)
end

local function format_review(list)
    local lines
    local diffed = vim.iter(list):find(on_diff)
    if diffed or unified_active() then
        -- The repository of the commented files, which is a worktree's when one is under review
        local cwd = git({ 'rev-parse', '--show-toplevel' }, vim.fn.fnamemodify((diffed or list[1]).file, ':h'))
        local base = commit_base()
        local hash = git({ 'rev-parse', '--short', base }, cwd) or base
        local subject = git({ 'log', '-1', '--format=%s', base }, cwd) or ''
        local head = git({ 'rev-parse', '--short', 'HEAD' }, cwd) or 'HEAD'
        local base_desc = hash == base and hash or ('%s (%s)'):format(base, hash)
        if subject ~= '' then
            base_desc = ('%s "%s"'):format(base_desc, subject)
        end
        lines = {
            ('Code review of the working tree changes against %s, HEAD is %s.'):format(base_desc, head),
            'Line numbers refer to the current working tree files. Please address each comment:',
        }
    else
        lines =
            { 'Review of the files below, line numbers refer to their current content. Please address each comment:' }
    end
    for i, c in ipairs(list) do
        table.insert(lines, '')
        table.insert(lines, ('%d. %s'):format(i, location(c.file, c.lnum, c.end_lnum)))
        if #c.excerpt > 0 then
            -- Lines commented outside of a diff are plain code. The fence is longer than any run of backticks
            -- in the code, which would end it otherwise
            local is_diff = on_diff(c)
            local longest = 2
            for _, line in ipairs(c.excerpt) do
                for run in line:gmatch('`+') do
                    longest = math.max(longest, #run)
                end
            end
            local fence = ('`'):rep(longest + 1)
            table.insert(lines, '   ' .. fence .. (is_diff and 'diff' or c.ft or ''))
            for j, line in ipairs(c.excerpt) do
                if j > 40 then
                    table.insert(lines, ('   … %d more lines'):format(#c.excerpt - 40))
                    break
                end
                table.insert(lines, '   ' .. (is_diff and line or line:sub(2)))
            end
            table.insert(lines, '   ' .. fence)
        end
        for _, line in ipairs(vim.split(c.text, '\n')) do
            table.insert(lines, '   ' .. line)
        end
    end
    return table.concat(lines, '\n')
end

-- Targets a review can be sent to; `send` pastes the review into the prompt without submitting it and
-- returns whether that worked
local targets = {
    claude = {
        name = 'Claude Code',
        send = function(text)
            require('custom.terminals').hide(Snacks.terminal.get('tmux', { create = false }))
            local ok, terminal = pcall(require, 'claudecode.terminal')
            return ok and terminal.send_to_terminal(text, { submit = false, focus = true })
        end,
    },
    copilot = {
        name = 'Copilot Chat',
        send = function(text)
            local ok, chat = pcall(require, 'CopilotChat')
            if not ok then
                return false
            end
            chat.open()
            -- Append to the prompt being written, so text already typed there is kept
            local prompt = chat.chat:get_message('user')
            local typed = prompt and vim.trim(prompt.content) ~= ''
            chat.chat:add_message({ role = 'user', content = (typed and '\n\n' or '') .. text })
            chat.chat:follow()
            return true
        end,
    },
}

-- Paste all unsent comments into the prompt of Claude Code (default) or Copilot Chat without submitting it
function M.send(target)
    if not require_active() then
        return
    end
    local t = targets[target or 'claude']
    if not t then
        notify(('Unknown review target %s, use claude or copilot'):format(target), vim.log.levels.ERROR)
        return
    end
    local list = vim.tbl_filter(function(c)
        return not c.sent
    end, sorted())
    if #list == 0 then
        notify('No unsent comments')
        return
    end
    local text = format_review(list)

    if t.send(text) then
        for _, c in ipairs(list) do
            c.sent = true
            place(c, c.buf)
        end
        notify(('Sent %d comment(s) to %s'):format(#list, t.name))
    else
        vim.fn.setreg('+', text)
        notify(('%s is not running, review copied to the clipboard instead'):format(t.name), vim.log.levels.WARN)
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Session
------------------------------------------------------------------------------------------------------------------------

function M.is_active()
    return state.active
end

-- Status line colors: a bold badge in the colorscheme's error color, so the review is hard to miss
function M.status_color()
    local function color(name, attr, fallback)
        local value = vim.api.nvim_get_hl(0, { name = name, link = false })[attr]
        return value and ('#%06x'):format(value) or fallback
    end
    return {
        fg = color('Normal', 'bg', '#1e1e1e'),
        bg = color('DiagnosticError', 'fg', '#e06c75'),
        gui = 'bold',
    }
end

-- Status line marker with the comment count, e.g. `󰆉 Review 3 (1 unsent)`
function M.status()
    if not state.active then
        return ''
    end
    local total, unsent = 0, 0
    for _, c in pairs(state.comments) do
        total = total + 1
        unsent = unsent + (c.sent and 0 or 1)
    end
    local status = '󰆉 Review ' .. total
    if unsent > 0 and unsent < total then
        status = status .. (' (%d unsent)'):format(unsent)
    end
    return status
end

-- The excerpts sent with the comments show the diff against the base, so they follow it when it changes. A
-- comment in a buffer whose diff is not shown keeps its excerpt, as without a diff it would lose its +/- lines
local function refresh_excerpts()
    local udiff = package.loaded['unified.diff']
    for _, c in pairs(state.comments) do
        if c.buf and vim.api.nvim_buf_is_loaded(c.buf) and udiff and udiff.is_diff_displayed(c.buf) then
            sync(c)
            c.excerpt = excerpt(c.buf, c.lnum, c.end_lnum)
        end
    end
end

function M.start(args)
    if not state.active then
        state.active = true
        vim.api.nvim_create_autocmd('CursorMoved', { group = group, callback = M.hover })
        vim.api.nvim_create_autocmd('WinLeave', {
            group = group,
            callback = function()
                state.left_win = vim.api.nvim_get_current_win()
            end,
        })
        -- Remember the positions before a buffer is reloaded or unloaded, as that drops its extmarks
        vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufUnload' }, {
            group = group,
            callback = function(ev)
                for _, c in pairs(state.comments) do
                    if c.buf == ev.buf then
                        sync(c)
                    end
                end
            end,
        })
        -- Re-wrap the comments when their windows change size
        vim.api.nvim_create_autocmd({ 'WinResized', 'VimResized' }, {
            group = group,
            callback = function()
                for _, c in pairs(state.comments) do
                    if c.buf and vim.fn.bufwinid(c.buf) ~= -1 then
                        place(sync(c), c.buf)
                    end
                end
            end,
        })
        vim.api.nvim_create_autocmd('User', {
            group = group,
            pattern = 'UnifiedBaseCommitUpdated',
            callback = refresh_excerpts,
        })
        vim.api.nvim_create_autocmd('BufReadPost', {
            group = group,
            callback = function(ev)
                local file = vim.api.nvim_buf_get_name(ev.buf)
                for _, c in pairs(state.comments) do
                    if c.file == file then
                        place(c, ev.buf)
                    end
                end
            end,
        })
    end
    if args and args ~= '' then
        state.base = args
        if unified_active() and unified_base() ~= args then
            -- The diff on screen follows the base, which refreshes the excerpts once unified resolved it
            vim.cmd({ cmd = 'Unified', args = { args } })
        else
            refresh_excerpts()
        end
    end
    notify(('Review started against %s, comment with <leader>rc'):format(args ~= '' and args or commit_base()))
end

local function teardown()
    local p = state.panel
    p.new = nil
    if p.buf and vim.api.nvim_buf_is_valid(p.buf) then
        vim.bo[p.buf].modified = false
    end
    M.close_panel()
    if p.buf and vim.api.nvim_buf_is_valid(p.buf) then
        vim.api.nvim_buf_delete(p.buf, { force = true })
    end
    for id in pairs(state.comments) do
        remove(id)
    end
    vim.api.nvim_clear_autocmds({ group = group })
    state.active = false
    state.comments = {}
    state.next_id = 1
    state.base = nil
    state.panel = { buf = nil, win = nil, ids = {}, new = nil }
    state.code_win, state.left_win = nil, nil
end

function M.stop()
    if not state.active then
        notify('No review running')
        return
    end
    local unsent = #vim.tbl_filter(function(c)
        return not c.sent
    end, vim.tbl_values(state.comments))
    if unsent == 0 then
        teardown()
        return
    end
    -- Not confirm(), as noice shows a repeated confirm() message as a bare prompt without the question
    local prompt = ('%d unsent comment(s) will be discarded. End the review?'):format(unsent)
    vim.ui.select({ 'No', 'Yes' }, { prompt = prompt }, function(choice)
        if choice == 'Yes' and state.active then
            teardown()
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------
-- Commands and keymaps
------------------------------------------------------------------------------------------------------------------------

vim.api.nvim_create_user_command('Review', function(opts)
    if opts.args == 'end' then
        M.stop()
    elseif opts.fargs[1] == 'send' then
        M.send(opts.fargs[2])
    else
        M.start(opts.args)
    end
end, {
    nargs = '*',
    desc = 'Start a review (optionally naming the base ref), or `end` / `send [claude|copilot]` it',
    complete = function(lead, line)
        local candidates = line:match('^%s*%a+!?%s+send%s') and vim.tbl_keys(targets)
            or { 'end', 'send', 'HEAD', 'HEAD~1' }
        return vim.tbl_filter(function(s)
            return s:sub(1, #lead) == lead
        end, candidates)
    end,
})
vim.api.nvim_create_user_command('Comments', M.list, { desc = 'List review comments' })

-- User commands must be capitalized, so expand the lowercase spelling on the command line
for _, name in ipairs({ 'review', 'comments' }) do
    local cmd = name:sub(1, 1):upper() .. name:sub(2)
    vim.cmd(
        ([[cnoreabbrev <expr> %s getcmdtype() ==# ':' && getcmdline() ==# '%s' ? '%s' : '%s']]):format(
            name,
            name,
            cmd,
            name
        )
    )
end

local map = vim.keymap.set
map('n', '<leader>rr', '<cmd>Review<CR>', { desc = 'Start review' })
map('n', '<leader>rq', M.stop, { desc = 'End review' })
map({ 'n', 'x' }, '<leader>rc', M.add, { desc = 'Add comment' })
map('n', '<leader>re', M.edit, { desc = 'Edit comment' })
map('n', '<leader>rd', M.delete, { desc = 'Delete comment' })
map('n', '<leader>rl', M.list, { desc = 'List comments' })
map('n', '<leader>rs', M.send, { desc = 'Send review to Claude Code' })
map('n', '<leader>rp', function()
    M.send('copilot')
end, { desc = 'Send review to Copilot Chat' })

return M
