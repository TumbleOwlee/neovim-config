-- Keybindings with interactive popup for reminder
return {
	{
		"folke/which-key.nvim",
		dependencies = {
			"nvim-mini/mini.icons",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			spec = {
				{
					-- Terminal mode without <leader>
					{ "<A-d>", [[<C-\><C-n><cmd>Lspsaga term_toggle<CR>]], desc = "Close terminal" },
					mode = "t",
					remap = false,
					silent = true,
				},
				{
					-- Normal mode without <leader>
					{
						{ "g", group = "Go to" },
						{ "gD", [[<Cmd>lua vim.lsp.buf.declaration()<CR>]], desc = "Go to declaration" },
						{ "gd", [[<Cmd>lua vim.lsp.buf.definition()<CR>]], desc = "Go to definition" },
						{ "gi", [[<cmd>lua vim.lsp.buf.implementation()<CR>]], desc = "Go to implementation" },
						{ "gh", [[<cmd>Lspsaga finder<CR>]], desc = "LSP finder" },
						{ "gr", [[<cmd>lua vim.lsp.buf.references()<CR>]], desc = "Show references" },
					},
					{ "K", [[<cmd>Lspsaga hover_doc<CR>]], desc = "Show documentation" },
					{ "<A-d>", [[<cmd>Lspsaga term_toggle tmux<CR>]], desc = "Open terminal" },
					{
						"<A-w>",
						[[<cmd>lua require('telescope.builtin').lsp_document_symbols({ symbols='function' })<CR>]],
						desc = "Show functions",
					},
					{ "<C-d>", [[<cmd>NvimTreeFocus<CR>]], desc = "Toggle directory tree" },
					{ "<C-p>", [[<cmd>Lspsaga diagnostic_jump_prev<CR>]], desc = "Jump to previous" },
					{ "<C-n>", [[<cmd>Lspsaga diagnostic_jump_next<CR>]], desc = "Jump to next" },
					{ "<C-a>", [[<cmd>Lspsaga code_action<CR>]], desc = "Code action" },
					{ "<C-f>", [[<cmd>lua vim.lsp.buf.format()<CR>]], desc = "Format current buffer" },
					{ "<C-g>", [[<cmd>lua require'neogen'.generate()<CR>]], desc = "Add documentation" },
					{ "<A-b>", [[<cmd>lua require'dap'.toggle_breakpoint()<CR>]], desc = "Set breakpoint" },
					{
						"<A-c>",
						[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if require'dap'.status() and require'dap'.status() ~= "" then require'dap'.continue() end<CR>]],
						desc = "Continue session",
					},
					{
						"<A-n>",
						[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if require'dap'.status() and require'dap'.status() ~= "" then require'dap'.step_over() end<CR>]],
						desc = "Step over",
					},
					{
						"<A-s>",
						[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if require'dap'.status() and require'dap'.status() ~= "" then require'dap'.step_into() end<CR>]],
						desc = "Step into",
					},
					{
						"<A-r>",
						[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if not require'dap'.status() or require'dap'.status() == "" then require'dap'.continue() end<CR>]],
						desc = "Start debug session",
					},
					{
						"<A-f>",
						[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if require'dap'.status() and require'dap'.status() ~= "" then vim.g.dap_float = require'dap.ui.widgets'.centered_float(require'dap.ui.widgets'.frames) end<CR>]],
						desc = "Show debug frames",
					},
					{
						"<A-l>",
						[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if require'dap'.status() and require'dap'.status() ~= "" then vim.g.dap_float = require'dap.ui.widgets'.centered_float(require'dap.ui.widgets'.scopes) end<CR>]],
						desc = "Show debug locals",
					},
					{ "<A-p>", [[<cmd>lua require'dap'.repl.toggle()<CR>]], desc = "Show console" },
					{ "<A-m>", [[<cmd>w<CR><cmd>bn<CR>]], desc = "Next buffer" },
					{ "<A-q>", [[<cmd>lua require'custom.search'.search_pattern()<CR>]], desc = "Next buffer" },
					{ "<tab>", [[<cmd>tabnext<CR>]], desc = "Next tab" },
					{ "<S-tab>", [[<cmd>tabprevious<CR>]], desc = "Previous tab" },
					{ "<C-t>", [[<cmd>tabnew %<CR>]], desc = "Open new tab" },
					{ "j", "gj", desc = "Move cursor down" },
					{ "k", "gk", desc = "Move cursor up" },
					mode = "n",
					remap = false,
					silent = false,
				},
				{
					-- Normal mode with leader key
					{
						{ "<leader>c", group = "Code actions" },
						{ "<leader>ca", [[<cmd>Lspsaga code_action<CR>]], desc = "Code action" },
					},
					{
						{ "<leader>s", group = "Session Handling" },
						{ "<leader>ss", desc = "Save session" },
						{ "<leader>sl", desc = "Load session" },
					},
					{ "<leader>D", [[<cmd>lua vim.lsp.buf.type_definition()<CR>]], desc = "Type definition" },
					{
						{ "<leader>d", group = "Dashboard operations" },
						{ "<leader>dn", [[<cmd>DashboardNewFile<CR>]], desc = "New file" },
					},
					{
						{ "<leader>g", group = "Debugging operations" },
						{
							"<leader>gb",
							[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.toggle_breakpoint()<CR>]],
							desc = "Toggle breakpoint",
						},
						{
							"<leader>gc",
							[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.continue()<CR>]],
							desc = "Continue",
						},
						{
							"<leader>gr",
							[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if require'dap'.status() and require'dap'.status() ~= "" then require'dap'.terminate() end require'dap'.continue()<CR>]],
							desc = "Run session",
						},
						{
							"<leader>gt",
							[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.terminate()<CR>]],
							desc = "Terminate",
						},
						{
							"<leader>gd",
							[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.clear_breakpoints()<CR>]],
							desc = "Clear all breakpoints",
						},
						{
							"<leader>gn",
							[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.step_over()<CR>]],
							desc = "Step over",
						},
						{
							"<leader>gg",
							[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.run_to_cursor()<CR>]],
							desc = "Run to cursor",
						},
						{
							{ "<leader>gs", group = "Step operations" },
							{
								"<leader>gsi",
								[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.step_into()<CR>]],
								desc = "Step into",
							},
							{
								"<leader>gso",
								[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.step_out()<CR>]],
								desc = "Step out",
							},
							{
								"<leader>gsb",
								[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.step_back()<CR>]],
								desc = "Step back",
							},
							{
								"<leader>gsr",
								[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.reverse_continue()<CR>]],
								desc = "Reverse continue",
							},
						},
						{
							{ "<leader>gi", group = "Information" },
							{
								"<leader>giu",
								[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.up()<CR>]],
								desc = "Go up in stacktrace",
							},
							{
								"<leader>gid",
								[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end require'dap'.down()<CR>]],
								desc = "Go down in stacktrace",
							},
							{
								"<leader>gif",
								[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if require'dap'.status() and require'dap'.status() ~= "" then vim.g.dap_float = require'dap.ui.widgets'.centered_float(require'dap.ui.widgets'.frames) end<CR>]],
								desc = "Show frames",
							},
							{
								"<leader>gis",
								[[<cmd>lua if vim.g.dap_float then vim.g.dap_float.close() vim.g.dap_float = nil end if require'dap'.status() and require'dap'.status() ~= "" then vim.g.dap_float = require'dap.ui.widgets'.centered_float(require'dap.ui.widgets'.scopes) end<CR>]],
								desc = "Show scopes",
							},
						},

						{ "<leader>gp", [[<cmd>lua require'dap'.pause()<CR>]], desc = "Pause thread" },
						{
							"<leader>gf",
							[[<cmd>lua require'dap'.repl.toggle()<CR>]],
							desc = "Toggle interactive REPL console",
						},
						{
							"<leader>gv",
							[[<cmd>lua require'dap.ui.widgets').hover()<CR>]],
							desc = "Show value of expr under cursor",
						},
					},
					{
						{ "<leader>l", group = "LSP operations" },
						{
							{ "<leader>lw", group = "Workspace" },
							{ "<leader>lwa", [[<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>]], desc = "Add folder" },
							{
								"<leader>lwr",
								[[<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>]],
								desc = "Remove folder",
							},
							{
								"<leader>lwl",
								[[<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>]],
								desc = "List folders",
							},
						},
						{ "<leader>lq", [[<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>]], desc = "Set loclist" },
						{ "<leader>ls", [[<cmd>Lspsaga peek_definition<CR>]], desc = "Peek definition" },
						{
							"<leader>ld",
							[[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]],
							desc = "Document symbols",
						},
						{ "<leader>lr", [[<cmd>Lspsaga rename<CR>]], desc = "Rename" },
						{ "<leader>lp", [[<cmd>Lspsaga peek_definition<CR>]], desc = "Preview definition" },
						{
							{ "<leader>lj", group = "Jump" },
							{ "<leader>ljn", [[<cmd>Lspsaga diagnostic_jump_prev<CR>]], desc = "Jump to next" },
							{ "<leader>ljp", [[<cmd>Lspsaga diagnostic_jump_next<CR>]], desc = "Jump to previous" },
						},
						{
							{ "<leader>lc", group = "Callhierarchy" },
							{ "<leader>lci", [[<cmd>Lspsaga incoming_calls<CR>]], desc = "Incoming calls" },
							{ "<leader>lco", [[<cmd>Lspsaga outgoing_calls<CR>]], desc = "Outgoing calls" },
						},
					},
					{
						{ "<leader>b", group = "Buffer operations" },
						{ "<leader>bp", [[<cmd>BufferLinePick<CR>]], desc = "Buffer picker" },
						{ "<leader>bb", [[<cmd>Gitsigns toggle_current_line_blame<CR>]], desc = "Toggle line blame" },
					},
					{
						{ "<leader>q", group = "Quickfix window" },
						{ "<leader>qt", [[<cmd>Trouble diagnostics toggle<CR>]], desc = "Toggle quickfix" },
						{ "<leader>qd", [[<cmd>TodoTelescope<CR>]], desc = "Show ToDo list" },
					},
					{
						{ "<leader>t", group = "Telescope operations" },
						{
							{ "<leader>tf", group = "Find" },
							{
								"<leader>tff",
								[[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]],
								desc = "Find files",
							},
							{
								"<leader>tfz",
								[[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]],
								desc = "Fuzzy find",
							},
						},
						{ "<leader>tm", [[<cmd>lua require('telescope.builtin').marks()<CR>]], desc = "Help tags" },
						{ "<leader>th", [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], desc = "Help tags" },
						{ "<leader>tt", [[<cmd>lua require('telescope.builtin').tags()<CR>]], desc = "Tags" },
						{
							"<leader>ts",
							[[<cmd>lua require('telescope.builtin').grep_string()<CR>]],
							desc = "Grep string",
						},
						{ "<leader>tl", [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], desc = "Live grep" },
						{
							"<leader>tc",
							[[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]],
							desc = "Tags in current buffer",
						},
						{ "<leader>t?", [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], desc = "Old files" },
					},
					{
						{ "<leader>n", group = "Annotation / Notification" },
						{ "<leader>ns", [[<cmd>lua Snacks.notifier.show_history()<CR>]], desc = "Show notification history" },
						{ "<leader>nf", [[<cmd>lua require'neogen'.generate()<CR>]], desc = "Generate annotation" },
					},
					{ "<leader>z", [[<cmd>Twilight<CR>]], desc = "Toggle zen mode" },
					{
						{ "<leader>p", group = "Nvim operations" },
						{ "<leader>pu", [[<cmd>Lazy update<CR>]], desc = "Update plugins" },
						{ "<leader>pq", [[<cmd>exit<CR>]], desc = "Close nvim" },
					},
					{
						"<leader>f",
						[[<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>]],
						desc = "List buffers",
					},
					{
						"<leader><Space>",
						[[<cmd>lua require('telescope.builtin').buffers()<CR>]],
						desc = "List buffers",
					},
					mode = "n",
					remap = false,
					silent = true,
				},
				{
					-- Visual mode with <leader>
					mode = "v",
					remap = false,
					silent = true,
				},
				{
					{ "<Tab>", [[<cmd>lua vimrc.cmp.cb_tab()<CR>]], desc = "Move to next completion item" },
					{ "<S-Tab>", [[<cmd>lua vimrc.cmp.cb_s_tab()<CR>]], desc = "Move to previous completion item" },
					{ "<S-CR>", [[<cmd>lua vimrc.cmp.cb_s_cr()<CR>]], desc = "Confirm completion item" },
					{
						"<C-x>",
						[[<cmd>lua if require'luasnip'.expandable() then require'luasnip'.expand() end<CR>]],
						desc = "Expand snippet",
					},
					{
						"<C-n>",
						[[<cmd>lua if require'luasnip'.jumpable(1) then require'luasnip'.jump(1) end<CR>]],
						desc = "Jump to next position",
					},
					{
						"<C-p>",
						[[<cmd>lua if require'luasnip'.jumpable(-1) then require'luasnip'.jump(-1) end<CR>]],
						desc = "Jump to next position",
					},
					{ "<C-h>", [[<cmd>lua require'neogen'.jump_next()<CR>]], desc = "Jump to next placeholder" },
					{ "<C-l>", [[<cmd>lua require'neogen'.jump_prev()<CR>]], desc = "Jump to previous placeholder" },
					mode = "i",
					remap = false,
					silent = true,
				},
			},
		},
	},
}
