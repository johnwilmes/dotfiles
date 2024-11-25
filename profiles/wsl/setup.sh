#!/usr/bin/env bash

win_user=$(powershell.exe '$env:UserName')
win_home = "/mnt/c/Users/${win_user}"

# Set system defaults
sudo cp -R "${PROFILE_DIR}/etc/default/*" /etc/default/

ln -sf $win_home "$HOME/winhome"

cp "${BASE_DIR}/wezterm.lua" "${win_home}/.wezterm.lua"

