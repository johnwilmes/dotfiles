#!/usr/bin/env bash

dconf load /org/gnome/desktop/ < "gnome-desktop.conf"
dconf load /org/gnome/mutter/ < "gnome-mutter.conf"
dconf load /org/gnome/shell/keybindings/ < "gnome-shell-keybindings.conf"
dconf load /org/gnome/settings-daemon/plugins/ < "gnome-settingsdaemon-plugins.conf"
