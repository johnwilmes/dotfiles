local wezterm = require('wezterm')
local config = wezterm.config_builder()

config.enable_kitty_keyboard = true
config.use_dead_keys = false
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}

-- WINDOWS SPECIFIC
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- We are running on Windows; maybe we emit different
  -- key assignments here?
  wsl_distribution = 'Ubuntu-24.04'
  config.wsl_domains = {
      {
          name = 'wsl',
          distribution = wsl_distribution,
          default_cwd = '~',
      },
      {
          name = 'wsl:root',
          distribution = wsl_distribution,
          username = 'root',
          default_cwd = '/root',
      },
  }
  config.launch_menu = {
      {
          label = 'WSL',
          domain = { DomainName = 'wsl' },
          cwd = '~', -- For some reason, doesn't seem to work to infer CWD from current pane...
      },
      {
          label = 'WSL (root)',
          domain = { DomainName = 'wsl:root' },
          cwd = '/root/',
      },
      {
          label = 'Powershell',
          domain = { DomainName = 'local' },
          args = { 'powershell.exe', '-NoLogo', },

      },
      {
          label = 'Cmd',
          domain = { DomainName = 'local' },
      },
  }

  config.default_domain = 'wsl'
end

return config
