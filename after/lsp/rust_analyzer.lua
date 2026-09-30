return {
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = true,
            check = {
                command = 'clippy',
                features = 'all',
            },
        },
    },
}
