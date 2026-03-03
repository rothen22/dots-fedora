#!/bin/bash
# .bashrc.d/00-init.sh - One-time initialization tasks

BASHRC_INIT_FILE="$HOME/.bashrc_initialized"

# Only run once per login shell
if [ ! -f "$BASHRC_INIT_FILE" ]; then
    # One-time setup tasks
    export GPG_TTY=$(tty)
    
    # Add other one-time tasks here
    # Example: Create directories, set permissions, etc.
    
    touch "$BASHRC_INIT_FILE"
fi
