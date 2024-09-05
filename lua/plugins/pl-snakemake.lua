require 'loader'.load_plugin({
    'snakemake/snakemake',
    rtp = 'misc/vim',
    ft = 'snakemake',
    config = function()
        vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
            pattern = { '*.smk' },
            command = 'silent w !snakefmt - 2>/dev/null >/tmp/snakefmt && cat /tmp/snakefmt >%',
        })
    end
})
