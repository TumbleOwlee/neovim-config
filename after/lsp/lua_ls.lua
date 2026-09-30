return {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = {
                    '?.lua',
                    '?/init.lua',
                    vim.fn.expand('~/.luarocks/share/lua/5.3/?.lua'),
                    vim.fn.expand('~/.luarocks/share/lua/5.3/?/init.lua'),
                    '/usr/share/5.3/?.lua',
                    '/usr/share/lua/5.3/?/init.lua',
                },
            },
            diagnostics = {
                globals = { 'vim', 'Snacks' },
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    '${3rd}/luv/library',
                    vim.fn.expand('~/.luarocks/share/lua/5.3'),
                    '/usr/share/lua/5.3',
                },
            },
            telemetry = {
                enable = false,
            },
        },
    },
}
