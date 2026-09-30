-- Documentation annotations; placeholders are jumped with the snippet keys
return {
    {
        'danymat/neogen',
        cmd = 'Neogen',
        keys = {
            {
                '<leader>nf',
                function()
                    require('neogen').generate()
                end,
                desc = 'Generate annotation',
            },
        },
        opts = {
            snippet_engine = 'luasnip',
        },
    },
}
