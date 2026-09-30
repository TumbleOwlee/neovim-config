-- Snakemake syntax (formatting via snakefmt is done by conform)
return {
    {
        'snakemake/snakemake',
        ft = 'snakemake',
        config = function(plugin)
            vim.opt.rtp:append(plugin.dir .. '/misc/vim')
        end,
    },
}
