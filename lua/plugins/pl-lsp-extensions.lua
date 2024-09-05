require 'loader'.load_plugin({
    'nvim-lua/lsp_extensions.nvim',
    config = function()
        require 'lsp_extensions'.inlay_hints {
            highlight = "Comment",
            prefix = " > ",
            aligned = false,
            only_current_line = false,
            enabled = { "TypeHint", "ChainingHint", "ParameterHint" }
        }
    end
})
