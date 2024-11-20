local wezterm = require('wezterm')
local config = wezterm.config_builder()

config.enable_kitty_keyboard = true
config.use_dead_keys = false
config.audible_bell = "Disabled"

return config
