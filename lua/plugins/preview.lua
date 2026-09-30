return {
    {
        'https://gitlab.com/itaranto/preview.nvim.git',
        version = '*',
        cmd = 'PreviewFile',
        opts = {
            plantuml = {
                name = 'plantuml_text',
                renderer = { type = 'buffer', opts = { split_cmd = 'split' } },
            },
        },
    },
}
