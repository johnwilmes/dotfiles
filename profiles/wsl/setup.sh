#!/usr/bin/env bash

win_user=$(powershell.exe '$env:UserName')
win_user=$(echo $win_user | tr -d '[:space:]') # remove trailing whitespace
win_home="/mnt/c/Users/${win_user}"

ln -sf $win_home "$HOME/winhome"

cp "${BASE_DIR}/wezterm.lua" "${win_home}/.wezterm.lua"

