return {
    {
        'https://gitlab.com/itaranto/preview.nvim.git',
        version = '*',
        cmd = 'PreviewFile',
        -- Neovim has no PlantUML filetype, which the previewer is chosen by
        init = function()
            vim.filetype.add({ extension = { puml = 'plantuml', plantuml = 'plantuml' } })
        end,
        opts = {
            previewers_by_ft = {
                plantuml = {
                    name = 'plantuml_text',
                    renderer = { type = 'buffer', opts = { split_cmd = 'split' } },
                },
            },
        },
    },
}
