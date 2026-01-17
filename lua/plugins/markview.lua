return {
    {
        "OXY2DEV/markview.nvim",
        opts = {
            preview = {
                icon_provider = "mini",
            },
            markdown = {
                headings = {
                    heading_1 = { icon_hl = "@markup.link", icon = '%d. ' },
                    heading_2 = { icon_hl = "@markup.link", icon = '%d.%d. ' },
                    heading_3 = { icon_hl = "@markup.link", icon = '%d.%d.%d. ' },
                },
            },
        },
        dependencies = {
            "nvim-mini/mini.icons"
        },
        lazy = false
    }
}
