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

For remote machine, delete references to ssh-agent from .zshrc?

## Design notes

- only target bash, no attempt to make shell scripts portable to arbitary posix shell
  - POSIX sh is a pain
  - bash is slightly less of a pain
  - unlikely that there are any systems we care about where this functionality will be relevant,
    but bash is unavailable, and if so could just install bash first
