#!/usr/bin/env bash
set -euo pipefail
windows_home=$(powershell.exe -NoProfile -Command '[Environment]::GetFolderPath("UserProfile")' | tr -d '\r\n')
[[ -n "$windows_home" ]] || { echo "Could not determine Windows home." >&2; exit 1; }
win_home=$(wslpath -u "$windows_home")
[[ -d "$win_home" ]] || { echo "Windows home is inaccessible: $win_home" >&2; exit 1; }
if [[ -e "$HOME/winhome" && ! -L "$HOME/winhome" ]]; then
    echo "Refusing to replace existing directory: $HOME/winhome" >&2
    exit 1
fi
ln -sfn "$win_home" "$HOME/winhome"
# Preserve an existing terminal configuration before installing ours.
if [[ -f "$win_home/.wezterm.lua" ]] && ! cmp -s "$BASE_DIR/wezterm.lua" "$win_home/.wezterm.lua"; then
    backup=$(mktemp "$win_home/.wezterm.lua.backup.XXXXXX")
    cp "$win_home/.wezterm.lua" "$backup"
fi
cp "$BASE_DIR/wezterm.lua" "$win_home/.wezterm.lua"
