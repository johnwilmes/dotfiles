#!/usr/bin/env bash
set -euo pipefail

tools_work=false
if command -v nvim >/dev/null && command -v uv >/dev/null && command -v uvx >/dev/null; then
    if nvim --version >/dev/null 2>&1 && uv --version >/dev/null 2>&1 && uvx --version >/dev/null 2>&1; then
        tools_work=true
    fi
fi
if [[ "$(uname -s)" == Linux ]] && { [[ "$tools_work" == false ]] || [[ "${UPGRADE_TOOLS:-false}" == true ]]; }; then
    case "$(uname -m)" in
        x86_64) nvim_arch=x86_64; uv_arch=x86_64 ;;
        aarch64|arm64) nvim_arch=arm64; uv_arch=aarch64 ;;
        *) echo "Unsupported Linux architecture." >&2; exit 1 ;;
    esac
    stage=$(mktemp -d)
    trap 'rm -rf "$stage"' EXIT
    # Download and extract both tools before changing any installed files.
    curl -fL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" -o "$stage/nvim.tar.gz"
    curl -fL "https://github.com/astral-sh/uv/releases/latest/download/uv-$uv_arch-unknown-linux-gnu.tar.gz" -o "$stage/uv.tar.gz"
    mkdir -p "$stage/nvim" "$stage/uv"
    tar xzf "$stage/nvim.tar.gz" -C "$stage/nvim" --strip-components=1
    tar xzf "$stage/uv.tar.gz" -C "$stage/uv" --strip-components=1
    "$stage/nvim/bin/nvim" --version >/dev/null
    "$stage/uv/uv" --version >/dev/null
    "$stage/uv/uvx" --version >/dev/null
    mkdir -p "$STOW_DIR" "$BIN_DEST"
    # Keep old versions intact; each successful install gets its own directory.
    destination=$(mktemp -d "$STOW_DIR/tools.XXXXXX")
    mv "$stage/nvim" "$destination/nvim"
    mv "$stage/uv" "$destination/uv"
    ln -sfn "$destination/nvim/bin/nvim" "$BIN_DEST/nvim"
    ln -sfn "$destination/uv/uv" "$BIN_DEST/uv"
    ln -sfn "$destination/uv/uvx" "$BIN_DEST/uvx"
fi

if [[ "${CHANGE_SHELL:-false}" == true ]]; then
    shell_path=$(command -v zsh)
    grep -Fxq "$shell_path" /etc/shells || { echo "$shell_path is not listed in /etc/shells." >&2; exit 1; }
    [[ "${SHELL:-}" == "$shell_path" ]] || chsh -s "$shell_path"
fi
