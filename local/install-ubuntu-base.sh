#!/usr/bin/env bash

STOW_DIR="$HOME/.local/stow"
BIN_DEST="$HOME/.local/bin/" # (this is part of systemd spec, but not XDG)
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"
FONT_DIR="$XDG_DATA_HOME/fonts"

# Apparently, reliably getting the location of a script is complicated.
# Even this will fail if the script is part of a pipeline, hence the "set -e"
set -e
BASE_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# make folders if they don't exist
mkdir -p $STOW_DIR
mkdir -p $BIN_DEST
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_STATE_HOME
mkdir -p $FONT_DIR

# Additional packages for basic system
# awk: print the lines in $APT_LIST that do not match [spaces followed by # or end of line]
# xargs: pass those lines as arguments to sudo apt install
# process substitution "<( ... )" sends output to xargs as name of file (preserving stdin, though
# I'm not sure why that's important here)
APT_LIST="$BASE_DIR/ubuntu-base.apt"
xargs -a <(awk '! /^ *(#|$)/' "$APT_LIST") -r -- sudo apt install

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
    tar xz -C "." --one-top-level=astral-uv --strip-components=1 --overwrite

ln -sf "$STOW_DIR/astral-uv/uv" $BIN_DEST
ln -sf "$STOW_DIR/astral-uv/uvx" $BIN_DEST

