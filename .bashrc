# .bashrc - Simplified

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source personal aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Source modular configs
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
