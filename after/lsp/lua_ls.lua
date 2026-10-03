return {
    settings = {
        Lua = {
            -- LuaJIT implements Lua 5.1, so its rocks are the ones for 5.1
            runtime = {
                version = 'LuaJIT',
                path = {
                    '?.lua',
                    '?/init.lua',
                    vim.fn.expand('~/.luarocks/share/lua/5.1/?.lua'),
                    vim.fn.expand('~/.luarocks/share/lua/5.1/?/init.lua'),
                    '/usr/share/lua/5.1/?.lua',
                    '/usr/share/lua/5.1/?/init.lua',
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
                    vim.fn.expand('~/.luarocks/share/lua/5.1'),
                    '/usr/share/lua/5.1',
                },
            },
            telemetry = {
                enable = false,
            },
        },
    },
}
