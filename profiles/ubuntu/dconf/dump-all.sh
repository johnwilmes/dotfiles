#!/usr/bin/env bash

dconf dump /org/gnome/desktop/ > "gnome-desktop.conf"
dconf dump /org/gnome/mutter/ > "gnome-mutter.conf"
dconf dump /org/gnome/shell/keybindings/ > "gnome-shell-keybindings.conf"
dconf dump /org/gnome/settings-daemon/plugins/ > "gnome-settingsdaemon-plugins.conf"
