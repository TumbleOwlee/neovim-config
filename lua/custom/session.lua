-- Directory sessions (resession.nvim) of the directory nvim was started in: a tab with a directory of its own (a
-- worktree under review) does not change which session is saved or loaded
local M = {}

local dir = 'dirsession'

local function name()
    return vim.fn.getcwd(-1, -1)
end

-- Drop the tabs whose directory does not exist anymore (e.g. a worktree removed after its branch was merged) from the
-- session file, as resession fails to load a tab it cannot change into, and the buffers of the files below it
local function drop_missing_tabs()
    local files = require('resession.files')
    local file = require('resession.util').get_session_file(name(), dir)
    local data = files.load_json_file(file)
    if not (data and data.tabs) then
        return
    end
    local missing = {}
    local tabs = vim.tbl_filter(function(tab)
        if tab.cwd and vim.fn.isdirectory(tab.cwd) == 0 then
            table.insert(missing, tab.cwd)
            return false
        end
        return true
    end, data.tabs)
    if #missing == 0 then
        return
    end
    data.buffers = vim.tbl_filter(function(buf)
        return not vim.iter(missing):any(function(cwd)
            return vim.fs.relpath(cwd, buf.name or '') ~= nil
        end)
    end, data.buffers or {})
    -- A session keeps at least one tab, without the directory it lost
    if #tabs == 0 then
        data.tabs[1].cwd = nil
        tabs = { data.tabs[1] }
    end
    data.tabs = tabs
    files.write_json_file(file, data)
end

function M.load()
    -- Loading deletes every buffer, also the ones with changes that were not written
    local modified = vim.tbl_filter(function(buf)
        return vim.bo[buf].modified and vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())
    if #modified > 0 then
        vim.notify(
            ('%d buffer(s) with unsaved changes, write them before loading the session'):format(#modified),
            vim.log.levels.WARN,
            { title = 'Session' }
        )
        return
    end
    -- resession turns off autocmds and messages while it loads and only turns them on again when the load succeeds.
    -- A session file that cannot be read (e.g. truncated) fails the same way
    local eventignore, shortmess = vim.o.eventignore, vim.o.shortmess
    local ok, err = pcall(function()
        drop_missing_tabs()
        require('resession').load(name(), { dir = dir, silence_errors = true })
    end)
    if not ok then
        vim.o.eventignore, vim.o.shortmess = eventignore, shortmess
        vim.notify(('Loading the session failed: %s'):format(err), vim.log.levels.ERROR, { title = 'Session' })
    end
end

function M.save(notify)
    -- resession switches tabs while saving, which the command-line window does not allow
    if vim.fn.getcmdwintype() ~= '' then
        return
    end
    -- Saving visits every tab, which makes the last of them the previous tab (`g<Tab>`), so the one before is
    -- visited again afterwards
    local current = vim.api.nvim_get_current_tabpage()
    local previous = vim.api.nvim_list_tabpages()[vim.fn.tabpagenr('#')]
    -- Like a load, a failed save would leave autocmds turned off
    local eventignore = vim.o.eventignore
    local ok, err = pcall(require('resession').save, name(), { dir = dir, notify = notify })
    if
        previous
        and previous ~= current
        and vim.api.nvim_tabpage_is_valid(previous)
        and vim.api.nvim_get_current_tabpage() == current
    then
        vim.o.eventignore = 'all'
        pcall(vim.api.nvim_set_current_tabpage, previous)
        pcall(vim.api.nvim_set_current_tabpage, current)
    end
    vim.o.eventignore = eventignore
    if not ok then
        vim.notify(('Saving the session failed: %s'):format(err), vim.log.levels.ERROR, { title = 'Session' })
    end
end

return M
