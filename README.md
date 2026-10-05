# Dotfiles

Personal Zsh, Neovim, Git, WezTerm, and keyboard configuration, installed with
Dotbot. Supports macOS (Apple Silicon and Intel), Ubuntu, and Ubuntu on WSL.

## Install

Clone using HTTPS on a new machine before SSH credentials are configured:

```sh
git clone https://github.com/johnwilmes/dotfiles.git ~/dotfiles
~/dotfiles/install macos
```

On macOS, Git requires Apple's Command Line Tools. If needed, run
`xcode-select --install` and finish that installation before cloning.
Homebrew is discovered even when it is missing from PATH, or installed if absent.
The installer initializes its own Brew environment; new Zsh sessions initialize
Homebrew before Oh My Zsh plugins and completions load.

Choose one profile:

```sh
~/dotfiles/install macos    # core + macOS apps and Karabiner configuration
~/dotfiles/install ubuntu   # core + WezTerm, keyboard defaults, SSH agent
~/dotfiles/install wsl      # core + Windows SSH integration and WezTerm config
~/dotfiles/install core     # shared configuration and CLI tools only
```

Each platform profile automatically includes core. Commands work from any
working directory, including paths containing spaces. The installer bootstraps
Python, Git, and recursive submodules before running Dotbot; no global pip
installation is needed.

Installation proceeds through prerequisites, packages and platform setup,
configuration links, then command checks. Failures stop the installer. Fix the
reported error and rerun the same command; earlier successful steps may remain.
Existing non-symlink configuration files are not forcibly overwritten by Dotbot.
If a destination conflicts, move it to a backup location or merge it before
rerunning. The Ubuntu profile deliberately installs `/etc/default/keyboard`.

Optional flags:

```sh
~/dotfiles/install macos --change-shell  # change login shell to an allowed Zsh
~/dotfiles/install ubuntu --upgrade     # also upgrade system packages and CLI tools
```

Without `--upgrade`, Linux keeps working Neovim/uv installations. When needed,
Linux downloads architecture-specific upstream binaries, stages and checks both
tools before replacing links, and retains previous installations under
`~/.local/stow/tools.*`. macOS installs native Neovim and uv through Homebrew.
Homebrew may still update individual packages during `brew install`.

## Platform details

- WSL requires Windows interop, PowerShell, `wslpath`, and Windows OpenSSH in its
  standard `C:\Windows\System32\OpenSSH` location. The Windows home is discovered
  from Windows rather than inferred from the username. Existing WezTerm settings
  are backed up before replacement.
- WezTerm defaults to the `Ubuntu-24.04` WSL distribution. Set
  `WEZTERM_WSL_DISTRO` in the Windows environment to select a different one.
- Karabiner may require permissions granted through macOS System Settings.
  The Alt+Tab/Alt+backtick mapping requires Karabiner 16+. Holding left Option
  starts as normal Option; pressing Tab or backtick changes it to Command until
  Option is released. Shift can reverse cycling without closing the switcher.
  Other keys pressed during that hold also see Command. Right Option is unchanged.
- GNOME dconf preferences are optional: run
  `profiles/ubuntu/dconf/load-all.sh` in your desktop session to apply them.
- Paths intentionally follow this repository's fixed `~/.config` and
  `~/.local` layout, including the exported XDG variables.
- Old Keyfactor experiments live in `archive/keyfactor_backup`, outside Neovim's
  runtime path. They are preserved for reference, not installed.

## Development

The installer targets Bash, including the system Bash 3.2 on macOS. Zsh startup
files target Zsh. Submodule versions are pinned by Git.

```sh
python3 -m unittest discover -s tests -v
bash -n install
```

Smoke tests use temporary repositories and command stubs. They perform no
network access, package installation, privilege escalation, or real-home edits.
They cover ordering, repeat runs, invalid arguments, paths with spaces, and
failure handling. Actual package/application behavior still needs validation on
the target OS.
