#!/usr/bin/env bash

# Set shell
echo "Changing shell to zsh"
chsh -s /usr/bin/zsh

# Download neovim
curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz |
    tar xz -C "$STOW_DIR" --one-top-level=nvim --strip-components=1 --overwrite

# symlink just the bin for nvim, the share doesn't have anything we need
ln -sf "$STOW_DIR/nvim/bin/nvim" $BIN_DEST

# install uv
curl -L https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz |
    tar xz -C "$STOW_DIR" --one-top-level=astral-uv --strip-components=1 --overwrite

ln -sf "$STOW_DIR/astral-uv/uv" $BIN_DEST
ln -sf "$STOW_DIR/astral-uv/uvx" $BIN_DEST

