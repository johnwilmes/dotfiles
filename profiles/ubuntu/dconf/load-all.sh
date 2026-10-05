#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

dconf load /org/gnome/desktop/ < "gnome-desktop.conf"
dconf load /org/gnome/mutter/ < "gnome-mutter.conf"
dconf load /org/gnome/shell/keybindings/ < "gnome-shell-keybindings.conf"
dconf load /org/gnome/settings-daemon/plugins/ < "gnome-settingsdaemon-plugins.conf"
