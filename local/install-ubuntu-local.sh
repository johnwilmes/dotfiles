#!/usr/bin/env bash

# TODO Install gnome shell extensions
#       extension to override "activities overview" on login: https://extensions.gnome.org/extension/4099/no-overview/

# Source base installation, with location environment variables and basic installations
set -e
BASE_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source $BASE_DIR/install-ubuntu-base.sh

# Additional packages for local system
LOCAL_APT_LIST="$BASE_DIR/ubuntu-local.apt"
xargs -a <(awk '! /^ *(#|$)/' "$APT_LIST") -r -- sudo apt install

# Set system defaults
sudo cp -R "$BASE_DIR/etc/default/*" /etc/default/
sudo update-grub

# install poetry
python3 install-poetry.py

# Load dconf preferences (mostly gnome keybindings)
dconf load /org/gnome/desktop/ < "$BASE_DIR/../dconf/gnome-desktop.conf"
dconf load /org/gnome/mutter/keybindings/ < "$BASE_DIR/../dconf/gnome-mutter.conf"
dconf load /org/gnome/shell/keybindings/ < "$BASE_DIR/../dconf/gnome-shell-keybindings.conf"
dconf load /org/gnome/settings-daemon/plugins/ < "$BASE_DIR/../dconf/gnome-settingsdaemon-plugins.conf"

# TODO:
# automatically get latest release from github instead of requiring manual url
# Download kitty terminal emulator
curl -L https://github.com/kovidgoyal/kitty/releases/download/v0.28.1/kitty-0.28.1-x86_64.txz |
    tar xJ -C "$STOW_DIR" --one-top-level=kitty --overwrite

# symlink the bin and share directories for kitty
stow -d "$STOW_DIR" --ignore='^lib.*' --no-folding kitty

iosevkazip=$(mktemp --suffix=.zip)
curl -L https://github.com/be5invis/Iosevka/releases/download/v22.1.1/super-ttc-sgr-iosevka-fixed-22.1.1.zip > $iosevkazip
unzip $iosevkazip -d $FONT_DIR
rm -f $iosevkazip

blexzip=$(mktemp --suffix=.zip)
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/IBMPlexMono.zip > $blexzip
unzip $blexzip -d $FONT_DIR
rm -f $blexzip

fc-cache -f
