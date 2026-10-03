-- unified.nvim keeps a single diff base and a single file tree. This gives every tab a diff of its own, as worktrees
-- under review are in tabs of their own: a tab remembers the base and the tree window of the diff shown in it, the
-- tree of a tab that is left is let go of, and entering a tab brings back its tree and its base
local M = {}

local group = vim.api.nvim_create_augroup('unified_tabs', { clear = true })

-- The tab whose files unified's tree state (its nodes, root and base) was last built for
local rendered_tab

-- unified's state, nil while it is not loaded
local function unified()
    return package.loaded['unified.state']
end

local function tree_state()
    return require('unified.file_tree.state')
end

-- Point unified at the tree window (or none), so its next tree is shown there
local function set_tree(win)
    local ustate = unified()
    local buf = win and vim.api.nvim_win_get_buf(win) or nil
    ustate.file_tree_win, ustate.file_tree_buf = win, buf
    tree_state().window, tree_state().buffer = win, buf
end

local function in_tab(win, tab)
    return win ~= nil and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_tabpage(win) == tab
end

local function current_base()
    local ok, base = pcall(unified().get_commit_base)
    return ok and base or nil
end

-- `:Unified reset` clears the diff of every buffer but only closes the tree unified points at, so it closes the trees
-- of the other tabs as well and forgets the diffs of all tabs
local function patch_reset()
    local command = require('unified.command')
    if command.tabs_reset then
        return
    end
    local reset = command.reset
    command.tabs_reset = true
    command.reset = function(...)
        reset(...)
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
            local tree = vim.t[tab].unified_tree
            if in_tab(tree, tab) and #vim.api.nvim_tabpage_list_wins(tab) > 1 then
                pcall(vim.api.nvim_win_close, tree, true)
            end
            vim.t[tab].unified_base, vim.t[tab].unified_tree = nil, nil
        end
        rendered_tab = nil
    end
end

-- Remember the base of the diff shown in the current tab and, once unified showed it, its tree window
vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'UnifiedBaseCommitUpdated',
    callback = function()
        patch_reset()
        local tab = vim.api.nvim_get_current_tabpage()
        vim.t[tab].unified_base = current_base()
        rendered_tab = tab
        vim.schedule(function()
            local ustate = unified()
            if vim.api.nvim_tabpage_is_valid(tab) and ustate and in_tab(ustate.file_tree_win, tab) then
                vim.t[tab].unified_tree = ustate.file_tree_win
            end
        end)
    end,
})

-- A tab split off another one (`:tab split`) shows its diff as well, in the same directory, so it takes over its base
-- (the tree stays the other tab's)
vim.api.nvim_create_autocmd('TabNewEntered', {
    group = group,
    callback = function()
        local previous = vim.fn.tabpagenr('#')
        if previous == 0 then
            return
        end
        local prev_tab = vim.api.nvim_list_tabpages()[previous]
        if prev_tab and vim.fn.getcwd(-1, previous) == vim.fn.getcwd(-1, 0) then
            vim.t.unified_base = vim.t[prev_tab].unified_base
        end
    end,
})

-- The tree of the tab that is left stays there, but unified lets go of it, so a diff in another tab opens a tree
-- of its own instead of replacing this one
vim.api.nvim_create_autocmd('TabLeave', {
    group = group,
    callback = function()
        local ustate = unified()
        if ustate and in_tab(ustate.file_tree_win, vim.api.nvim_get_current_tabpage()) then
            set_tree(nil)
        end
    end,
})

-- Entering a tab with a diff takes up its tree again. When another tab moved unified to another base, the tab's
-- base is set again, which renders its tree, and the diffs of its windows are shown against it. When only the
-- tree state was built for another tab (e.g. another worktree with the same base), the tree is rendered anew. The
-- cursor stays where it is, unlike with `:Unified`, which jumps to the first hunk
vim.api.nvim_create_autocmd('TabEnter', {
    group = group,
    callback = function()
        local ustate = unified()
        local tab = vim.api.nvim_get_current_tabpage()
        local base = vim.t[tab].unified_base
        if not (ustate and ustate.is_active() and base) then
            return
        end
        local tree = vim.t[tab].unified_tree
        tree = in_tab(tree, tab) and tree or nil
        set_tree(tree)
        if current_base() ~= base then
            -- A tree closed in this tab stays closed
            local tree_config = require('unified.config').values.file_tree
            local enabled = tree_config.enabled
            tree_config.enabled = enabled and tree ~= nil
            local ok, err = pcall(ustate.set_commit_base, base)
            tree_config.enabled = enabled
            if not ok then
                vim.notify(tostring(err), vim.log.levels.ERROR, { title = 'Unified' })
            end
            local udiff = require('unified.diff')
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
                local buf = vim.api.nvim_win_get_buf(win)
                if udiff.is_diff_displayed(buf) then
                    udiff.show(base, buf)
                end
            end
        elseif tree and rendered_tab ~= tab then
            require('unified.file_tree').show(base)
            rendered_tab = tab
        end
    end,
})

-- The base of the diff shown in the current tab, nil without one
function M.base()
    local ustate = unified()
    if not (ustate and ustate.is_active()) then
        return nil
    end
    return vim.t.unified_base
end

return M
