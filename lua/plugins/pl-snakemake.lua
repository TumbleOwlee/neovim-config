require'loader'.load_plugin({
    'snakemake/snakemake',
    rtp='misc/vim',
    ft='snakemake',
    config = function()
        vim.api.nvim_exec(
            [[
            augroup Snakemake
            autocmd!
            autocmd BufWritePost *.smk silent w !snakefmt - 2>/dev/null >/tmp/snakefmt && cat /tmp/snakefmt >%
            augroup end
            ]],
            false
        )
    end
})
