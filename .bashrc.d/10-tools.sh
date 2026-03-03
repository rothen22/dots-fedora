#!/bin/bash
# .bashrc.d/10-tools.sh - Initialize external tools

# Starship prompt (only init if installed)
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# Zoxide (only init if installed)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash --cmd cd)"
fi
