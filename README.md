# Neovim Configuration

## title

### title

> [!IMPORTANT]
> This is a personal neovim configuration. It may be updated any time. If you have any suggestions or plugin recommendations, please share them and I may introduce them to this environment.

[![status-badge](https://github-ci.code-ape.dev/api/badges/1/status.svg?events=tag&workflow=Package&step=artifact)](https://github-ci.code-ape.dev/repos/1)
[![status-badge](https://github-ci.code-ape.dev/api/badges/1/status.svg?events=tag&workflow=Package&step=upload)](https://github-ci.code-ape.dev/repos/1)
[![Plugin Installation](https://github.com/TumbleOwlee/neovim-config/actions/workflows/cache.yml/badge.svg)](https://github.com/TumbleOwlee/neovim-config/actions/workflows/cache.yml)

This repository contains a customized [Neovim](https://github.com/neovim/neovim) configuration for `C`, `C++` and `Rust` developement. Additional languages are configured but not the focus of the setup. Thus, it may be necessary to configure additional LSPs (see [`lua/plugins/nvim-lspconfig.lua`](https://github.com/TumbleOwlee/neovim-config/blob/main/lua/plugins/nvim-lspconfig.lua)). This configuration utilizes various plugins to add useful features. Each plugin is configured in [`lua/plugins`](https://github.com/TumbleOwlee/neovim-config/blob/main/Lua/plugins).  On the other hand general settings are located in [`lua/config`](https://github.com/TumbleOwlee/neovim-config/blob/main/lua/config).

## Online Installation

The easiest way to use and update this neovim configuration is to clone the repository and pull changes from time to time. Keep in mind, on first start of `neovim` [`LazyVim`](https://github.com/LazyVim/LazyVim) and all configured plugins will be automatically installed.

```bash
git clone https://github.com/TumbleOwlee/neovim-config ~/.config/nvim/
```

## Offline Installation

> [!NOTE]
> The nightly build is executed in each commit. This the installed neovim setup is always up-to-date.

In case your environment doesn't have internet access, this repository provides a nightly packages containing the configuration and all installed plugins. Just go to the [nightly release](https://github.com/TumbleOwlee/neovim-config/releases/tag/nightly) and download the [`neovim-config.tar.gz`](https://github.com/TumbleOwlee/neovim-config/releases/download/nightly/neovim-config.tar.gz). Move the archive onto your system and just unpack it into `~/` using `tar -xvf neovim-config.tar.gz`. The archive provides the contents of `~/.config/nvim` and `.local/nvim`. Afterwards you are ready to go.

*[x] todo

*[ ] test

##### Something

```rust
fn main() {
    println!("test");
}
```
