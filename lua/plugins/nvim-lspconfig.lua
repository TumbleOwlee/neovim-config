return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "ray-x/lsp_signature.nvim" },
			{ "mason-org/mason.nvim" },
			{ "mason-org/mason-lspconfig.nvim" },
			{ "hrsh7th/nvim-cmp" },
		},
		config = function()
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				pattern = { "*.rs" },
				callback = function()
					vim.lsp.buf.format({ timeout_ms = 3000 })
				end,
			})

			local on_attach = function(_, bufnr)
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
				vim.cmd([[ command! Format execute 'lua vim.lsp.buf.formatting()' ]])
				require("lsp_signature").on_attach()
			end

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			local mason = require("mason")
			local mason_registry = require("mason-registry")
			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				automatic_installation = true,
			})

			mason.setup({
				ui = {
					icons = {
						server_installed = "✓",
						server_pending = "➜",
						server_uninstalled = "✗",
					},
				},
			})

			local configure = function(name)
				return {
					cmd = vim.lsp.config[name].cmd,
					on_attach = on_attach,
					capabilities = capabilities,
				}
			end

			local configs = {
				-- Default config
				function(name)
					return name, configure(name)
				end,
				-- Specific setups
				["lua_language_server"] = function()
					return "lua_ls",
						vim.tbl_deep_extend("force", configure("lua_ls"), {
							settings = {
								Lua = {
									runtime = {
										version = "LuaJIT",
										path = {
											"?.lua",
											"?/init.lua",
											vim.fn.expand("~/.luarocks/share/lua/5.3/?.lua"),
											vim.fn.expand("~/.luarocks/share/lua/5.3/?/init.lua"),
											"/usr/share/5.3/?.lua",
											"/usr/share/lua/5.3/?/init.lua",
										},
									},
									diagnostics = {
										globals = { "vim" },
									},
									workspace = {
										library = {
											vim.api.nvim_get_runtime_file("", true),
											vim.fn.expand("~/.luarocks/share/lua/5.3"),
											"/usr/share/lua/5.3",
										},
									},
									telemetry = {
										enable = false,
									},
								},
							},
						})
				end,
				["r_languageserver"] = function()
					return "r_language_server",
						vim.tbl_deep_extend("force", configure("r_language_server"), {
							settings = {
								pylsp = {
									plugins = {
										pycodestyle = {
											ignore = { "w391", "E501" },
											maxLineLength = 120,
										},
									},
								},
							},
						})
				end,
				["python_lsp_server"] = function()
					return "pylsp", configure("pylsp")
				end,
				["yaml_language_server"] = function()
					return "yamlls",
						vim.tbl_deep_extend("force", configure("yamlls"), {
							settings = {
								yaml = {
									format = {
										enable = true,
										singleQuote = true,
									},
									validate = true,
									completion = true,
								},
							},
						})
				end,
				["json_lsp"] = function()
					return "jsonls", configure("jsonls")
				end,
				["bash_language_server"] = function()
					return "bashls", configure("bashls")
				end,
				["rust_analyzer"] = function()
					return "rust_analyzer",
						vim.tbl_deep_extend("force", configure("rust_analyzer"), {
							settings = {
								["rust-analyzer"] = {
									checkOnSave = true,
									check = {
										enable = true,
										command = "clippy",
										features = "all",
									},
								},
							},
						})
				end,
				["docker_compose_langserver"] = function()
					return "docker_compose_langserver", configure("docker_compose_langserver")
				end,
				["dockerfile_language_server"] = function()
					return "dockerls", configure("dockerls")
				end,
				["cmake_language_server"] = function()
					return "cmake", configure("cmake")
				end,
			}

			for _, name in ipairs(mason_registry.get_installed_package_names()) do
				local n, cfg = (configs[name:gsub("-", "_")] or configs[1])(name:gsub("-", "_"))
				if n ~= "cspell" then
					vim.lsp.config[name] = cfg
				end
			end
			vim.lsp.inlay_hint.enable()
		end,
	},
}
