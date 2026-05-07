vim.filetype.add({
    extension = {
        conf = 'dosini',
        ini = 'dosini',
    },
    pattern = {
        ['*.conf$'] = 'dosini',
        ['*.ini$'] = 'dosini',
    },
})
