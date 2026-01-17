return {
    {
        'vague-theme/vague.nvim',
        config = function()
            require 'vague'.setup({
                transparent = true,
            })
            vim.cmd([[silent! set background=dark]])
            vim.cmd([[silent! colorscheme vague]])
        end
    },
}
