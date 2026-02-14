-- Autocompletion plugin
return {
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/cmp-nvim-lsp-document-symbol" },
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "windwp/nvim-autopairs", "L3MON4D3/LuaSnip", 'onsails/lspkind.nvim', 'hrsh7th/cmp-calc' },
        config = function()
            -- Customization for Pmenu
            vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#282C34", fg = "NONE" })
            vim.api.nvim_set_hl(0, "Pmenu", { fg = "#C5CDD9", bg = "#22252A" })

            vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
            vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
            vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
            vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })

            vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = "#EED8DA", bg = "#B5585F" })
            vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = "#EED8DA", bg = "#B5585F" })
            vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = "#EED8DA", bg = "#B5585F" })

            vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#C3E88D", bg = "#9FBD73" })
            vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = "#C3E88D", bg = "#9FBD73" })
            vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#C3E88D", bg = "#9FBD73" })

            vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = "#FFE082", bg = "#D4BB6C" })
            vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = "#FFE082", bg = "#D4BB6C" })
            vim.api.nvim_set_hl(0, "CmpItemKindReference", { fg = "#FFE082", bg = "#D4BB6C" })

            vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#EADFF0", bg = "#A377BF" })
            vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = "#EADFF0", bg = "#A377BF" })
            vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#EADFF0", bg = "#A377BF" })
            vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#EADFF0", bg = "#A377BF" })
            vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = "#EADFF0", bg = "#A377BF" })

            vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#000000", bg = "#0FBD73" })
            --vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#C5CDD9", bg = "#7E8294" })
            vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#C5CDD9", bg = "#7E8294" })

            vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = "#F5EBD9", bg = "#D4A959" })
            vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#F5EBD9", bg = "#D4A959" })
            vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#F5EBD9", bg = "#D4A959" })

            vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#DDE5F5", bg = "#6C8ED4" })
            vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = "#DDE5F5", bg = "#6C8ED4" })
            vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = "#DDE5F5", bg = "#6C8ED4" })

            vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#D8EEEB", bg = "#58B5A8" })
            vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = "#D8EEEB", bg = "#58B5A8" })
            vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = "#D8EEEB", bg = "#58B5A8" })

            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.setup({
                window = {
                    completion = {
                        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                        col_offset = -3,
                        side_padding = 0,
                    },
                },
                formatting = {
                    fields = { "icon", "abbr", "menu", "kind" },
                    format = function(entry, vim_item)
                        local lspkind = require("lspkind")
                        local kind = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
                        kind.icon = " " .. (kind.icon or "") .. "  "
                        kind.kind = "   (" .. (kind.kind or "") .. ")"
                        return kind
                    end,
                },
                snippet = {
                    expand = function(args)
                        local luasnip = require("luasnip")
                        if not luasnip then
                            return
                        end
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ["<Down>"] = cmp.config.disable,
                    ["<Up>"] = cmp.config.disable,
                    ["<Tab>"] = cmp.config.disable,
                    ["<S-Tab>"] = cmp.config.disable,
                    ["<C-n>"] = cmp.config.disable,
                    ["<C-p>"] = cmp.config.disable,
                    ["<C-y>"] = cmp.config.disable,
                    ["<C-e>"] = cmp.config.disable,
                    ["<CR>"] = cmp.config.disable,
                },
                sources = cmp.config.sources({
                    { name = "calc" },
                    { name = "luasnip" },
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_document_symbol" },
                    { name = "nvim_lsp_signature_help" },
                }, {
                    { name = "buffer" },
                }),
            })
            -- Set configuration for specific filetype.
            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({
                    { name = "cmp_git" },
                }, {
                    { name = "buffer" },
                }),
            })
            -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline("/", {
                sources = {
                    { name = "buffer" },
                },
            })
            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(":", {
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
            })
            -- add nvim-autopairs
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

            _G.vimrc = _G.vimrc or {}
            _G.vimrc.cmp = _G.vimrc.cmp or {}
            _G.vimrc.cmp.has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0
                    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end
            local luasnip = require("luasnip")
            local types = require("cmp.types")
            _G.vimrc.cmp.cb_tab = function()
                if not _G.vimrc.cmp.has_words_before() then
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
                elseif cmp and cmp.visible() then
                    cmp.select_next_item({ behavior = types.cmp.SelectBehavior.Insert })
                elseif luasnip and luasnip.jumpable(1) then
                    luasnip.jump(1)
                elseif luasnip and luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif cmp and _G.vimrc.cmp.has_words_before() then
                    cmp.complete()
                else
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
                end
            end
            _G.vimrc.cmp.cb_s_tab = function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert })
                elseif luasnip and luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                elseif luasnip and luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                end
            end
            -- Important Note
            -- By default SHIFT-CR may not work. If so, you have to configure your terminal to send the correct codes.
            -- See https://stackoverflow.com/questions/16359878/how-to-map-shift-enter
            _G.vimrc.cmp.cb_s_cr = function()
                if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm()
                else
                    cmp.select_next_item()
                    cmp.select_prev_item()
                    if cmp.get_active_entry() then
                        cmp.confirm()
                    end
                end
            end
            _G.vimrc.cmp.cb_c_x = function()
                if luasnip and luasnip.expandable() then
                    luasnip.expand()
                end
            end
        end,
    },
}
