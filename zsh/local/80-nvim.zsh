EDITOR=`command -v vim`
if command -v nvim &> /dev/null; then
    EDITOR=`command -v nvim`
    alias vi='nvim'
    alias vim='nvim'
    alias view='nvim -R'
    alias vimdiff='nvim -d'
fi
export EDITOR
export VISUAL="$EDITOR"

# How long to wait for additional characters in sequence (e.g. due to <alt> via <esc> mapping...)
# 1 = 10ms
export KEYTIMEOUT=1


