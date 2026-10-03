FROM debian:trixie-slim

# Same steps as .ci/install-deps.sh (used by .woodpecker/Package.yml), keep both in sync
ARG NVIM_VERSION=v0.12.5
ARG TREE_SITTER_VERSION=v0.26.7
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential ca-certificates curl git gzip tar && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz" | \
        tar xz -C /opt && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
    curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/$TREE_SITTER_VERSION/tree-sitter-linux-x64.gz" | \
        gunzip > /usr/local/bin/tree-sitter && \
    chmod +x /usr/local/bin/tree-sitter && \
    nvim --headless +'lua if vim.fn.has("nvim-0.12") == 0 then os.exit(1) end' +qall && \
    tree-sitter --version
