FROM alpine:latest

RUN apk add --no-cache build-base cmake coreutils curl unzip gettext-tiny-dev git wget linux-headers && \
    git clone https://github.com/neovim/neovim && \
    cd neovim && \
    git checkout stable && \
    make CMAKE_BUILD_TYPE=Release && \
    make install && \
    cd .. && \
    rm -rf neovim && \
    nvim --headless +'lua if vim.fn.has("nvim-0.12") == 0 then os.exit(1) end' +qall

