#!/usr/bin/env bash

# Add wezterm APT repo
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt install wezterm -y

# Set system defaults
sudo cp -R "${PROFILE_DIR}/etc/default/*" /etc/default/

# Load dconf preferences (mostly gnome keybindings)
#dconf load /org/gnome/desktop/ < "${PROFILE_DIR}/dconf/gnome-desktop.conf"
#dconf load /org/gnome/mutter/keybindings/ < "${PROFILE_DIR}/dconf/gnome-mutter.conf"
#dconf load /org/gnome/shell/keybindings/ < "${PROFILE_DIR}/dconf/gnome-shell-keybindings.conf"
#dconf load /org/gnome/settings-daemon/plugins/ < "${PROFILE_DIR}/dconf/gnome-settingsdaemon-plugins.conf"

#iosevkazip=$(mktemp --suffix=.zip)
#curl -L https://github.com/be5invis/Iosevka/releases/download/v22.1.1/super-ttc-sgr-iosevka-fixed-22.1.1.zip > $iosevkazip
#unzip $iosevkazip -d $FONT_DIR
#rm -f $iosevkazip
#fc-cache -f
