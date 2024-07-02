Configuration repository using dotbot

## Overview

## Usage

    git clone git@github.com:johnwilmes/dotfiles.git
    cd dotfiles
    git submodule init
    git submodule update
    ./install core
    cd local
    ./install-<something>.sh

Note that if you are doing this on a remote machine, it probably won't have the kitty terminfo
available. So from local kitty, run

    kitten ssh <hostname>

Afterwards, execute vi and run `:PackerSync`

For remote machine, delete references to ssh-agent from .zshrc?

## Design notes

- only target bash, no attempt to make shell scripts portable to arbitary posix shell
- - POSIX sh is a pain
- - bash is slightly less of a pain
- - I don't want to spend much time on the shell anyway, so I don't care about figuring out if zsh/fish/whatever would be better
- - unlikely that there are any systems we care about where this functionality will be relevant,
    but bash is unavailable
