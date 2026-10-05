# Discover Homebrew for the Bash installer without changing the environment.
find_homebrew() {
    brew_bin=$(command -v brew 2>/dev/null) && [[ -x "$brew_bin" ]] && return 0
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [[ -x "$brew_bin" ]] && return 0
    done
    return 1
}
