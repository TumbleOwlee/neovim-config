return {
    {
        "snakemake/snakemake",
        ft = "snakemake",
        config = function(plugin)
            vim.opt.rtp:append(plugin.dir .. "/misc/vim")
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                pattern = { "*.smk" },
                command = "silent w !snakefmt - 2>/dev/null >/tmp/snakefmt && cat /tmp/snakefmt >%",
            })
        end,
    },
}
