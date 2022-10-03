Configuration repository using dotbot

## Overview

## Usage

Design notes:
- only target bash, no attempt to make shell scripts portable to arbitary posix shell
- - POSIX sh is a pain
- - bash is slightly less of a pain
- - I don't want to spend much time on the shell anyway, so I don't care about figuring out if zsh/fish/whatever would be better
- - unlikely that there are any systems we care about where this functionality will be relevant,
    but bash is unavailable
