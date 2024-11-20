#!/usr/bin/env bash

# TODO Install gnome shell extensions
#       extension to override "activities overview" on login: https://extensions.gnome.org/extension/4099/no-overview/

# Source base installation, with location environment variables and basic installations
set -e
BASE_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source $BASE_DIR/install-ubuntu-base.sh

# Add wezterm APT repo
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update

# Additional packages for local system
LOCAL_APT_LIST="$BASE_DIR/ubuntu-local.apt"
xargs -a <(awk '! /^ *(#|$)/' "$APT_LIST") -r -- sudo apt install

# Set system defaults
sudo cp -R "$BASE_DIR/etc/default/*" /etc/default/

# Load dconf preferences (mostly gnome keybindings)
dconf load /org/gnome/desktop/ < "$BASE_DIR/../dconf/gnome-desktop.conf"
dconf load /org/gnome/mutter/keybindings/ < "$BASE_DIR/../dconf/gnome-mutter.conf"
dconf load /org/gnome/shell/keybindings/ < "$BASE_DIR/../dconf/gnome-shell-keybindings.conf"
dconf load /org/gnome/settings-daemon/plugins/ < "$BASE_DIR/../dconf/gnome-settingsdaemon-plugins.conf"

#iosevkazip=$(mktemp --suffix=.zip)
#curl -L https://github.com/be5invis/Iosevka/releases/download/v22.1.1/super-ttc-sgr-iosevka-fixed-22.1.1.zip > $iosevkazip
#unzip $iosevkazip -d $FONT_DIR
#rm -f $iosevkazip
#fc-cache -f
