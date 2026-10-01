-- Parsers installed on startup, other languages are installed when first opened
local parsers = {
    'bash',
    'c',
    'cpp',
    'diff',
    'html',
    'javascript',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'regex',
    'rust',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
}

-- Enable highlighting and, where the parser supports it, indentation
local function start(buf, lang)
    if not pcall(vim.treesitter.start, buf, lang) then
        return
    end
    if vim.treesitter.query.get(lang, 'indents') then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
end

-- Textobject keymap helpers
local function sel(query)
    return function()
        require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects')
    end
end

local function move(fn, query)
    return function()
        require('nvim-treesitter-textobjects.move')[fn](query, 'textobjects')
    end
end

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false, -- Does not support lazy-loading
        build = ':TSUpdate',
        config = function()
            local ts = require('nvim-treesitter')
            local headless = #vim.api.nvim_list_uis() == 0
            local can_install = vim.fn.executable('tree-sitter') == 1 and not headless

            if can_install then
                -- Asynchronous, already installed parsers are skipped
                ts.install(parsers)
            elseif not headless then
                vim.schedule(function()
                    vim.notify(
                        "Parsers can't be installed. Run 'cargo install --locked tree-sitter-cli'!",
                        vim.log.levels.WARN,
                        { title = 'Tree-Sitter-CLI' }
                    )
                end)
            end

            local available
            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('TreesitterStart', { clear = true }),
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if not lang then
                        return
                    end
                    if vim.treesitter.language.add(lang) then
                        start(args.buf, lang)
                    elseif can_install then
                        available = available or ts.get_available()
                        if vim.list_contains(available, lang) then
                            ts.install(lang):await(function()
                                if vim.api.nvim_buf_is_valid(args.buf) then
                                    start(args.buf, lang)
                                end
                            end)
                        end
                    end
                end,
            })
        end,
    },
    -- Additional textobjects for treesitter
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        dependencies = 'nvim-treesitter/nvim-treesitter',
        opts = {
            select = {
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            },
            move = {
                set_jumps = true, -- whether to set jumps in the jumplist
            },
        },
        keys = {
            { 'af', sel('@function.outer'), mode = { 'x', 'o' }, desc = 'Around function' },
            { 'if', sel('@function.inner'), mode = { 'x', 'o' }, desc = 'Inside function' },
            { 'ac', sel('@class.outer'), mode = { 'x', 'o' }, desc = 'Around class' },
            { 'ic', sel('@class.inner'), mode = { 'x', 'o' }, desc = 'Inside class' },
            {
                ']m',
                move('goto_next_start', '@function.outer'),
                mode = { 'n', 'x', 'o' },
                desc = 'Next function start',
            },
            { ']]', move('goto_next_start', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next class start' },
            { ']M', move('goto_next_end', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next function end' },
            { '][', move('goto_next_end', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next class end' },
            {
                '[m',
                move('goto_previous_start', '@function.outer'),
                mode = { 'n', 'x', 'o' },
                desc = 'Previous function start',
            },
            {
                '[[',
                move('goto_previous_start', '@class.outer'),
                mode = { 'n', 'x', 'o' },
                desc = 'Previous class start',
            },
            {
                '[M',
                move('goto_previous_end', '@function.outer'),
                mode = { 'n', 'x', 'o' },
                desc = 'Previous function end',
            },
            {
                '[]',
                move('goto_previous_end', '@class.outer'),
                mode = { 'n', 'x', 'o' },
                desc = 'Previous class end',
            },
        },
    },
}
