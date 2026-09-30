-- Dims inactive portions of code
return {
    {
        'folke/twilight.nvim',
        cmd = { 'Twilight', 'TwilightEnable', 'TwilightDisable' },
        keys = {
            { '<leader>z', '<cmd>Twilight<CR>', desc = 'Toggle focus mode' },
        },
        opts = {
            dimming = {
                alpha = 0.5,
            },
            context = 30,
        },
    },
}
