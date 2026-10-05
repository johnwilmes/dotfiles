#!/usr/bin/env bash
set -euo pipefail
key=$(mktemp)
trap 'rm -f "$key"' EXIT
curl -fsSL https://apt.fury.io/wez/gpg.key -o "$key"
sudo install -d -m 0755 /etc/apt/keyrings
sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg "$key"
sudo chmod 0644 /etc/apt/keyrings/wezterm-fury.gpg
printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
sudo apt-get update
