#!/bin/sh
# Build dependencies of the offline package on Debian (glibc, x86_64), used by .woodpecker/Package.yml: the official
# Neovim release, the tree-sitter CLI and a C compiler to build the parsers, make and curl for plugin builds. Built on
# glibc, the parsers and blink.cmp's matcher load on common distributions. .shrike/neovim.Dockerfile has the same
# steps, keep both in sync
set -eu

NVIM_VERSION=v0.12.5
TREE_SITTER_VERSION=v0.26.7

apt-get update
apt-get install -y --no-install-recommends build-essential ca-certificates curl git gzip tar
rm -rf /var/lib/apt/lists/*

curl -fsSL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz" | tar xz -C /opt
ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/$TREE_SITTER_VERSION/tree-sitter-linux-x64.gz" |
    gunzip >/usr/local/bin/tree-sitter
chmod +x /usr/local/bin/tree-sitter

nvim --headless +'lua if vim.fn.has("nvim-0.12") == 0 then os.exit(1) end' +qall
tree-sitter --version
