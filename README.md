# Neovim Configuration

> [!IMPORTANT]
> This is a personal neovim configuration. It may be updated any time. If you have any suggestions or plugin recommendations, please share them and I may introduce them to this environment.

[![status-badge](https://github-ci.code-ape.dev/api/badges/1/status.svg?events=tag&workflow=Package&step=install)](https://github-ci.code-ape.dev/repos/1)
[![status-badge](https://github-ci.code-ape.dev/api/badges/1/status.svg?events=tag&workflow=Package&step=upload)](https://github-ci.code-ape.dev/repos/1)
[![Nightly Tag](https://github.com/TumbleOwlee/neovim-config/actions/workflows/nightly.yml/badge.svg)](https://github.com/TumbleOwlee/neovim-config/actions/workflows/nightly.yml)
[![Format](https://github.com/TumbleOwlee/neovim-config/actions/workflows/format.yml/badge.svg)](https://github.com/TumbleOwlee/neovim-config/actions/workflows/format.yml)

This repository contains a customized [Neovim](https://github.com/neovim/neovim) configuration for `C`, `C++` and `Rust` development. Additional languages are configured but not the focus of the setup. Language servers are installed with `:Mason` and enabled automatically, server specific settings are located in [`after/lsp`](https://github.com/TumbleOwlee/neovim-config/blob/main/after/lsp). This configuration utilizes various plugins to add useful features. Each plugin is configured in [`lua/plugins`](https://github.com/TumbleOwlee/neovim-config/blob/main/lua/plugins).  On the other hand general settings, keymaps and LSP behaviour are located in [`lua/config`](https://github.com/TumbleOwlee/neovim-config/blob/main/lua/config).

## Requirements

- Neovim **0.12** or newer
- `git`, `make` and a C compiler
- [`tree-sitter-cli`](https://github.com/tree-sitter/tree-sitter) to install parsers (`cargo install --locked tree-sitter-cli`)
- Optional: `ripgrep` and `fd` for the pickers, `stylua`/`snakefmt` for formatting Lua/Snakemake, `node` for GitHub Copilot

## Online Installation

The easiest way to use and update this neovim configuration is to clone the repository and pull changes from time to time. Keep in mind, on first start of `neovim` [`lazy.nvim`](https://github.com/folke/lazy.nvim), all configured plugins and the treesitter parsers will be automatically installed. Plugins are installed at the versions recorded in `lazy-lock.json`; `:Lazy update` (`<leader>pu`) updates them and the lockfile, which is committed afterwards.

```bash
git clone https://github.com/TumbleOwlee/neovim-config ~/.config/nvim/
```

## Offline Installation

> [!NOTE]
> The nightly package is rebuilt on every commit to `main` and contains the plugins at the versions of `lazy-lock.json`.

In case your environment doesn't have internet access, this repository provides a nightly package containing the configuration, all installed plugins and the treesitter parsers of the languages listed in [`lua/config/parsers.lua`](https://github.com/TumbleOwlee/neovim-config/blob/main/lua/config/parsers.lua). Language servers are not part of it, as Mason downloads them; install them on a machine with access to the same platform and copy `~/.local/share/nvim/mason` along. Just go to the [nightly release](https://github.com/TumbleOwlee/neovim-config/releases/tag/nightly) and download the [`neovim-config.tar.gz`](https://github.com/TumbleOwlee/neovim-config/releases/download/nightly/neovim-config.tar.gz). Move the archive onto your system and just unpack it into `~/` using `tar -xvf neovim-config.tar.gz`. The archive provides the contents of `~/.config/nvim` and `~/.local/share/nvim`. Afterwards you are ready to go. The package is built on Debian for x86_64 Linux with glibc; its parsers and compiled plugin libraries don't load on other platforms (e.g. musl based distributions like Alpine).

Building the package (`:SyncInstall`) needs the `tree-sitter` CLI and a C compiler to install the parsers, and fails without them.

## AI Assistants

- **Claude Code** ([claudecode.nvim](https://github.com/coder/claudecode.nvim)): requires the `claude` CLI. Toggle with `<A-,>` or `<leader>ac`.
- **GitHub Copilot**: inline suggestions use Neovim's native inline completion. Install the server with `:MasonInstall copilot-language-server`, then run `:LspCopilotSignIn` once. Accept a suggestion with `<C-f>`, cycle with `<A-]>`/`<A-[>`. Chat is provided by [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) (`<A-e>`, `<leader>C…`).

## Key Mappings

`<leader>` is `<Space>`. Press `<leader>` and wait for the which-key popup to see all mappings.

| Keys | Action |
|---|---|
| `<leader><Space>` / `<leader>ff` / `<leader>fg` | Buffers / files / live grep |
| `<leader>fw` / `<leader>fz` / `<leader>fr` | Grep word / search buffer lines / recent files |
| `<leader>fd` / `<leader>fb` / `<leader>e` | ToDo list / oil file browser / file explorer |
| `gd` / `gD` / `gh` / `K` | Definition / declaration / references picker / hover |
| `grn` / `gra` / `grr` / `gri` / `grt` | Native LSP: rename / code action / references / implementation / type definition |
| `<C-n>` / `<C-p>` (`]d` / `[d`) | Next / previous diagnostic |
| `<leader>l…` | LSP: format (`lf`), toggle format on save (`lF`), symbols (`ld`), calls (`lci`/`lco`), inlay hints (`lh`) |
| `<Tab>` / `<S-Tab>` / `<S-CR>` (insert mode) | Completion next / previous / accept, snippet jumps with `<C-n>`/`<C-p>` |
| `<A-b>` `<A-r>` `<A-c>` `<A-n>` `<A-s>` | Debug: breakpoint / start / continue / step over / step into (`<leader>d…` for more, `<leader>dl` starts a Lua debug server in this instance) |
| `<leader>g…` / `]h` / `[h` | Git: blame, preview/stage/reset hunk / next / previous hunk |
| `<leader>o…` | Overseer tasks (`:Make`, `:CMake`, `:Run`, `:Grep`) |
| `<leader>s…` | Save / load directory session (restored automatically when started without files) |
| `<Tab>` / `<S-Tab>` (normal mode), `]<Tab>` / `[<Tab>` | Next / previous tab |
| `<C-t>` / `<C-q>` (`<leader><Tab>n` / `<leader><Tab>c`) | Open current buffer in new tab / close tab |
| `<A-d>` | Toggle floating terminal |

## Code Review

Review changes and send the comments to Claude Code or Copilot Chat. A review uses the diff shown by [unified.nvim](https://github.com/axkirillov/unified.nvim) when one is shown, but comments can be made on any file.

| Keys / Command | Action |
|---|---|
| `:Review [ref]` / `<leader>rr` | Start a review, optionally against `ref` |
| `<leader>rc` | Comment on the cursor line or the selection |
| `<leader>re` / `<leader>rd` / `<leader>rl` | Edit / delete the comments on the line / list all comments |
| `<leader>rs` / `<leader>rp` | Send the unsent comments to Claude Code / Copilot Chat (`:Review send [claude\|copilot]`) |
| `:Review end` / `<leader>rq` | End the review |
| `:Worktree [name] [stage]` / `<leader>gw` | Review a linked git worktree in its own tab, read-only and without language servers; `stage` limits the diff to its last commit |

## Task Board

In a directory with a `.claude/tasks/` board, the status line shows the progress of every run and the window bar the steps of the followed run.

| Keys / Command | Action |
|---|---|
| `:Board approval` / `<leader>ba` | Open the files waiting for approval |
| `:Board focus [slug\|all]` / `<leader>bf` | Follow one run only, or all runs |
