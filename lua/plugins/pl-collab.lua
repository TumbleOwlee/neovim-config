-- Collaborative edition
require 'loader'.load_plugin({
    'jbyuki/instant.nvim',
    config = function()
        local function new_hi_group(name, fg, bg)
            local use_bg = bg or '0'
            local use_fg = fg or '0'
            vim.cmd("highlight " .. name .. " guifg=" .. use_fg .. " guibg=" .. use_bg)
            return name
        end

        vim.g.instant_username = "Owlee"
        vim.g.instant_auth_separator = "| "

        -- Configure user colors
        vim.g.instant_cursor_hl_group_user1 = new_hi_group("instant_cursor1", "#000000", "#BB62D3")
        vim.g.instant_name_hl_group_user1 = new_hi_group("instant_name1", "#BB62D3")
        vim.g.instant_cursor_hl_group_user2 = new_hi_group("instant_cursor2", "#000000", "#D36284")
        vim.g.instant_name_hl_group_user2 = new_hi_group("instant_name2", "#D36284")
        vim.g.instant_cursor_hl_group_user3 = new_hi_group("instant_cursor3", "#000000", "#62A9D3")
        vim.g.instant_name_hl_group_user3 = new_hi_group("instant_name3", "#62A9D3")
        vim.g.instant_cursor_hl_group_user4 = new_hi_group("instant_cursor4", "#000000", "#62D39D")
        vim.g.instant_name_hl_group_user4 = new_hi_group("instant_name4", "#62D39D")
        vim.g.instant_cursor_hl_group_default = new_hi_group("instant_cursor_default", "#000000", "#CCD362")
        vim.g.instant_name_hl_group_default = new_hi_group("instant_name_default", "#CCD362")
    end
})
