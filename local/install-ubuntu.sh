#!/usr/bin/env bash

# TODO Install gnome shell extensions
#       extension to override "activities overview" on login: https://extensions.gnome.org/extension/4099/no-overview/

STOW_DIR="$HOME/.local/stow"
BIN_DEST="$HOME/.local/bin/" # (this is part of systemd spec, but not XDG)
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"
FONT_DIR="$XDG_DATA_HOME/fonts"

set -e

# Apparently, reliably getting the location of a script is complicated.
# Even this will fail if the script is part of a pipeline, hence the "set -e"
BASE_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
APT_LIST="$BASE_DIR/ubuntu.apt"

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
xargs -a <(awk '! /^ *(#|$)/' "$APT_LIST") -r -- sudo apt install

# ln -s $(which fdfind) "$BIN_DEST/fd"

# Set system defaults
sudo cp -R "$BASE_DIR/etc/default" /etc/default
sudo update-grub

# Set shell
echo "Changing shell to zsh"
chsh -s /usr/bin/zsh

# Load dconf preferences (mostly gnome keybindings)
dconf load /org/gnome/desktop/wm/ < "$BASE_DIR/../dconf/gnome-desktop-wm.conf"
dconf load /org/gnome/mutter/keybindings/ < "$BASE_DIR/../dconf/gnome-mutter.conf"
dconf load /org/gnome/shell/keybindings/ < "$BASE_DIR/../dconf/gnome-shell-keybindings.conf"
dconf load /org/gnome/settings-daemon/plugins/ < "$BASE_DIR/../dconf/gnome-settingsdaemon-plugins.conf"

# TODO:
# automatically get latest release from github instead of requiring manual url
# Download kitty terminal emulator
curl -L https://github.com/kovidgoyal/kitty/releases/download/v0.25.0/kitty-0.25.0-x86_64.txz |
    tar xJ -C "$STOW_DIR" --one-top-level=kitty --overwrite
# Download neovim
curl -L https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.tar.gz |
    tar xz -C "$STOW_DIR" --one-top-level=nvim --strip-components=1 --overwrite

# symlink the bin and share directories for kitty
stow -d "$STOW_DIR" --ignore='^lib.*' --no-folding kitty
# just the bin for nvim, the share doesn't have anything we need
ln -sf "$STOW_DIR/nvim/bin/nvim" $BIN_DEST

iosevkazip=$(mktemp --suffix=.zip)
curl -L https://github.com/be5invis/Iosevka/releases/download/v10.3.0/super-ttc-sgr-iosevka-fixed-10.3.0.zip > $iosevkazip
unzip $iosevkazip -d $FONT_DIR
rm -f $iosevkazip

blexzip=$(mktemp --suffix=.zip)
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/IBMPlexMono.zip > $blexzip
unzip $blexzip -d $FONT_DIR
rm -f $blexzip

fc-cache -f
