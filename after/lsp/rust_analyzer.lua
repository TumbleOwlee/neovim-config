-- nvim-lspconfig's root detection, which the `root_dir` below would otherwise replace
local default
for _, path in ipairs(vim.api.nvim_get_runtime_file('lsp/rust_analyzer.lua', true)) do
    if not path:find('/after/lsp/', 1, true) then
        default = dofile(path).root_dir
        break
    end
end

return {
    -- No server for a worktree under review: it would index and check a second copy of the workspace
    -- while the agent working there builds it
    root_dir = function(bufnr, on_dir)
        if require('custom.worktree').is_reviewed(vim.api.nvim_buf_get_name(bufnr)) then
            return
        end
        if default then
            default(bufnr, on_dir)
        end
    end,
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = true,
            check = {
                command = 'clippy',
                features = 'all',
            },
        },
    },
}
