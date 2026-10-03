local Util = {}

function Util.abort(msg, context)
    vim.api.nvim_echo({
        { msg .. '\n', 'ErrorMsg' },
        { context, 'WarningMsg' },
        { #vim.api.nvim_list_uis() > 0 and '\nPress any key to exit...' or '' },
    }, true, {})
    -- Without a UI (headless, CI) there is nobody to press a key
    if #vim.api.nvim_list_uis() > 0 then
        vim.fn.getchar()
    end
    os.exit(1)
end

return Util
