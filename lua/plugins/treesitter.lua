return {
    -- Additional textobjects for treesitter
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
        branch = 'main',
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = 'main',
        build = ":TSUpdate",
        config = function()
            local opts = {
                ensure_installed = {
                    "bash",
                    "html",
                    "javascript",
                    "json",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "query",
                    "regex",
                    "tsx",
                    "typescript",
                    "vim",
                    "yaml",
                    "rust",
                    "cpp",
                    "diff",
                },
                highlight = {
                    enable = true, -- false will disable the whole extension
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
                indent = {
                    enable = true,
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@class.outer",
                        },
                    },
                },
            }
            require 'nvim-treesitter'.setup(opts)

            vim.defer_fn(function()
                vim.fn.system('tree-sitter --version')
                if not (vim.v.shell_error == 0) then
                    vim.notify("Try installing 'tree-sitter-cli'. May block!",
                        vim.log.levels.WARN,
                        { title = "Tree-Sitter-CLI" })
                    vim.fn.system('cargo install --locked tree-sitter-cli')
                    if not (vim.v.shell_error == 0) then
                        vim.notify("TSInstall won't work. Run 'cargo install --locked tree-sitter-cli'!",
                            vim.log.levels.ERROR,
                            { title = "Tree-Sitter-CLI" })
                    else
                        vim.notify("Missing 'tree-sitter-cli' installed!",
                            vim.log.levels.INFO,
                            { title = "Tree-Sitter-CLI" })
                    end
                else
                    vim.notify("Executable present. Ready to install parsers.",
                        vim.log.levels.INFO,
                        { title = "Tree-Sitter-CLI" })
                end
            end, 1000)
        end
    },
}
